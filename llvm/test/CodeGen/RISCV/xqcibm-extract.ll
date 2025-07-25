; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefixes=RV32I
; RUN: llc -mtriple=riscv32 -mattr=+experimental-xqcibm -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefixes=RV32XQCIBM
; RUN: llc -mtriple=riscv32 -mattr=+experimental-xqcibm,+zbb -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefixes=RV32XQCIBMZBB

define i32 @sexti1_i32(i1 %a) nounwind {
; RV32I-LABEL: sexti1_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 31
; RV32I-NEXT:    srai a0, a0, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti1_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 1, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti1_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.ext a0, a0, 1, 0
; RV32XQCIBMZBB-NEXT:    ret
  %sext = sext i1 %a to i32
  ret i32 %sext
}

define i32 @sexti1_i32_2(i32 %a) {
; RV32I-LABEL: sexti1_i32_2:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 31
; RV32I-NEXT:    srai a0, a0, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti1_i32_2:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 1, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti1_i32_2:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.ext a0, a0, 1, 0
; RV32XQCIBMZBB-NEXT:    ret
  %shl = shl i32 %a, 31
  %shr = ashr exact i32 %shl, 31
  ret i32 %shr
}


define i32 @sexti8_i32(i8 %a) nounwind {
; RV32I-LABEL: sexti8_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 24
; RV32I-NEXT:    srai a0, a0, 24
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti8_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 8, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti8_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    sext.b a0, a0
; RV32XQCIBMZBB-NEXT:    ret
  %sext = sext i8 %a to i32
  ret i32 %sext
}

define i32 @sexti8_i32_2(i32 %a) {
; RV32I-LABEL: sexti8_i32_2:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 24
; RV32I-NEXT:    srai a0, a0, 24
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti8_i32_2:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 8, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti8_i32_2:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    sext.b a0, a0
; RV32XQCIBMZBB-NEXT:    ret
  %shl = shl i32 %a, 24
  %shr = ashr exact i32 %shl, 24
  ret i32 %shr
}

define i32 @sexti16_i32(i16 %a) nounwind {
; RV32I-LABEL: sexti16_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 16
; RV32I-NEXT:    srai a0, a0, 16
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti16_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 16, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti16_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    sext.h a0, a0
; RV32XQCIBMZBB-NEXT:    ret
  %sext = sext i16 %a to i32
  ret i32 %sext
}

define i32 @sexti16_i32_2(i32 %a) {
; RV32I-LABEL: sexti16_i32_2:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 16
; RV32I-NEXT:    srai a0, a0, 16
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti16_i32_2:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 16, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti16_i32_2:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    sext.h a0, a0
; RV32XQCIBMZBB-NEXT:    ret
  %shl = shl i32 %a, 16
  %shr = ashr exact i32 %shl, 16
  ret i32 %shr
}

define i64 @sexti1_i64(i64 %a) {
; RV32I-LABEL: sexti1_i64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 31
; RV32I-NEXT:    srai a0, a0, 31
; RV32I-NEXT:    mv a1, a0
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti1_i64:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 1, 0
; RV32XQCIBM-NEXT:    mv a1, a0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti1_i64:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.ext a0, a0, 1, 0
; RV32XQCIBMZBB-NEXT:    mv a1, a0
; RV32XQCIBMZBB-NEXT:    ret
  %shl = shl i64 %a, 63
  %shr = ashr exact i64 %shl, 63
  ret i64 %shr
}

define i64 @sexti1_i64_2(i1 %a) {
; RV32I-LABEL: sexti1_i64_2:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 31
; RV32I-NEXT:    srai a0, a0, 31
; RV32I-NEXT:    mv a1, a0
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti1_i64_2:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 1, 0
; RV32XQCIBM-NEXT:    mv a1, a0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti1_i64_2:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.ext a0, a0, 1, 0
; RV32XQCIBMZBB-NEXT:    mv a1, a0
; RV32XQCIBMZBB-NEXT:    ret
  %1 = sext i1 %a to i64
  ret i64 %1
}

define i64 @sexti8_i64(i64 %a) {
; RV32I-LABEL: sexti8_i64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a1, a0, 24
; RV32I-NEXT:    srai a0, a1, 24
; RV32I-NEXT:    srai a1, a1, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti8_i64:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 8, 0
; RV32XQCIBM-NEXT:    srai a1, a0, 31
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti8_i64:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    sext.b a0, a0
; RV32XQCIBMZBB-NEXT:    srai a1, a0, 31
; RV32XQCIBMZBB-NEXT:    ret
  %shl = shl i64 %a, 56
  %shr = ashr exact i64 %shl, 56
  ret i64 %shr
}

