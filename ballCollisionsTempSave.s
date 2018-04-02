.section .text
.include "constants.s"
@new sub
.global ballPositionUpdate
ballPositionUpdate:
	push	{r4-r11, lr}	

	ldr	r2, =ballCoord
	ldr	r7, [r2]		@r7 = 396
	ldr	r8, [r2, #4]		@r8 = 777
	str	r7, [r2, #8]
	str	r8, [r2, #12]

	ldr	r3, =TL
	str	r7, [r3, #8]		@TL prevX = 396
	str	r8, [r3, #12]		@TL prevY = 777

	ldr	r3, =TR
	add	r7, r7, #7		@r7 = 403
	str	r7, [r3, #8]		@TR prevX = 403
	str 	r8, [r3, #12]		@TR prevY = 777

	ldr	r3, =BR
	add	r8, r8, #7		@r8 = 784
	str	r7, [r3, #8]		@BR prevX = 403
	str 	r8, [r3, #12]		@BL prevY = 784

	ldr	r3, =BL
	sub	r7, r7, #7		@r7 = 396
	str	r7, [r3, #8]		@BL prevX = 396
	str 	r8, [r3, #12]		@BL prevY = 784


	ldr	r5, =angle
	ldr	r6, [r5]		@angle (r6) = 45
	ldr	r5, =horizDirection
	ldr	r7, [r5]		@horizontal direction (r7) = 1 (right)
	ldr	r5, =vertDirection
	ldr	r8, [r5]		@vertical direction (r8) = 1 (up)

	cmp	r8, #1			@if vertical direction is not up, branch to downRight
	bne	downRight
	cmp	r7, #1			@if horizontal direction is not right, branch to upLeft
	bne	upLeft

	ldr	r0, =TR			@run checkCollisions of the top right pixel of ball's hitbox

	bl	checkCollisions 

	ldr	r5, =horizDirection	@load horizontal direction address into r5
	ldr	r4, [r5]		@load value of horizontal direction into r4
	cmp	r4, r7			@if the horizontal direction (r4) has changed, branch to the end
	bne	finish

	ldr	r5, =vertDirection	@load vertical direction address into r5
	ldr	r4, [r5]		@load value of vertical direction into r4
	cmp	r4, r8			@if the vertical direction (r4) has changed, branch to the end
	bne	finish

	ldr	r0, =TL			@run checkCollisions of the top left pixel of ball's hitbox

	bl	checkCollisions

	ldr	r5, =vertDirection	@load vertical direction address into r5
	ldr	r4, [r5]		@load value of vertical direction into r4
	cmp	r4, r8			@if the vertical direction (r4) has changed, branch to the end
	bne	finish

	ldr	r0, =BR			@run checkCollisions of the bottom right pixel of ball's hitbox

	bl	checkCollisions		

	b	finish			@branch to the end

upLeft:	
	cmp	r7, #0
	bne	downRight

	ldr	r0, =TL

	bl	checkCollisions

	ldr	r5, =horizDirection
	ldr	r4, [r5]
	cmp	r4, r7
	bne	finish

	ldr	r5, =vertDirection
	ldr	r4, [r5]
	cmp	r4, r8
	bne	finish

	ldr	r0, =TR

	bl	checkCollisions

	ldr	r5, =vertDirection
	ldr	r4, [r5]
	cmp	r4, r8
	bne	finish

	ldr	r0, =BL

	bl	checkCollisions

	b	finish

downRight:	
	cmp	r7, #1
	bne	downLeft

	ldr	r0, =BR

	bl	checkCollisions

	ldr	r5, =horizDirection
	ldr	r4, [r5]
	cmp	r4, r7
	bne	finish

	ldr	r5, =vertDirection
	ldr	r4, [r5]
	cmp	r4, r8
	bne	finish

	ldr	r0, =BL

	bl	checkCollisions

	ldr	r5, =vertDirection
	ldr	r4, [r5]
	cmp	r4, r8
	bne	finish

	ldr	r0, =TR

	bl	checkCollisions

	b	finish

downLeft:
	ldr	r0, =BL

	bl	checkCollisions

	ldr	r5, =horizDirection
	ldr	r4, [r5]
	cmp	r4, r7
	bne	finish

	ldr	r5, =vertDirection
	ldr	r4, [r5]
	cmp	r4, r8
	bne	finish

	ldr	r0, =BR

	bl	checkCollisions

	ldr	r5, =vertDirection
	ldr	r4, [r5]
	cmp	r4, r8
	bne	finish

	ldr	r0, =TL

	bl	checkCollisions

	b	finish

finish:
	ldr	r2, =ballCoord		@load the ballCoord address into r2
	str	r0, [r2]		@take the result from checkCollisions and store it into the memory location of the ball's x-coordinate
	str	r1, [r2, #4]		@take the result from checkCollisions and store it into the memory location of the ball's y-coordinate

	ldr	r3, =TL			@load the address of the top left pixel of the ball
	str	r0, [r3]		@take the result from checkCollisions and store it into the memory location of the ball's top left x-coordinate
	str	r1, [r3, #4]		@take the result from checkCollisions and store it into the memory location of the ball's top left y-coordinate

	ldr	r3, =TR			@load the address of the top right pixel of the ball
	add	r0, r0, #7		@take the result from checkCollisions and add 7 to the x-coordinate to get the position of the top right pixel
	str	r0, [r3]		@take the result from previous instruction and store it into the memory location of the ball's top right x-coordinate
	str 	r1, [r3, #4]		@take the result from checkCollisions and store it into the memory location of the ball's top right y-coordinate

	ldr	r3, =BR			@load the address of the bottom right pixel of the ball
	add	r1, r1, #7		@take the result from checkCollisions and add 7 to the y-coordinate to get the position of the bottom right pixel
	str	r0, [r3]		@take the result from checkCollisions and store it into the memory location of the ball's bottom right x-coordinate
	str 	r1, [r3, #4]		@take the result from previous instruction and store it into the memory location of the ball's bottom right y-coordinate

	ldr	r3, =BL			@load the address of the bottom left pixel of the ball
	sub	r0, r0, #7		@take the result from checkCollisions and subtract 7 from the x-coordinate calculated above to get the position of the bottom left pixel
	str	r0, [r3]		@take the result now in r0 and store it into the memory location of the ball's bottom left x-coordinate
	str 	r1, [r3, #4]		@take the result now in r1 and store it into the memory location of the ball's bottom left y-coordinate

	pop	{r4-r11, lr}
	bx	lr	

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ new sub
checkCollisions:
	@ parameters and their starting values
	@ r0 = brick colour
	@r1 = angle
	@r4 = currentPixelX
	@r5 = currentPixelY
	@r6 = ballCoordX
	@r7 = ballCoordY
	@r8 = horizDirection
	@r9 = vertDirection
	@r10 = address of pixel being tested
	@r11 = nextPixelX
	@r12 = nextPixelY
	@returns temporary registers holding the x and y of the upper left pixel of the ball image r0, r1

	push	{r4-r12, lr}

	mov 	r10, r0			@address of the pixel being tested
	ldr	r4, [r10]		@ current x of test pixel
	ldr	r5, [r10, #4]		@ current y of test pixel

	ldr	r1, =ballCoord		@r1 = address of the ball coordinates
	ldr	r6, [r1]		@r6 = the current x-coordinate of the ball
	ldr	r7, [r1, #4]		@r7 = the current y-coordinate of the ball

	ldr	r2, =angle		@r2 = address of angle
	ldr	r1, [r2]		@r1 = angle value

	ldr	r2, =horizDirection	@r2 = address of horizontal direction
	ldr	r8, [r2]		@r8 = value of horizontal direction

	ldr	r2, =vertDirection	@r2 = address of vertical direction
	ldr	r9, [r2]		@r9 = value of vertical direction

	cmp	r9, #1			@check if vertical direction is 1 (up)
	bne	down			@if not, move to down
	sub	r12, r5, #3		@decrement y coordinate of the testing pixel by 2
	sub	r7, r7, #3		@decrement the temporary ball y coordinate by 2

	b	angleTest		

down:					@vertical direction is 0 (down)
	add	r12, r5, #3		@increment y coordinate of the testing pixel by 2
	add	r7, r7, #3		@increment the temporary ball y coordinate by 2

angleTest:
	cmp	r1, #45			@check the angle the ball is travelling
	bne	angle60			@if angle != 45 move to angle60

	cmp	r8, #1			@check the horizontal direction of ball travelling at 45 degrees
	bne	left45			@if horizontal direction is 1 (right) proceed

	add	r11, r4, #3		@increment x coordinate of the testing pixel by 2
	add	r6, r6, #3		@increment the temporary ball x coordinate by 2
	b	wallTest			

left45:
	sub	r11, r4, #3		@decrement x coordinate of the testing pixel by 2
	sub	r6, r6, #3		@decrement the temporary ball x coordinate by 2
	b	wallTest

angle60:
	cmp	r8, #1			@check the horizontal direction of ball travelling at 60 degrees
	bne	left60			@if horizontal direction is 1 (up) proceed
	add	r11, r4, #2		@increment x coordinate of the testing pixel by 1
	add	r6, r6, #2		@increment the temporary ball x coordinate by 1
	
	b	wallTest

left60:
	sub	r11, r4, #2		@decrement x coordinate of the testing pixel by 1
	sub	r6, r6, #2		@decrement the temporary ball x coordinate by 1

wallTest:
	cmp	r11, #640		@check if the next pixel of testing pixel exceeds right boundary
	bge	wallBody		@if so, proceed with right wall collision processing, otherwise test for the left wall

leftWall:
	cmp	r11, #159		@check if the next pixel of testing pixel exceeds left boundary
	ble 	wallBody		@if so, proceed with right wall collision processing, otherwise test for a brick collision on x-axis

checkBrickX:
	mov 	r0, r11			@store the next x value of the test pixel as the x parameter for getPixelColour
	mov 	r1, r5			@store the next y value of the test pixel as the y parameter for getPixelColour
	bl  	getPixelColour		@call getPixelColour

	ldr 	r2, =yellow		@load the address of the yellow hex value into r2
	ldr 	r1, [r2]		@load the yellow hex value into r1
	cmp	r0, r1			@compare the value returned by getpixelColour (r0) to the hex value of yellow (r1)
	beq	brickHitX		@if the value is not equal, not colliding with yellow brick, move to ceiling collisions; otherwise, it will move into the wall body

@@this was added@@
	ldr 	r2, =orange		@load the address of the yellow hex value into r2
	ldr 	r1, [r2]		@load the orange hex value into r1
	cmp	r0, r1			@compare the value returned by getpixelColour (r0) to the hex value of orange (r1)
	beq	brickHitX		@if they equal, collision with orange brick on top of the ball is detected, move to inner body

	ldr 	r2, =red		@load the address of the red hex value into r2
	ldr 	r1, [r2]		@load the red hex value into r1
	cmp	r0, r1			@compare the value returned by getpixelColour (r0) to the hex value of red (r1)
	bne	ceilingTest		@if they equal, collision with red brick on top of the ball is detected, move to inner body
@@end additions@@

brickHitX:
	mov	r3, #40
	sdiv	r0, r11, r3
	mul	r4, r0, r3
	sub	r0, #3
	
	mov 	r3, #25
	sdiv	r1, r12, r3
	mul	r5, r1, r3
	sub	r1, #5

	mov	r3, #14
	mul	r1, r3

	mov	r3, #4
	add	r0, r1
	mul	r0, r3

	ldr 	r2, =map
	ldr	r3, [r2, r0]

	cmp	r3, #2
	movlt	r3, #10
	subeq	r3, #1
	cmp	r3, #3
	subeq	r3, #1

	str 	r3, [r2, r0]

	ldr	r3, =powerUp1
	ldr	r0, [r3]
	ldr	r1, [r3, #4]
	ldr	r2, [r3, #8]

	cmp	r4, r0
	cmpeq	r5, r1
	cmpeq	r2, #0
	addeq	r2, #1
	streq 	r2, [r3, #8]

	ldr	r3, =powerUp2
	ldr	r0, [r3]
	ldr	r1, [r3, #4]
	ldr	r2, [r3, #8]

	cmp	r4, r0
	cmpeq	r5, r1
	cmpeq	r2, #0
	addeq	r2, #1
	streq	r2, [r3, #8]
		
	
wallBody:
	ldr	r2, =ballCoord		@load the address of the ball coordinates into r2
	ldr	r6, [r2, #8]		@load the previous value of ball x-coordinate into r6
	ldr	r1, [r2, #12]		@load the previous value of ball y-coordinate into r1
	sub	r1, r7, r1		@r1 = (current value of ball y-coordinate - previous value of ball y-coordinate)
	add	r7, r7, r1		@r7 = current value of ball y-coordinate + (current value of ball y-coordinate - previous value of ball y-coordinate)

	ldr	r11, [r10, #8]		@load the testing pixel previous x coordinate into r11

	ldr	r2, [r10, #12]		@load the testing pixel previous y coordinate into r2
	sub	r2, r5, r2		@r2 = current testing pixel y - current testing previous y
	add	r12, r5, r2		@testing pixel next y = current y + (current y - prev y) (flipped over the x-axis)

	eor	r8, #1			@toggle the value of the horizontal direction
	ldr	r2, =horizDirection	@load the address of the horizontal direction into r2
	str 	r8, [r2]		@store the toggled value into the horizontal direction memory location

	cmp	r12, #149		@check if the next pixel y-coordinate exceeds the ceiling boundary
	bgt	checkBrickY		@if it is greater than the ceiling (that is, lower), move to check for brick collision, otherwise move to inner body
	
innerBody:
	@@@@@@@@@ MORE STUFF HERE @@@@@@@@@@@@@@

	mov	r11, r4			@set the next x-coordinate for the testing pixel to the current x-coordinate of the testing pixel
	mov	r12, r5			@set the next y-coordinate for the testing pixel to the current y-coordinate of the testing pixel
	eor	r9, #1			@toggle the value of vertical direction (r9)
	ldr	r2, =vertDirection	@load the address of vertical direction into r2
	str	r9, [r2]		@store the toggled value of the vertical direction into the vertical direction memory address
	
	b	endCheckCollisions	@move to end of subroutine, as a collision in the corner has been detected.

checkBrickY:
	mov 	r0, r11			@move the value of the next x-coordinate into the x parameter for the getPixelColour function
	mov 	r1, r12			@move the value of the next y-coordinate into the y parameter for the getPixelColour function
	bl  	getPixelColour		

	ldr 	r2, =yellow		@load the address of the yellow hex value into r2
	ldr 	r1, [r2]		@load the yellow hex value into r1
	cmp	r0, r1			@compare the value returned by getpixelColour (r0) to the hex value of yellow (r1)
	beq	innerBody		@if they equal, collision with yellow brick on top of the ball is detected, move to inner body
					@otherwise, check orange brick

	ldr 	r2, =orange		@load the address of the yellow hex value into r2
	ldr 	r1, [r2]		@load the orange hex value into r1
	cmp	r0, r1			@compare the value returned by getpixelColour (r0) to the hex value of orange (r1)
	beq	innerBody		@if they equal, collision with orange brick on top of the ball is detected, move to inner body
					@otherwise, check red brick

	ldr 	r2, =red		@load the address of the red hex value into r2
	ldr 	r1, [r2]		@load the red hex value into r1
	cmp	r0, r1			@compare the value returned by getpixelColour (r0) to the hex value of red (r1)
	beq	innerBody		@if they equal, collision with red brick on top of the ball is detected, move to inner body
	b	endCheckCollisions	@otherwise, no brick collision, move to check ceiling collision

ceilingTest:
	cmp	r12, #149		@check is the next value of the y-coordinate for testing pixel is less than the ceiling (149)
	ble	ceilingBody		@if yes, jump to the ceilingBody to perform reflection, otherwise, check for a brick collision

checkBrick:
	mov 	r0, r11			@
	mov 	r1, r12			@
	bl  	getPixelColour		@

	ldr 	r2, =yellow		@
	ldr 	r1, [r2]		@
	cmp	r0, r1			@
	beq	brickHitY		@

	ldr 	r2, =orange		@
	ldr 	r1, [r2]		@
	cmp	r0, r1			@
	beq	brickHitY		@

	ldr 	r2, =red		@
	ldr 	r1, [r2]		@
	cmp	r0, r1			@
	bne	floorTest		@

brickHitY:
	mov	r3, #40
	sdiv	r0, r11, r3
	sub	r0, #3
	
	mov 	r3, #25
	sdiv	r1, r12, r3
	sub	r1, #5

	mov	r3, #14
	mul	r1, r3

	mov	r3, #4
	add	r0, r1
	mul	r0, r3

	ldr 	r2, =map
	ldr	r3, [r2, r0]

	cmp	r3, #2
	movlt	r3, #10
	subeq	r3, #1
	cmp	r3, #3
	subeq	r3, #1

	str 	r3, [r2, r0]	

ceilingBody:
	ldr	r2, =ballCoord		@
	ldr	r1, [r2, #8]		@
	sub	r1, r6, r1		@
	add	r6, r6, r1		@
	ldr	r7, [r2, #12]		@
		
	ldr	r12, [r10, #12]		@load the testing pixel previous y coordinate
					@next x coordinate of testing pixel is set to its previous coordinate

	ldr	r2, [r10, #8]		@load the testing pixel previous x coordinate
	sub	r2, r4, r2		@current testing pixel x - previous x
	add	r11, r4, r2		@testing pixel next x = current x + (current x - prev x) (flipped over the y-axis)

	eor	r9, #1			@
	ldr	r2, =vertDirection	@
	str 	r9, [r2]		@

	b	endCheckCollisions 	

floorTest:
	ldr	r2, =vertDirection
	ldr	r9, [r2]
	cmp	r9, #0
	bne	endCheckCollisions

	ldr	r2, =tempCurrentPos
	str	r4, [r2]
	str	r5, [r2, #4]
	mov	r0, r11
	mov	r1, r12
	mov	r2, r10

	bl	floorCollision

	mov	r6, r0
	mov	r7, r1

endCheckCollisions:
	@str 	r4, [r10, #8]		@
	@str 	r5, [r10, #12]		@
	@str 	r11, [r10]		@
	@str 	r12, [r10,#4]		@
	mov 	r0, r6			@
	mov 	r1, r7			@

	pop {r4-r12, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@new sub

floorCollision:
@r0 = nextX
@r1 = nextY
@r2 = address of testing pixel

	push	{r4-r12, lr}

	mov	r11, r0
	mov	r12, r1
	mov	r6, r2

bottomTest:
	mov	r0, #823
	cmp	r12, r0			@check is the next value of the y-coordinate for testing pixel is less than the floor (824)
	bge	loseLife		@if yes, fall through to ceilingAngleTest, otherwise, check for a brick collision

checkBrickFloor:
	mov 	r0, r11			@
	mov 	r1, r12			@
	bl  	getPixelColour		@

	ldr 	r2, =yellow		@
	ldr 	r1, [r2]		@
	cmp	r0, r1			@
	beq	floorBrickHitY		@

	ldr 	r2, =orange		@
	ldr 	r1, [r2]		@
	cmp	r0, r1			@
	beq	floorBrickHitY		@

	ldr 	r2, =red		@
	ldr 	r1, [r2]		@
	cmp	r0, r1			@
	beq	floorBrickHitY		@

	ldr	r2, =innerBlue
	ldr	r1, [r2]
	cmp	r0, r1
	beq	paddle60

	ldr	r2, =outerBlue
	ldr	r1, [r2]
	cmp	r0, r1
	bne	endFloor
	b	paddle45	

floorBrickHitY:
	mov	r3, #40
	sdiv	r0, r11, r3
	sub	r0, #3
	
	mov 	r3, #25
	sdiv	r1, r12, r3
	sub	r1, #5

	mov	r3, #14
	mul	r1, r3

	mov	r3, #4
	add	r0, r1
	mul	r0, r3

	ldr 	r2, =map
	ldr	r3, [r2, r0]

	cmp	r3, #2
	movlt	r3, #10
	subge	r3, #1

	str 	r3, [r2, r0]
	b	floorBody

paddle60:
	ldr	r2, =angle
	mov	r3, #60
	str	r3, [r2]
	b	floorBody

paddle45:
	ldr	r2, =angle
	mov	r3, #45
	str	r3, [r2]
	

	ldr	r2, =paddle
	ldr	r3, [r2]
	add	r3, #30	

	ldr	r2, =ballCoord
	ldr	r5, [r2]
	add	r5, #7

	ldr	r2, =horizDirection
	mov	r4, #0
	cmp	r5, r3
	strle	r4, [r2]
	add	r4, #1
	strgt	r4, [r2]
	
floorBody:
	ldr	r2, =ballCoord		@
	ldr	r1, [r2, #8]		@
	sub	r1, r7, r1		@
	add	r7, r7, r1		@
	ldr	r8, [r2, #12]		@
		
	ldr	r12, [r6, #12]		@load the testing pixel previous y coordinate
					@next x coordinate of testing pixel is set to its previous coordinate

	@ldr	r1, =tempCurrentPos
	@ldr	r10, [r1]

	ldr	r2, [r6, #8]		@load the testing pixel previous x coordinate
	sub	r2, r10, r2		@current testing pixel x - previous x
	add	r11, r4, r2		@testing pixel next x = current x + (current x - prev x) (flipped over the y-axis)

	eor	r9, #1			@
	ldr	r2, =vertDirection	@
	str 	r9, [r2]		@

	b	endFloor

loseLife:
	ldr	r2, =gameState
	ldr	r3, [r2, #LIVESLEFT]
	sub	r3, #1
	str	r3, [r2, #LIVESLEFT]

	bl	reset

endFloor:
	mov	r0, r7
	mov	r1, r8
	pop	{r4-r12, pc}
	
	
		

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ new sub
.global getPixelColour
getPixelColour:
	@r0 = x
	@r1 = y
	@r4 = offset
	@return colour

	push		{r4-r6, lr}
	
	ldr		r5, =frameBufferInfo	@load frame buffer info address into r5
	ldr		r3, [r5, #4]		@load frame width into r3
	mul		r1, r3
	add		r4, r0, r1

	lsl		r4, #2

	ldr		r6, [r5]
	ldr		r0, [r6, r4]

	pop		{r4, r5, r6, pc}



.section	.data

.global ballDimen

tempCurrentPos:
		.int		0
		.int		0

ballDimen:
		.int		8
		.int		8

prevBallCoord:
		.int		0
		.int		0
.global ballCoord
ballCoord:
		.int		396
		.int		777
		.int		0
		.int		0

.global angle
angle:		.int		45

.global horizDirection
horizDirection:	.int		1

.global vertDirection
vertDirection:	.int		1

.global TL, TR, BL, BR
TL:		
		.int		396
		.int		777
		.int		0
		.int		0

TR:		
		.int		403
		.int		777
		.int		0
		.int		0

BL:		
		.int		396
		.int		784
		.int		0
		.int		0

BR:		
		.int		403
		.int		784
		.int		0
		.int		0


