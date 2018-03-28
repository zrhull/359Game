
@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl		initFbInfo

	mov	r5, #120		@ Start of game boarder for Y
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
	mov	r9, #120		@ y initial offset
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
	cmp	r9, #820		@ Max Y value
	bge	bot2
	b	yTileLoop
bot2:
	mov	r0, #0			@ Draw the paddle
	bl	drawPadle

	bl	Driver			@ Initiate Driver

	@ stop
	haltLoop$:
		b	haltLoop$

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
	push	{r1, r3, r4, r5, r6}
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
	pop	{r1, r3, r4, r5, r6}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global	drawPadle
drawPadle:				@ This function is used to draw/ update the paddle
	@ r0 = x offset
	push	{r4, r5, r6, r7, r8, r9, lr}

	ldr	r3, =paddle
	ldr	r4, [r3]		@ Load the (x, y) position of the paddle
	ldr	r6, [r3, #4]
	add	r4, r0, r4		@ Save paddle offset
	str	r4, [r3]		@ Save new X value

	cmp	r4, #160		@ Cannot go past the left boarder
	ble	doneYPaddle
	mov	r5, #560		@ Cannot go past the right boarder
	cmp	r4, r5
	bge	doneYPaddle
ReDrawBackground:			@ Draw the background
	mov	r3, #770		@ Y offset for background tiles
	mov	r8, #40			@ Calculate the x coord
	sdiv	r7, r4, r8
	sub	r7, #1
	mul	r7, r8			@ Initail x coord for re-drawing background
	mov	r5, #0			@ X loop counter
reDraw:
	ldr	r2, =background		
	mov	r0, r7			@ Send background and x and y coords as parameters
	mov	r1, r3
	cmp	r0, #120		@ Do not draw the background if its actually a boarder
	ble	skip
	cmp	r0, #640
	bge	skip
	bl	drawHardTile		@ Draw background tile
skip:
	add	r5, #1			@ Increment counter
	add	r7, #40			@ Increment x offset
	cmp	r5, #5			@ If looped 3 times stop
	blt	reDraw

	mov	r1, r6			@ Time to draw the paddle/ y offset
	ldr	r7, =Paddle		
	add	r5, r1, #15		@ Y loop counter maximum
YLoopPaddle:
	mov	r0, r4			@ Reset X offset
	mov	r6, #0			@ Reset X counter
XLoopPaddle:
	cmp	r6, #80			@ Length of paddle
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

	pop	{r4, r5, r6, r7, r8, r9, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

drawTile:				@ Draws a tile with black lines around it.
	@ r0 = given x offset
	@ r1 = given y offset
	@ r2 = given color
	push	{r4, r5, r6, lr}
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

	pop	{r4, r5, r6, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

drawHardTile:				@ This function is used to draw a tile with a data stored image
	@ r0 = x coord
	@ r1 = y coord
	@ r2 = tile location
	push	{r4, r5, r6, r7, lr}

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
	pop	{r4, r5, r6, r7, lr}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Data section
.section .data

lrSave:
	.int	0x00000000

.align
.globl frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height

.global	paddle
paddle:
	.int	360
	.int	780

magenta:			@ Transparent color
	.int	0xFFF05EF0

red:
	.int	0xFFFF0000

orange:
	.int	0xFFFF8B00

yellow:
	.int	0xFFFFEE00


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

