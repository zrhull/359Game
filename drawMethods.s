

@ Code section
.section .text
.include "constants.s"
.global setup
setup:
	push	{r4-r11, lr}
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl		initFbInfo

	mov	r5, #125		@ Start of game boarder for Y
	mov	r7, #0			@ Y loop counter
BackgroundStartY:
	mov	r3, #0			@ Reset X counter
	mov	r4, #120		@ Reset X offset
BackgroundStart:
	ldr	r2, =background
	mov	r0, r4			@ Give picture location X and Y coords as parameters
	mov	r1, r5
	cmp	r3, #14			@ Max X
	bge	doneRow
	bl	drawHardTile
	add	r4, #40			@ Add 40 to X offset
	add	r3, #1			@ Increment X loop counter
	b	BackgroundStart
doneRow:
	add	r5, #25			@ Increment Y offset
	add	r7, #1			@ increment Y loop counter and loop again if needed
	cmp	r7, #28
	blt	BackgroundStartY

	mov	r6, #0			@ map brick offset
	mov	r9, #125		@ y initial offset
	mov	r11, #0			@ x # of bricks
	ldr	r4, =map
yTileLoop:
	mov	r8, #120		@ x initail offset
	mov	r11, #0			@ X loop counter
TileLoop:
	cmp	r11, #14		@ max X loops
	bge	bot
	mov	r0, r8			@ Give X and Y offsets as parameters
	mov	r1, r9
	ldr	r10, [r4], #4		@ Load memory value on map
	cmp	r10, #9			@ #9 is right hand wall peice
stop:
	ldreq	r2, =wallRight
	bleq	drawHardTile		@ Draw the wall peice
	cmp	r10, #8			@ #8 is right wall corner
	ldreq	r2, =wallRightCorner
	bleq	drawHardTile
	cmp	r10, #7			@ #7 is the ceiling
	ldreq	r2, =ceiling
	bleq	drawHardTile
	cmp	r10, #6			@ #6 is the left wall corner
	ldreq	r2, =wallLeftCorner
	bleq	drawHardTile
	cmp	r10, #5			@ #5 is the left wall
	ldreq	r2, =wallLeft
	bleq	drawHardTile
	cmp	r10, #3			@ #3 is red color
	ldreq	r2, =red
	ldreq	r2, [r2]
	beq	draw
	cmp	r10, #2			@ #2 is orange color
	ldreq	r2, =orange
	ldreq	r2, [r2]
	beq	draw
	cmp	r10, #1			@ #1 is yellow color
	ldreq	r2, =yellow
	ldreq	r2, [r2]
draw:
	mov	r0, r8			@ Reset x and Y offsets
	mov	r1, r9
	cmp	r10, #4			@ Draw a tile if the map value is less than 4
	bllt	drawTile	

	add	r8, #40			@ Increment X offset
	add	r11, #1			@ x brick counter increment
	b	TileLoop
bot:
	add	r9, #25			@ Increment Y offset
	mov	r12, #825
	cmp	r9, r12			@ Max Y value
	bge	ScoreAndLives
	b	yTileLoop
