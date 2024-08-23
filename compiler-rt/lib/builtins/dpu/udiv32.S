        .text
        .globl  __udiv32
        .type   __udiv32,@function
__udiv32:
	clz r2, r1, max, 1f // r2 = by how many the divider can be shifted on 32-bit
	clz r3, r0         // r3 = number of useless bits of the dividend
	sub r2, r3, r2, gtu, 2f// r2 = the maximal shift to be done
	move r3, r1
	move.u d0, r0
	jump r2, 3f                 // As we will jump backward relatively to label 3 forward
	div_step d0, r3, d0, 31
	div_step d0, r3, d0, 30
	div_step d0, r3, d0, 29
	div_step d0, r3, d0, 28
	div_step d0, r3, d0, 27
	div_step d0, r3, d0, 26
	div_step d0, r3, d0, 25
	div_step d0, r3, d0, 24
	div_step d0, r3, d0, 23
	div_step d0, r3, d0, 22
	div_step d0, r3, d0, 21
	div_step d0, r3, d0, 20
	div_step d0, r3, d0, 19
	div_step d0, r3, d0, 18
	div_step d0, r3, d0, 17
	div_step d0, r3, d0, 16
	div_step d0, r3, d0, 15
	div_step d0, r3, d0, 14
	div_step d0, r3, d0, 13
	div_step d0, r3, d0, 12
	div_step d0, r3, d0, 11
	div_step d0, r3, d0, 10
	div_step d0, r3, d0, 9
	div_step d0, r3, d0, 8
	div_step d0, r3, d0, 7
	div_step d0, r3, d0, 6
	div_step d0, r3, d0, 5
	div_step d0, r3, d0, 4
	div_step d0, r3, d0, 3
	div_step d0, r3, d0, 2
	div_step d0, r3, d0, 1
3:
	div_step d0, r3, d0, 0
4:	
	jump r23
2:
	move.u d0, r0, true, 4b
1:
	fault 2
