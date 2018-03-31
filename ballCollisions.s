

@new sub
ballPositionUpdate:
	push	{r4-r9, lr}	

	ldr	r5, =angle
	ldr	r6, [r5]		@r6 = 45
	ldr	r5, =horizDirection
	ldr	r7, [r5]		@r7 = 1
	ldr	r5, =vertDirection
	ldr	r8, [r5]		@r8 = 1

	if r8 == 1 and r7 == 1

	cmp	r8, #1
	bne	upLeft
	cmp	r7, #1
	bne	upLeft

	ldr	r0, =TR

	bl	checkCollisions

	ldr	r5, =horizDirection
	ldr	r4, [r5]
	cmp	r4, r7
	bne	finish

	ldr	r5, =vertDirection
	ldr	r4, [r5]
	cmp	r4, r8
	bne	finish

	ldr	r0, =TL

	bl	checkCollisions

	ldr	r5, =vertDirection
	ldr	r4, [r5]
	cmp	r4, r8
	bne	finish

	ldr	r0, =BR

	bl	checkCollisions

	b	finish

upLeft:	
	cmp	r8, #1
	bne	downRight
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
	cmp	r8, #0
	bne	downLeft
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
	ldr	r9, =ballCoord
	str	r0, [r9]
	str	r1, [r9, #4]

	pop	{r4-r9, pc}	

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

	mov r10, r0
	ldr	r4, [r10]		@ current x
	ldr	r5, [r10, #4]		@ current y

	ldr	r1, =ballCoord
	ldr	r6, [r1]
	ldr	r7, [r1, #4]

	ldr	r2, =angle
	ldr	r1, [r2]

	ldr	r2, =horizDirection
	ldr	r8, [r2]

	ldr	r2, =vertDirection
	ldr	r9, [r2]

	cmp	r8, #1			@check if horizonontal direction is 1 (right)
	bne	left			@if not, move to left
	add	r11, r4, #1		@increment x coordinate of the testing pixel by 1
	add	r6, r6, #1		@increment the temporary ball x coordinate by 1

	b	angleTest		

left:					@horizontal direction is 0 (left)
	sub	r11, r4, #1		@decrement x coordinate of the testing pixel by 1
	sub	r6, r6, #1		@decrement the temporary ball x coordinate by 1

angleTest:
	cmp	r1, #45			@check the angle the ball is travelling
	bne	angle60			@if angle != 45 move to angle60

	cmp	r9, #1			@check the vertical direction of ball travelling at 45 degrees
	bne	down45			@if vertical direction is 1 (up) proceed

	add	r12, r5, #1		@increment y coordinate of the testing pixel by 1
	add	r7, r7, #1		@increment the temporary ball y coordinate by 1
	b	angle60			

down45:
	sub	r12, r5, #1		@decrement y coordinate of the testing pixel by 1
	sub	r7, r7, #1		@decrement the temporary ball y coordinate by 1

angle60:
	cmp	r9, #1			@check the vertical direction of ball travelling at 60 degrees
	bne	down60			@if vertical direction is 1 (up) proceed
	add	r12, r5, #2		@increment y coordinate of the testing pixel by 2
	add	r7, r7, #2		@increment the temporary ball y coordinate by 2
	
	b	wallTest

down60:
	sub	r12, r5, #2		@decrement y coordinate of the testing pixel by 2
	sub	r7, r7, #2		@decrement the temporary ball y coordinate by 2

wallTest:
	cmp	r11, #640		@check if the next pixel of testing pixel exceeds right boundary
	bge	wallBody		@if so, proceed with right wall collision processing

leftWall:
	cmp	r11, #159
	ble wallBody

checkBrickX:
	mov r0, r11
	mov r1, r12
	bl  getPixelColour

	ldr r2, =yellow
	ldr r1, [r2]

	cmp	r0, r1
	bne ceilingBegin
	
wallBody:
	ldr	r2, [r10, #8]		@load the testing pixel previous x coordinate
	mov	r11, r2			@next x coordinate of testing pixel is set to its previous coordinate

	ldr	r2, [r10, #12]		@load the testing pixel previous y coordinate
	sub	r2, r5, r2		@current testing pixel y - previous y
	add	r12, r5, r2		@testing pixel next y = current y + (current y - prev y) (flipped over the x-axis)

	eor	r8, #1
	ldr	r2, =horizDirection
	str r8, [r2]

	cmp	r12, #144		
	blt	checkBrick
	
innerBody:
	mov	r11, r4
	mov	r12, r5
	eor	r9, #1
	ldr	r2, =vertDirection
	str	r9, [r2]
	
	b	ceilingBegin

checkBrickY:
	mov r0, r11
	mov r1, r12
	bl  getPixelColour

	ldr r2, =yellow
	ldr r1, [r2]
	cmp	r0, r1
	beq	innerBody

	ldr r2, =orange
	ldr r1, [r2]
	cmp	r0, r1
	beq	innerBody

	ldr r2, =red
	ldr r1, [r2]
	cmp	r0, r1
	beq	innerBody


ceilingBegin:
	ldr	r2, =angle
	ldr r1, [r2]
	b   ceilingTest

angleChange
	add r12, r5, #1
	mov r1, #45

ceilingTest:
	cmp	r12, #144	
	bge angleTest	

angleTest:
	cmp	r1, #60
	beq angleChange
	b   ceilingBody

checkBrick:
	mov r0, r11
	mov r1, r12
	bl  getPixelColour

	ldr r2, =yellow
	ldr r1, [r2]
	cmp	r0, r1
	beq	ceilingBody

	ldr r2, =orange
	ldr r1, [r2]
	cmp	r0, r1
	beq	ceilingBody

	ldr r2, =red
	ldr r1, [r2]
	cmp	r0, r1
	bne	endCheckCollisions

ceilingBody:
	ldr	r2, [r10, #12]		@load the testing pixel previous y coordinate
	mov	r12, r2			@next y coordinate of testing pixel is set to its previous coordinate

	ldr	r2, [r10, #8]		@load the testing pixel previous x coordinate
	sub	r2, r4, r2		@current testing pixel x - previous x
	add	r12, r5, r2		@testing pixel next y = current y + (current y - prev y) (flipped over the x-axis)

	eor	r9, #1
	ldr	r2, =vertDirection
	str r9, [r2]	

endCheckCollisions:
	str r4, [r10, #8]
	str r5, [r10, #12]

	mov r0, r11
	mov r1, r12

	pop {r4-r12, pc}



	.section	.data

ballDimen:
		.int		8
		.int		8

prevBallCoord:
		.int		0
		.int		0

ballCoord:
		.int		392
		.int		788

angle:		.int		45

horizDirection:	.int		0x1

vertDirection:	.int		0x1

TL:		
		.int		392
		.int		788
		.int		0
		.int		0

TR:		
		.int		399
		.int		788
		.int		0
		.int		0

BL:		
		.int		392
		.int		781
		.int		0
		.int		0

BR:		
		.int		399
		.int		781
		.int		0
		.int		0