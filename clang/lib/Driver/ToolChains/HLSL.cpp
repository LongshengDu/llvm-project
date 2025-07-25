//===--- HLSL.cpp - HLSL ToolChain Implementations --------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "HLSL.h"
#include "clang/Driver/CommonArgs.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Job.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/TargetParser/Triple.h"
#include <regex>

using namespace clang::driver;
using namespace clang::driver::tools;
using namespace clang::driver::toolchains;
using namespace clang;
using namespace llvm::opt;
using namespace llvm;

namespace {

const unsigned OfflineLibMinor = 0xF;

bool isLegalShaderModel(Triple &T) {
  if (T.getOS() != Triple::OSType::ShaderModel)
    return false;

  auto Version = T.getOSVersion();
  if (Version.getBuild())
    return false;
  if (Version.getSubminor())
    return false;

  auto Kind = T.getEnvironment();

  switch (Kind) {
  default:
    return false;
  case Triple::EnvironmentType::Vertex:
  case Triple::EnvironmentType::Hull:
  case Triple::EnvironmentType::Domain:
  case Triple::EnvironmentType::Geometry:
  case Triple::EnvironmentType::Pixel:
  case Triple::EnvironmentType::Compute: {
    VersionTuple MinVer(4, 0);
    return MinVer <= Version;
  } break;
  case Triple::EnvironmentType::Library: {
    VersionTuple SM6x(6, OfflineLibMinor);
    if (Version == SM6x)
      return true;

    VersionTuple MinVer(6, 3);
    return MinVer <= Version;
  } break;
  case Triple::EnvironmentType::Amplification:
  case Triple::EnvironmentType::Mesh: {
    VersionTuple MinVer(6, 5);
    return MinVer <= Version;
  } break;
  }
  return false;
}

std::optional<std::string> tryParseProfile(StringRef Profile) {
  // [ps|vs|gs|hs|ds|cs|ms|as]_[major]_[minor]
  SmallVector<StringRef, 3> Parts;
  Profile.split(Parts, "_");
  if (Parts.size() != 3)
    return std::nullopt;

  Triple::EnvironmentType Kind =
      StringSwitch<Triple::EnvironmentType>(Parts[0])
          .Case("ps", Triple::EnvironmentType::Pixel)
          .Case("vs", Triple::EnvironmentType::Vertex)
          .Case("gs", Triple::EnvironmentType::Geometry)
          .Case("hs", Triple::EnvironmentType::Hull)
          .Case("ds", Triple::EnvironmentType::Domain)
          .Case("cs", Triple::EnvironmentType::Compute)
          .Case("lib", Triple::EnvironmentType::Library)
          .Case("ms", Triple::EnvironmentType::Mesh)
          .Case("as", Triple::EnvironmentType::Amplification)
          .Default(Triple::EnvironmentType::UnknownEnvironment);
  if (Kind == Triple::EnvironmentType::UnknownEnvironment)
    return std::nullopt;

  unsigned long long Major = 0;
  if (llvm::getAsUnsignedInteger(Parts[1], 0, Major))
    return std::nullopt;

  unsigned long long Minor = 0;
  if (Parts[2] == "x" && Kind == Triple::EnvironmentType::Library)
    Minor = OfflineLibMinor;
  else if (llvm::getAsUnsignedInteger(Parts[2], 0, Minor))
    return std::nullopt;

  // Determine DXIL version using the minor version number of Shader
  // Model version specified in target profile. Prior to decoupling DXIL version
  // numbering from that of Shader Model DXIL version 1.Y corresponds to SM 6.Y.
  // E.g., dxilv1.Y-unknown-shadermodelX.Y-hull
  llvm::Triple T;
  Triple::SubArchType SubArch = llvm::Triple::NoSubArch;
  switch (Minor) {
  case 0:
    SubArch = llvm::Triple::DXILSubArch_v1_0;
    break;
  case 1:
    SubArch = llvm::Triple::DXILSubArch_v1_1;
    break;
  case 2:
    SubArch = llvm::Triple::DXILSubArch_v1_2;
    break;
  case 3:
    SubArch = llvm::Triple::DXILSubArch_v1_3;
    break;
  case 4:
    SubArch = llvm::Triple::DXILSubArch_v1_4;
    break;
  case 5:
    SubArch = llvm::Triple::DXILSubArch_v1_5;
    break;
  case 6:
    SubArch = llvm::Triple::DXILSubArch_v1_6;
    break;
  case 7:
    SubArch = llvm::Triple::DXILSubArch_v1_7;
    break;
  case 8:
    SubArch = llvm::Triple::DXILSubArch_v1_8;
    break;
  case OfflineLibMinor:
    // Always consider minor version x as the latest supported DXIL version
    SubArch = llvm::Triple::LatestDXILSubArch;
    break;
  default:
    // No DXIL Version corresponding to specified Shader Model version found
    return std::nullopt;
  }
  T.setArch(Triple::ArchType::dxil, SubArch);
  T.setOSName(Triple::getOSTypeName(Triple::OSType::ShaderModel).str() +
              VersionTuple(Major, Minor).getAsString());
  T.setEnvironment(Kind);
  if (isLegalShaderModel(T))
    return T.getTriple();
  else
    return std::nullopt;
}

bool isLegalValidatorVersion(StringRef ValVersionStr, const Driver &D) {
  VersionTuple Version;
  if (Version.tryParse(ValVersionStr) || Version.getBuild() ||
      Version.getSubminor() || !Version.getMinor()) {
    D.Diag(diag::err_drv_invalid_format_dxil_validator_version)
        << ValVersionStr;
    return false;
  }

  uint64_t Major = Version.getMajor();
  uint64_t Minor = *Version.getMinor();
  if (Major == 0 && Minor != 0) {
    D.Diag(diag::err_drv_invalid_empty_dxil_validator_version) << ValVersionStr;
    return false;
  }
  VersionTuple MinVer(1, 0);
  if (Version < MinVer) {
    D.Diag(diag::err_drv_invalid_range_dxil_validator_version) << ValVersionStr;
    return false;
  }
  return true;
}

std::string getSpirvExtArg(ArrayRef<std::string> SpvExtensionArgs) {
  if (SpvExtensionArgs.empty()) {
    return "-spirv-ext=all";
  }

  std::string LlvmOption =
      (Twine("-spirv-ext=+") + SpvExtensionArgs.front()).str();
  SpvExtensionArgs = SpvExtensionArgs.slice(1);
  for (auto Extension : SpvExtensionArgs) {
    if (Extension != "KHR")
      Extension = (Twine("+") + Extension).str();
    LlvmOption = (Twine(LlvmOption) + "," + Extension).str();
  }
  return LlvmOption;
}

bool isValidSPIRVExtensionName(const std::string &str) {
  std::regex pattern("KHR|SPV_[a-zA-Z0-9_]+");
  return std::regex_match(str, pattern);
}

// SPIRV extension names are of the form `SPV_[a-zA-Z0-9_]+`. We want to
// disallow obviously invalid names to avoid issues when parsing `spirv-ext`.
bool checkExtensionArgsAreValid(ArrayRef<std::string> SpvExtensionArgs,
                                const Driver &Driver) {
  bool AllValid = true;
  for (auto Extension : SpvExtensionArgs) {
    if (!isValidSPIRVExtensionName(Extension)) {
      Driver.Diag(diag::err_drv_invalid_value)
          << "-fspv-extension" << Extension;
      AllValid = false;
    }
  }
  return AllValid;
}
} // namespace

