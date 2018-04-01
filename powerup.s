.section .text
.include "constants.s"

.global powerUpdate
powerUpdate:				@ Update location of powerUp if either is in
	push	{r4, lr}		@ the moving state (state: 0 = waiting, 1 = moving,
	ldr	r0, =powerUpState	@ and 2 = dead)
	ldr	r3, [r0, #PU1ACTIVE]
	cmp	r3, #1
	bne	nextPower

	ldr	r1, [r0, #PU1Y]
	add	r1, #2
	mov	r2, #802
	cmp	r1, r2			@ If at the bottom of the game powerup
	movge	r1, #2			@ will die
	strge	r1, [r0, #PU1ACTIVE]
	strlt	r1, [r0, #PU1Y]		@ Else increment y offset by 2
	
nextPower:
	ldr	r0, =powerUpState
	ldr	r3, [r0, #PU2ACTIVE]
	cmp	r3, #1
	bne	powerDone
	ldr	r1, [r0, #PU2Y]
	add	r1, #2
	cmp	r1, r2
	movge	r1, #2
	strge	r1, [r0, #PU2ACTIVE]
	strlt	r1, [r0, #PU2Y]

powerDone:
	pop	{r4, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global setPowerUp
setPowerUp:				@ Pick random numbers between x (160 - 640)
	@ r0 = powerUp coord location	@ and y (225 - 375)
	push	{r4-r6, lr}
	mov	r7, r0			@ save memory location

	mov	r1, #160
	mov	r2, #640
	mov	r3, #225
	mov	r4, #375

	bl	rand			@ rand() % (max + 1 - Min) + min
	add	r5, r2, #1		@ to get a # from a range
	sub	r5, r1			@@@@ Might not work @@@@
	sdiv	r6, r0, r5		
	mul	r6, r5
	sub	r0, r6	
	add	r0, r1			@ r0 = the random number
	str	r0, [r7], #4

	bl	rand			@ rand() % (max + 1 - Min) + min
	add	r5, r2, #1		@ to get a # from a range
	sub	r5, r1			@@@@ Might not work @@@@
	sdiv	r6, r0, r5		
	mul	r6, r5
	sub	r0, r6			@ r0 = the random number
	add	r0, r1
	str	r0, [r7]

	pop	{r4-r6, lr}
	bx	lr