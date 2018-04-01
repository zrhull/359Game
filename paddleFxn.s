.section .text
.include "constants.s"
.global	PaddleCollision
PaddleCollision:			@ Collisions with the paddle, checks both sides and the top
	push	{r4-r10, lr}

	ldr	r0, =paddle
	ldr	r1, [r0]			@ X origin of paddle (Top left x  check pixel)
	ldr	r2, [r0, #4]
	ldr	r3, [r0, #8]			@ Length of paddle
	ldr	r4, =powerUp1Color		@@@@@@@ Have not put the powerup colors into memory yet
	ldr	r5, =powerUp2Color
	ldr	r6, =ballColor
	sub	r2, #2
	
	add	r3, r3, r1
	mov	r9, r2				@ save Y
	mov	r7, r1				@ save X
	add	r8, r2, #15			@ set Y min
LoopLeftSide:				@ Check left side of paddle (Bottom/ 6 up/ 12 up)
	mov	r0, r7				@ X and Y as parameters
	mov	r1, r8
	@@bl	getPixelColor
	cmp	r0, r4
	orreq	r10, #4				@ PowerUp1 collected
	cmp	r0, r5
	orreq	r10, #2				@ PowerUp2 collected
	cmp	r0, r6
	orreq	r10, #1				@ Ball collision
	sub	r8, #6				@ Increment Y check pixel	
	cmp	r8, r9				@ Compare pixel with height
	bge	LoopLeftSide	

LoopTop:				@ Checks collisions with the top of the paddle
	mov	r0, r7			@ (Every 6 pixels along the top)
	mov	r1, r8				@ X and Y as parameters
	@@bl	getPixelColor			@ Get the color at pixel (x, y)
	cmp	r0, r4
	orreq	r10, #4				@ PowerUp1 collected
	cmp	r0, r5
	orreq	r10, #2				@ PowerUp2 collected
	cmp	r0, r6
	orreq	r10, #1				@ Ball collision
	add	r7, #7				@ Increment X check pixel
	cmp	r7, r3				@ Compare pixel with length
	blt	LoopTop

	add	r8, r9, #15			@ Max Y for the loop
LoopRightSide:				@ Check collisions with the right side
	mov	r0, r3			@ (Top right pixel and 6 pixels down)
	mov	r1, r9				@ Give x and y as parameters
	@@bl	getPixelColor
	cmp	r0, r4
	orreq	r10, #4				@ PowerUp1 collected
	cmp	r0, r5
	orreq	r10, #2				@ Powerup2 collected
	cmp	r0, r6
	orreq	r10, #1				@ Ball collision
	add	r9, #6				@ Increment Y offset
	cmp	r7, r3				@ Compare pixel with length
	blt	LoopRightSide

	mov	r0, r10				@ Return collisions found

	pop	{r4-r10, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global	PaddleUpdate
PaddleUpdate:				@ Updates the paddles new value
	@ r0 = Input type
	push	{lr}

	ldr	r1, =paddle	@State
	ldr	r2, [r1]
	cmp	r0, #RIGHT
	addeq	r2, #3
	cmp	r0, #LEFT
	subeq	r2, #3
	cmp	r0, #ARIGHT
	addeq	r2, #6
	cmp	r0, #ALEFT
	subeq	r2, #6
	cmp	r2, #PADDLEMIN
	ble	pDone
	cmp	r2, #PADDLEMAX
	bge	pDone
	str	r2, [r1]
pDone:
	pop	{lr}
	bx	lr