void tools::hlsl::Validator::ConstructJob(Compilation &C, const JobAction &JA,
                                          const InputInfo &Output,
                                          const InputInfoList &Inputs,
                                          const ArgList &Args,
                                          const char *LinkingOutput) const {
  std::string DxvPath = getToolChain().GetProgramPath("dxv");
  assert(DxvPath != "dxv" && "cannot find dxv");

  ArgStringList CmdArgs;
  assert(Inputs.size() == 1 && "Unable to handle multiple inputs.");
  const InputInfo &Input = Inputs[0];
  CmdArgs.push_back(Input.getFilename());
  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  const char *Exec = Args.MakeArgString(DxvPath);
  C.addCommand(std::make_unique<Command>(JA, *this, ResponseFileSupport::None(),
                                         Exec, CmdArgs, Inputs, Input));
}

void tools::hlsl::MetalConverter::ConstructJob(
    Compilation &C, const JobAction &JA, const InputInfo &Output,
    const InputInfoList &Inputs, const ArgList &Args,
    const char *LinkingOutput) const {
  std::string MSCPath = getToolChain().GetProgramPath("metal-shaderconverter");
  ArgStringList CmdArgs;
  assert(Inputs.size() == 1 && "Unable to handle multiple inputs.");
  const InputInfo &Input = Inputs[0];
  CmdArgs.push_back(Input.getFilename());
  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());

  const char *Exec = Args.MakeArgString(MSCPath);
  C.addCommand(std::make_unique<Command>(JA, *this, ResponseFileSupport::None(),
                                         Exec, CmdArgs, Inputs, Input));
}