define i64 @sexti8_i64_2(i8 %a) {
; RV32I-LABEL: sexti8_i64_2:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a1, a0, 24
; RV32I-NEXT:    srai a0, a1, 24
; RV32I-NEXT:    srai a1, a1, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti8_i64_2:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 8, 0
; RV32XQCIBM-NEXT:    srai a1, a0, 31
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti8_i64_2:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    sext.b a0, a0
; RV32XQCIBMZBB-NEXT:    srai a1, a0, 31
; RV32XQCIBMZBB-NEXT:    ret
  %1 = sext i8 %a to i64
  ret i64 %1
}

define i64 @sexti16_i64(i64 %a) {
; RV32I-LABEL: sexti16_i64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a1, a0, 16
; RV32I-NEXT:    srai a0, a1, 16
; RV32I-NEXT:    srai a1, a1, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti16_i64:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 16, 0
; RV32XQCIBM-NEXT:    srai a1, a0, 31
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti16_i64:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    sext.h a0, a0
; RV32XQCIBMZBB-NEXT:    srai a1, a0, 31
; RV32XQCIBMZBB-NEXT:    ret
  %shl = shl i64 %a, 48
  %shr = ashr exact i64 %shl, 48
  ret i64 %shr
}

define i64 @sexti16_i64_2(i16 %a) {
; RV32I-LABEL: sexti16_i64_2:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a1, a0, 16
; RV32I-NEXT:    srai a0, a1, 16
; RV32I-NEXT:    srai a1, a1, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti16_i64_2:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 16, 0
; RV32XQCIBM-NEXT:    srai a1, a0, 31
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti16_i64_2:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    sext.h a0, a0
; RV32XQCIBMZBB-NEXT:    srai a1, a0, 31
; RV32XQCIBMZBB-NEXT:    ret
  %1 = sext i16 %a to i64
  ret i64 %1
}

define i64 @sexti32_i64(i64 %a) {
; RV32I-LABEL: sexti32_i64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    srai a1, a0, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti32_i64:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    srai a1, a0, 31
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti32_i64:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    srai a1, a0, 31
; RV32XQCIBMZBB-NEXT:    ret
  %shl = shl i64 %a, 32
  %shr = ashr exact i64 %shl, 32
  ret i64 %shr
}

define i64 @sexti32_i64_2(i32 %a) {
; RV32I-LABEL: sexti32_i64_2:
; RV32I:       # %bb.0:
; RV32I-NEXT:    srai a1, a0, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: sexti32_i64_2:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    srai a1, a0, 31
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: sexti32_i64_2:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    srai a1, a0, 31
; RV32XQCIBMZBB-NEXT:    ret
  %1 = sext i32 %a to i64
  ret i64 %1
}

define i32 @extu_from_and_i32(i32 %x) {
; RV32I-LABEL: extu_from_and_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 20
; RV32I-NEXT:    srli a0, a0, 20
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: extu_from_and_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.extu a0, a0, 12, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: extu_from_and_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.extu a0, a0, 12, 0
; RV32XQCIBMZBB-NEXT:    ret
  %a = and i32 %x, 4095
  ret i32 %a
}

define i32 @no_extu_from_and_i32(i32 %x) {
; RV32I-LABEL: no_extu_from_and_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    andi a0, a0, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: no_extu_from_and_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    andi a0, a0, 31
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: no_extu_from_and_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    andi a0, a0, 31
; RV32XQCIBMZBB-NEXT:    ret
  %a = and i32 %x, 31
  ret i32 %a
}

define i32 @extu_from_and_i32_simm12_lb(i32 %x) {
; RV32I-LABEL: extu_from_and_i32_simm12_lb:
; RV32I:       # %bb.0:
; RV32I-NEXT:    andi a0, a0, 63
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: extu_from_and_i32_simm12_lb:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.extu a0, a0, 6, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: extu_from_and_i32_simm12_lb:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.extu a0, a0, 6, 0
; RV32XQCIBMZBB-NEXT:    ret
  %a = and i32 %x, 63
  ret i32 %a
}

define i32 @extu_from_and_i32_simm12_ub(i32 %x) {
; RV32I-LABEL: extu_from_and_i32_simm12_ub:
; RV32I:       # %bb.0:
; RV32I-NEXT:    andi a0, a0, 2047
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: extu_from_and_i32_simm12_ub:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.extu a0, a0, 11, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: extu_from_and_i32_simm12_ub:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.extu a0, a0, 11, 0
; RV32XQCIBMZBB-NEXT:    ret
  %a = and i32 %x, 2047
  ret i32 %a
}