ScoreAndLives:
	ldr	r0, =zero
	ldr	r1, =numberSize
	ldr	r2, =digitThree
	bl	drawImage		@ Draw first zero
	ldr	r0, =zero
	ldr	r1, =numberSize
	ldr	r2, =digitTwo
	bl	drawImage		@ Draw second zero
	ldr	r0, =zero
	ldr	r1, =numberSize
	ldr	r2, =digitOne
	bl	drawImage		@ Draw third zero
	ldr	r2, =livesPos
	ldr	r1, =numberSize
	ldr	r0, =three
	bl	drawImage		@ Draw lives

	pop	{r4-r11, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Draw Image
@ r0 - address
@ r1 - address of wh
@ r2 - address of xy
.global drawImage
drawImage:
	push	{r4-r10, lr}
	
	mov	r4, r0			@@ address of image
	mov	r5, r1			@@ address of width and height, h offset by 4
	mov 	r6, r2			@@ address of x and y coord, y offset by 4
	
	mov	r7, #0			@@ pixel's drawn
	mov 	r8, #0			@@ column
	mov	r9, #0			@@ row
	
	ldr	r0, [r5]		@@ load width
	ldr	r1, [r5, #4]		@@ load height
	mul	r10, r1, r0		@@ total number of pixels to be drawn
	b	checkSize		@@ Branch to check if all pixels are drawn

drawLoop:
	ldr	r0, [r6]		@@ x
	ldr	r1, [r6, #4]		@@ y
	
	add	r0, r8			@@ column
	add	r1, r9			@@ row
	ldr	r2, [r4, r7, lsl #2]	@@ load from image address, pixel number,
					@@ shifted by 2
	bl	DrawPixel		@@ draw specified pixel
	
	add	r7, #1			@@ increment pixels drawn
	add	r8, #1			@@ increment coloum
	ldr	r0, [r5]		@@ load width of image
	cmp	r8, r0			@@ if width is less than col, move on
	blt	drawLoop
	
	mov	r8, #0			@@ reset col tracker
	add	r9, #1			@@ increment row by 1

	ldr	r0, [r5, #4]		@@ get height of image
	cmp	r9, r0			@@ if row is less than height, draw loop again
	blt	drawLoop

checkSize:
	cmp	r7, r10			@@ Compares pixels drawn to total pixels
	blt	drawLoop
	pop	{r4-r10, lr}
	bx	lr	

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour

DrawPixel:
	push	{r1, r3-r6}
	offset	.req	r4
	ldr	r5, =frameBufferInfo
	ldr	r6, =magenta		@ Invalid constant error here
	ldr	r6, [r6]
	cmp	r2, r6
	beq	dontDraw		@ If its this color dont draw it
					@ offset = (y * width) + x
	
	ldr	r3, [r5, #4]		@ r3 = width
	mul	r1, r3
	add	offset,	r0, r1
	
					@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl	offset, #2
					@ store the colour (word) at frame buffer pointer + offset
	ldr	r1, [r5]		@ r0 = frame buffer pointer
	str	r2, [r1, offset]
dontDraw:
	pop	{r1, r3-r6}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global	drawPadle
drawPadle:				@ This function is used to draw/ update the paddle
	@ r0 = paddle image
	push	{r4-r9, lr}

	ldr	r3, =paddle
	ldr	r4, [r3]		@ Load the (x, y) position of the paddle
	ldr	r6, [r3, #4]
	ldr	r8, [r3, #8]		@ Paddle length

	cmp	r4, #160		@ Cannot go past the left boarder
	ble	doneYPaddle
	mov	r3, #560		@ Cannot go past the right boarder
	cmp	r4, r3
	bge	doneYPaddle

	mov	r7, r0			@ Move image location to r7
	mov	r1, r6			@ Y offset
	add	r5, r1, #15		@ Y loop counter maximum
YLoopPaddle:
	mov	r0, r4			@ Reset X offset
	mov	r6, #0			@ Reset X counter
XLoopPaddle:
	cmp	r6, r8			@ Length of paddle
	bge	doneXPaddle
	ldr	r2, [r7], #4		@ Load pixel color from memory
	bl	DrawPixel
	add	r6, #1			@ Increment X offset and counter
	add	r0, #1
	b	XLoopPaddle
doneXPaddle:
	add	r1, #1			@ Increment Y offset and loop 
	cmp	r1, r5
	blt	YLoopPaddle
doneYPaddle:				@ Finished paddle

	pop	{r4-r9, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global	drawTile
drawTile:				@ Draws a tile with black lines around it.
	@ r0 = given x offset
	@ r1 = given y offset
	@ r2 = given color
	push	{r4-r6, lr}
	mov	r3, r0				@ Save values given for comparing.
	mov	r5, r1
	mov	r6, r2
YBlkLoop:					@ Start of Y loop for brick.
	mov	r0, r3				@ Reset X offset.
xBlkLoop:
	sub	r4, r0, r3			@ Compare original X with updated X
	cmp	r4, #40				@ and if 40 pixels have been printed
	bge	done7				@ end the X loop.
	bl	DrawPixel
	add	r0, #1				@ Increment X offset.
	b	xBlkLoop
done7:
	add	r1, #1				@ Icrement Y offset.
	sub	r4, r1, r5			@ Compare Y offset, if Y has looped
	cmp	r4, #25				@ 25 times the brick is complete.
	bge	done8
	b	YBlkLoop
done8:						@ Start of black lines on top and bottom
	mov	r2, #0x00000000			@ of the brick.
	mov	r1, r5				@ Reset Y offset.
	add	r5, #24				@ New Y end value.
ringY:
	cmp	r1, r5				@ Compare if Y has looped twice.
	bgt	sides
	mov	r0, r3				@ Reset X offset.
ringX:
	sub	r4, r0, r3			@ Compare original X with updated X
	cmp	r4, #40				@ and if 40 pixels have been printed
	bge	done9				@ end the X loop.
	bl	DrawPixel
	add	r0, #1				@ Increment X offset.
	b	ringX
done9:
	add	r1, #24				@ Increment Y offset.
	b	ringY
sides:
	sub	r5, #24				@ Reset Y original value.
	mov	r1, r5				@ Set Y offset.
	mov	r0, r3				@ Reset X offset.
	add	r3, #39				@ New X end value.
ringSideY:
	cmp	r0, r3				@ Compare if X has looped twice.
	bgt	end
	mov	r1, r5				@ Reset Y offset.
ringSideX:
	sub	r4, r1, r5			@ Compare original Y with updated Y
	cmp	r4, #25				@ and if 25 pixels have been printed
	bge	done10				@ end the Y loop.
	bl	DrawPixel
	add	r1, #1				@ Increment Y offset.
	b	ringSideX
done10:
	add	r0, #39				@ Increment X offset.
	b	ringSideY
end:

	pop	{r4-r6, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global	drawHardTile
drawHardTile:				@ This function is used to draw a tile with a data stored image
	@ r0 = x coord
	@ r1 = y coord
	@ r2 = tile location
	push	{r4-r7, lr}

	mov	r7, r2				@ Store given coords and mov memery location
	mov	r4, r0
	add	r5, r1, #25			@ Y maximum depth
YBackLoop:
	mov	r0, r4				@ Reset X offset
	mov	r6, #0				@ Reset X counter
XBackLoop:
	cmp	r6, #40				@ Brick length max
	bge	doneX
	ldr	r2, [r7], #4			@ Load pixel color from memory
	bl	DrawPixel
	add	r6, #1				@ Increment X offset and counter
	add	r0, #1
	b	XBackLoop
doneX:
	add	r1, #1				@ Increment Y offset loop if needed
	cmp	r1, r5
	blt	YBackLoop
doneY:
	pop	{r4-r7, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global	drawBall
drawBall:
	push	{r4, lr}

	ldr	r0, =ball
	ldr	r1, =ballDimen
	ldr	r2, =ballCoord
	bl	drawImage

	pop	{r4, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global	DrawBackground			@ Draws the background over the area of the
DrawBackground:				@ given object
	@ r0 = location of objects coords
	@ r1 = location of objects dimensons
	push	{r4-r12, lr}
	
	ldr	r3, [r1, #4]			@ Height of object
	ldr	r2, [r1]			@ Width of object
	ldr	r1, [r0, #4]			@ Y coord of object
	ldr	r0, [r0]			@ X coord of object
	mov	r4, #40
	mov	r11, #25
	sdiv	r5, r0, r4		
	mul	r5, r4				@ X offset of background
	sdiv	r6, r1, r11
	mul	r6, r11				@ Y offset of background

	sdiv	r8, r2, r4
	add	r8, #1				@ Get number of background bricks in length
	sdiv	r3, r11
	add	r3, #1				@ Get # of background bricks in height
	mul	r3, r11
	add	r3, r6				@ Max Y pixel value (For loop counter)

	ldr	r9, =map
YLoopReDrawBack:
	mov	r7, #0				@ x loop counter
	mov	r12, r5 
XLoopReDrawBack:
	sdiv	r10, r5, r4			@ # of bricks from the screen wall
	sub	r10, #3				@ Element # in the row of the map
	sdiv	r2, r6, r11			@ # of bricks from the screen ceiling
	sub	r2, #5				@ Row #
	mov	r1, #14
	mul	r2, r1				@ The first element of the row
	mov	r1, #4
	add	r10, r2				@ The element in the map
	mul	r10, r1				@ The offset of the element in the map
	ldr	r10, [r9, r10]			@ Load value of map position
	
breakT:	cmp	r10, #10			@ Determin the tile to be drawn
	ldreq	r2, =background
	cmp	r10, #3
	ldreq	r2, =red
	ldreq	r2, [r2]
	cmp	r10, #2
	ldreq	r2, =orange
	ldreq	r2, [r2]
	cmp	r10, #1
	ldreq	r2, =yellow
	ldreq	r2, [r2]

	mov	r1, r6				@ Y offset for a parameter
	mov	r0, r12
	cmp	r7, r8				@ Compare X loop counter to # of bricks to draw
	bge	doneXLoopBack
	cmp	r12, #640			@ Dont Draw over the boarder
	bge	doneXLoopBack

	cmp	r10, #4				@ Compare the value in the map
	blgt	drawHardTile			@ Draw picture
	bllt	drawTile			@ Draw color
	add	r7, #1				@ Increment X loop counter
	add	r12, #40			@ Increment X offset
	b	XLoopReDrawBack
doneXLoopBack:
	add	r6, #25				@ Increment Y offset
	cmp	r6, r3				@ Compare number of bricks to draw down
	ble	YLoopReDrawBack
stopDrawing:


	pop	{r4-r12, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

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

	ldr	r1, =paddle
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
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global powerUpdate
powerUpdate:			@ Update location of powerUp if either is in
	push	{r4, lr}	@ the moving state (state: 0 = waiting, 1 = moving,
	ldr	r0, =powerUp1	@ and 2 = dead)
	ldr	r3, [r0, #8]
	cmp	r3, #1
	bne	nextPower

	ldr	r1, [r0, #4]
	add	r1, #2
	mov	r2, #802
	cmp	r1, r2			@ If at the bottom of the game powerup
	movge	r1, #2			@ will die
	strge	r1, [r0, #8]
	strlt	r1, [r0, #4]		@ Else increment y offset by 2
	
nextPower:
	ldr	r0, =powerUp2
	ldr	r3, [r0, #8]
	cmp	r3, #1
	bne	powerDone
	ldr	r1, [r0, #4]
	add	r1, #2
	cmp	r1, r2
	movge	r1, #2
	strge	r1, [r0, #8]
	strlt	r1, [r0, #4]

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

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global drawScore
drawScore:
	push	{r4, lr}

	ldr	r0, =map
	add	r0, #228		@ First position in the map (May be wrong)
	mov	r1, #0			@ # of points left counter
	mov	r2, #0			@ X loop counter
loopCount:
	ldr	r3, [r0], #4		@ load value and post increment
	add	r1, r1, r3		@ Total points left on board
	add	r2, #1			@ increment counter
	cmp	r2, #12			@ Get all 12 numbers in a row
	beq	loopCount
	add	r0, #8			@ Add 8 to the offset to skip 2 #'rs in the map
	mov	r2, #0			@ Reset X loop counter
	cmp	r0, #556		@ Last element to add
	ble	loopCount
	sub	r4, r1			@ r4 = score, /# of times bricks have been hit

	@@ Need to do score to printing numbers @@
	@@ Positions of all digits are in data section below @@
	@@ Also need to update lives @@
	@@ I put a section in setup at the top of this class that draws initail score and lives @@

	pop	{r4, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Data section
.section .data

.align
.global	paddle			@ Coordinates of the paddle/ length
paddle:
	.int	360
	.int	785

.global	paddleDimen		@ Dimensions of the ball
paddleDimen:
	.int	80
	.int	15

.global	ballCoord
ballCoord:
	.int	396		@ Coordinates of ball
	.int	777

.global	ballDimen
ballDimen:
	.int	8		@ Dimensions on the ball
	.int	8

.global	powerUp1
powerUp1:
	.int	0		@ Coordinates of powerUp1
	.int	0
	.int	0		@ State of powerup

.global	powerUpDimen
powerUpDimen:
	.int	40
	.int	25

.global	powerUp2
powerUp2:
	.int	0		@ Coordinates of powerUp2
	.int	0
	.int	0		@ State of powerup

.global	digitOne		@ Position of first digit
digitOne:
	.int	350
	.int	82

.global	digitTwo		@ Position of second digit
digitTwo:
	.int	388
	.int	82

.global	digitThree		@ Position third digit
digitThree:
	.int	426
	.int	82

.global livesPos		@ Position of lives
livesPos:
	.int	640
	.int	82
	
.global	numberSize		@ Size of all number pictures
numberSize:
	.int	39
	.int	50

magenta:			@ Transparent color
	.int	0xFFF05EF0

red:
	.int	0xFFFF0000

orange:
	.int	0xFFFF8B00

yellow:
	.int	0xFFFFEE00

powerUp1Color:
	.int	0xFF15E620

powerUp2Color:
	.int	0xFFa910eb

ballColor:
	.int	0xFF99D9Ea


.global	map
map:
	.int	6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 9
	.int	5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 9
	.int	5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 9
	.int	5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 9
	.int	5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9
	.int	5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9
	.int	5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9