/// DirectX Toolchain
HLSLToolChain::HLSLToolChain(const Driver &D, const llvm::Triple &Triple,
                             const ArgList &Args)
    : ToolChain(D, Triple, Args) {
  if (Args.hasArg(options::OPT_dxc_validator_path_EQ))
    getProgramPaths().push_back(
        Args.getLastArgValue(options::OPT_dxc_validator_path_EQ).str());
}

Tool *clang::driver::toolchains::HLSLToolChain::getTool(
    Action::ActionClass AC) const {
  switch (AC) {
  case Action::BinaryAnalyzeJobClass:
    if (!Validator)
      Validator.reset(new tools::hlsl::Validator(*this));
    return Validator.get();
  case Action::BinaryTranslatorJobClass:
    if (!MetalConverter)
      MetalConverter.reset(new tools::hlsl::MetalConverter(*this));
    return MetalConverter.get();
  default:
    return ToolChain::getTool(AC);
  }
}

std::optional<std::string>
clang::driver::toolchains::HLSLToolChain::parseTargetProfile(
    StringRef TargetProfile) {
  return tryParseProfile(TargetProfile);
}

DerivedArgList *
HLSLToolChain::TranslateArgs(const DerivedArgList &Args, StringRef BoundArch,
                             Action::OffloadKind DeviceOffloadKind) const {
  DerivedArgList *DAL = new DerivedArgList(Args.getBaseArgs());

  const OptTable &Opts = getDriver().getOpts();

  for (Arg *A : Args) {
    if (A->getOption().getID() == options::OPT_dxil_validator_version) {
      StringRef ValVerStr = A->getValue();
      if (!isLegalValidatorVersion(ValVerStr, getDriver()))
        continue;
    }
    if (A->getOption().getID() == options::OPT_dxc_entrypoint) {
      DAL->AddSeparateArg(nullptr, Opts.getOption(options::OPT_hlsl_entrypoint),
                          A->getValue());
      A->claim();
      continue;
    }
    if (A->getOption().getID() == options::OPT_dxc_rootsig_ver) {
      DAL->AddJoinedArg(nullptr,
                        Opts.getOption(options::OPT_fdx_rootsignature_version),
                        A->getValue());
      A->claim();
      continue;
    }
    if (A->getOption().getID() == options::OPT__SLASH_O) {
      StringRef OStr = A->getValue();
      if (OStr == "d") {
        DAL->AddFlagArg(nullptr, Opts.getOption(options::OPT_O0));
        A->claim();
        continue;
      } else {
        DAL->AddJoinedArg(nullptr, Opts.getOption(options::OPT_O), OStr);
        A->claim();
        continue;
      }
    }
    if (A->getOption().getID() == options::OPT_emit_pristine_llvm) {
      // Translate -fcgl into -emit-llvm and -disable-llvm-passes.
      DAL->AddFlagArg(nullptr, Opts.getOption(options::OPT_emit_llvm));
      DAL->AddFlagArg(nullptr,
                      Opts.getOption(options::OPT_disable_llvm_passes));
      A->claim();
      continue;
    }
    if (A->getOption().getID() == options::OPT_dxc_hlsl_version) {
      // Translate -HV into -std for llvm
      // depending on the value given
      LangStandard::Kind LangStd = LangStandard::getHLSLLangKind(A->getValue());
      if (LangStd != LangStandard::lang_unspecified) {
        LangStandard l = LangStandard::getLangStandardForKind(LangStd);
        DAL->AddSeparateArg(nullptr, Opts.getOption(options::OPT_std_EQ),
                            l.getName());
      } else {
        getDriver().Diag(diag::err_drv_invalid_value) << "HV" << A->getValue();
      }

      A->claim();
      continue;
    }
    if (A->getOption().getID() == options::OPT_dxc_gis) {
      // Translate -Gis into -ffp_model_EQ=strict
      DAL->AddSeparateArg(nullptr, Opts.getOption(options::OPT_ffp_model_EQ),
                          "strict");
      A->claim();
      continue;
    }
    if (A->getOption().getID() == options::OPT_fvk_use_dx_layout) {
      // This is the only implemented layout so far.
      A->claim();
      continue;
    }

    if (A->getOption().getID() == options::OPT_fvk_use_scalar_layout) {
      getDriver().Diag(diag::err_drv_clang_unsupported) << A->getAsString(Args);
      A->claim();
      continue;
    }

    if (A->getOption().getID() == options::OPT_fvk_use_gl_layout) {
      getDriver().Diag(diag::err_drv_clang_unsupported) << A->getAsString(Args);
      A->claim();
      continue;
    }

    DAL->append(A);
  }

  if (getArch() == llvm::Triple::spirv) {
    std::vector<std::string> SpvExtensionArgs =
        Args.getAllArgValues(options::OPT_fspv_extension_EQ);
    if (checkExtensionArgsAreValid(SpvExtensionArgs, getDriver())) {
      std::string LlvmOption = getSpirvExtArg(SpvExtensionArgs);
      DAL->AddSeparateArg(nullptr, Opts.getOption(options::OPT_mllvm),
                          LlvmOption);
    }
    Args.claimAllArgs(options::OPT_fspv_extension_EQ);
  }

  if (!DAL->hasArg(options::OPT_O_Group)) {
    DAL->AddJoinedArg(nullptr, Opts.getOption(options::OPT_O), "3");
  }

  return DAL;
}

bool HLSLToolChain::requiresValidation(DerivedArgList &Args) const {
  if (!Args.hasArg(options::OPT_dxc_Fo))
    return false;

  if (Args.getLastArg(options::OPT_dxc_disable_validation))
    return false;

  std::string DxvPath = GetProgramPath("dxv");
  if (DxvPath != "dxv")
    return true;

  getDriver().Diag(diag::warn_drv_dxc_missing_dxv);
  return false;
}

bool HLSLToolChain::requiresBinaryTranslation(DerivedArgList &Args) const {
  return Args.hasArg(options::OPT_metal) && Args.hasArg(options::OPT_dxc_Fo);
}

bool HLSLToolChain::isLastJob(DerivedArgList &Args,
                              Action::ActionClass AC) const {
  bool HasTranslation = requiresBinaryTranslation(Args);
  bool HasValidation = requiresValidation(Args);
  // If translation and validation are not required, we should only have one
  // action.
  if (!HasTranslation && !HasValidation)
    return true;
  if ((HasTranslation && AC == Action::BinaryTranslatorJobClass) ||
      (!HasTranslation && HasValidation && AC == Action::BinaryAnalyzeJobClass))
    return true;
  return false;
}