define i64 @extu_from_and_i64(i64 %x) {
; RV32I-LABEL: extu_from_and_i64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 20
; RV32I-NEXT:    srli a0, a0, 20
; RV32I-NEXT:    li a1, 0
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: extu_from_and_i64:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.extu a0, a0, 12, 0
; RV32XQCIBM-NEXT:    li a1, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: extu_from_and_i64:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.extu a0, a0, 12, 0
; RV32XQCIBMZBB-NEXT:    li a1, 0
; RV32XQCIBMZBB-NEXT:    ret
  %a = and i64 %x, 4095
  ret i64 %a
}

define i32 @extu_from_and_lshr_i32(i32 %x) {
; RV32I-LABEL: extu_from_and_lshr_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 6
; RV32I-NEXT:    srli a0, a0, 29
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: extu_from_and_lshr_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.extu a0, a0, 3, 23
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: extu_from_and_lshr_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.extu a0, a0, 3, 23
; RV32XQCIBMZBB-NEXT:    ret
  %shifted = lshr i32 %x, 23
  %masked = and i32 %shifted, 7
  ret i32 %masked
}

define i64 @extu_from_and_lshr_i64(i64 %x) {
; RV32I-LABEL: extu_from_and_lshr_i64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a1, 6
; RV32I-NEXT:    srli a0, a0, 20
; RV32I-NEXT:    li a1, 0
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: extu_from_and_lshr_i64:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.extu a0, a1, 12, 14
; RV32XQCIBM-NEXT:    li a1, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: extu_from_and_lshr_i64:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.extu a0, a1, 12, 14
; RV32XQCIBMZBB-NEXT:    li a1, 0
; RV32XQCIBMZBB-NEXT:    ret
  %shifted = lshr i64 %x, 46
  %masked = and i64 %shifted, 4095
  ret i64 %masked
}

define i32 @extu_from_lshr_and_i32(i32 %x) {
; RV32I-LABEL: extu_from_lshr_and_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 8
; RV32I-NEXT:    srli a0, a0, 20
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: extu_from_lshr_and_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.extu a0, a0, 12, 12
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: extu_from_lshr_and_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.extu a0, a0, 12, 12
; RV32XQCIBMZBB-NEXT:    ret
  %masked = and i32 %x, 16773120
  %shifted = lshr i32 %masked, 12
  ret i32 %shifted
}

define i64 @extu_from_lshr_and_i64(i64 %x) {
; RV32I-LABEL: extu_from_lshr_and_i64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 8
; RV32I-NEXT:    srli a0, a0, 20
; RV32I-NEXT:    li a1, 0
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: extu_from_lshr_and_i64:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.extu a0, a0, 12, 12
; RV32XQCIBM-NEXT:    li a1, 0
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: extu_from_lshr_and_i64:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.extu a0, a0, 12, 12
; RV32XQCIBMZBB-NEXT:    li a1, 0
; RV32XQCIBMZBB-NEXT:    ret
  %masked = and i64 %x, 16773120
  %shifted = lshr i64 %masked, 12
  ret i64 %shifted
}

define i32 @ext_from_ashr_shl_i32(i32 %x) {
; RV32I-LABEL: ext_from_ashr_shl_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 8
; RV32I-NEXT:    srai a0, a0, 24
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: ext_from_ashr_shl_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 8, 16
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: ext_from_ashr_shl_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.ext a0, a0, 8, 16
; RV32XQCIBMZBB-NEXT:    ret
  %shl = shl i32 %x, 8
  %ashr = ashr i32 %shl, 24
  ret i32 %ashr
}

define i32 @ext_from_ashr_sexti8_i32(i8 %x) {
; RV32I-LABEL: ext_from_ashr_sexti8_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 24
; RV32I-NEXT:    srai a0, a0, 29
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: ext_from_ashr_sexti8_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 3, 5
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: ext_from_ashr_sexti8_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.ext a0, a0, 3, 5
; RV32XQCIBMZBB-NEXT:    ret
  %sext = sext i8 %x to i32
  %ashr = ashr i32 %sext, 5
  ret i32 %ashr
}

define i32 @ext_from_ashr_sexti16_i32(i16 %x) {
; RV32I-LABEL: ext_from_ashr_sexti16_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    slli a0, a0, 16
; RV32I-NEXT:    srai a0, a0, 31
; RV32I-NEXT:    ret
;
; RV32XQCIBM-LABEL: ext_from_ashr_sexti16_i32:
; RV32XQCIBM:       # %bb.0:
; RV32XQCIBM-NEXT:    qc.ext a0, a0, 1, 15
; RV32XQCIBM-NEXT:    ret
;
; RV32XQCIBMZBB-LABEL: ext_from_ashr_sexti16_i32:
; RV32XQCIBMZBB:       # %bb.0:
; RV32XQCIBMZBB-NEXT:    qc.ext a0, a0, 1, 15
; RV32XQCIBMZBB-NEXT:    ret
  %sext = sext i16 %x to i32
  %ashr = ashr i32 %sext, 24
  ret i32 %ashr
}
