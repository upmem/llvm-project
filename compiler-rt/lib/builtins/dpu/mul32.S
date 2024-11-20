        .text
        .globl  __mul32
        .type   __mul32,@function
__mul32:
        jgtu r1, r0, .Ltmp0
        move r2, r0
        move r0, r1, true, .Ltmp1
.Ltmp0:
        move r2, r1
        // move r0, r0
.Ltmp1:
        move r1, zero
        mul_step d0, r2, d0, 0, z, .Ltmp2
        mul_step d0, r2, d0, 1, z, .Ltmp2
        mul_step d0, r2, d0, 2, z, .Ltmp2
        mul_step d0, r2, d0, 3, z, .Ltmp2
        mul_step d0, r2, d0, 4, z, .Ltmp2
        mul_step d0, r2, d0, 5, z, .Ltmp2
        mul_step d0, r2, d0, 6, z, .Ltmp2
        mul_step d0, r2, d0, 7, z, .Ltmp2
        mul_step d0, r2, d0, 8, z, .Ltmp2
        mul_step d0, r2, d0, 9, z, .Ltmp2
        mul_step d0, r2, d0, 10, z, .Ltmp2
        mul_step d0, r2, d0, 11, z, .Ltmp2
        mul_step d0, r2, d0, 12, z, .Ltmp2
        mul_step d0, r2, d0, 13, z, .Ltmp2
        mul_step d0, r2, d0, 14, z, .Ltmp2
        mul_step d0, r2, d0, 15, z, .Ltmp2
        mul_step d0, r2, d0, 16, z, .Ltmp2
        mul_step d0, r2, d0, 17, z, .Ltmp2
        mul_step d0, r2, d0, 18, z, .Ltmp2
        mul_step d0, r2, d0, 19, z, .Ltmp2
        mul_step d0, r2, d0, 20, z, .Ltmp2
        mul_step d0, r2, d0, 21, z, .Ltmp2
        mul_step d0, r2, d0, 22, z, .Ltmp2
        mul_step d0, r2, d0, 23, z, .Ltmp2
        mul_step d0, r2, d0, 24, z, .Ltmp2
        mul_step d0, r2, d0, 25, z, .Ltmp2
        mul_step d0, r2, d0, 26, z, .Ltmp2
        mul_step d0, r2, d0, 27, z, .Ltmp2
        mul_step d0, r2, d0, 28, z, .Ltmp2
        mul_step d0, r2, d0, 29, z, .Ltmp2
        mul_step d0, r2, d0, 30, z, .Ltmp2
        mul_step d0, r2, d0, 31, z, .Ltmp2
.Ltmp2:
        move r0, r1

        jump r23
