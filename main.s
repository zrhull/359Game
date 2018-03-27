
@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl		initFbInfo
	
	mov	r6, #0			@ map brick offset
	mov	r9, #100		@ y initial offset
	mov	r11, #0			@ x # of bricks
yTileLoop:
	mov	r8, #100		@ x initail offset
	mov	r11, #0
TileLoop:
	ldr	r4, =map
	ldr	r10, [r4, r6]
	cmp	r10, #5
	moveq	r2, #0xFF00
	beq	draw
	cmp	r10, #3
	moveq	r2, #0xFF0000
	beq	draw
	cmp	r10, #2
	moveq	r2, #0xC60
	beq	draw
	cmp	r10, #1
	moveq	r2, #0xFA0
	movne	r2, #0x00000000
	
draw:
	cmp	r11, #14
	bge	bot
	mov	r0, r8
	mov	r1, r9
	bl	drawTile
	
	add	r8, #40
	add	r6, #4
	add	r11, #1			@ x brick counter increment
	b	TileLoop
bot:
	add	r9, #25
	cmp	r9, #800
	bge	bot2
	b	yTileLoop
bot2:
	mov	r0, #0
	bl	drawPadle

	bl	Driver


	@ stop
	haltLoop$:
		b	haltLoop$
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour

DrawPixel:
	push	{r1, r3, r4, r5}
	offset	.req	r4
	ldr	r5, =frameBufferInfo	

					@ offset = (y * width) + x
	
	ldr	r3, [r5, #4]		@ r3 = width
	mul	r1, r3
	add	offset,	r0, r1
	
					@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl	offset, #2
					@ store the colour (word) at frame buffer pointer + offset
	ldr	r1, [r5]		@ r0 = frame buffer pointer
	str	r2, [r1, offset]
	pop	{r1, r3, r4, r5}
	bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global	drawPadle
drawPadle:
	@ r0 = x offset
	push	{r4, r5, r6, r7, r8, lr}
	ldr	r3, =paddle
	ldr	r4, [r3]		@ Load the (x, y) position of the paddle
	ldr	r1, [r3, #4]
	mov	r6, r1
	mov	r7, r0
	add	r4, r4, r0
	mov	r2, #0x2FE0
	cmp	r4, #140		@ Cannot go past the left border
	ble	donePadle
	mov	r5, #540
	cmp	r4, r5			@ Cannot go past the right border
	bge	donePadle
	str	r4, [r3]		@ Store new location of paddle
yLoop:
	mov	r5, #0
	mov	r0, r4
xloop:
	cmp	r5, #80
	bge	done3
	bl	DrawPixel
	add	r5, #1
	add	r0, #1
	b	xloop
done3:
	add	r1, #1
	mov	r3, #780
	cmp	r1, r3
	bge	done1
	b	yLoop
done1:
	mov	r1, r6			@ Reset Y
startErase:
	cmp	r7, #0			@ Check if offset is positive or negative
	addlt	r0, r4, #80		@ If offset is + add 80 pixels to start erasing
	subgt	r0, r4, r7			@ if offset is - the offset to start erasing
	mov	r5, #0
	mov	r2, #0x00000000
xLoopErase:
	cmp	r5, r7
	beq	doneDone
	bl	DrawPixel
	cmp	r5, r7
	addgt	r5, #-1
	addlt	r5, #1
	add	r0, #1
	b	xLoopErase
doneDone:
	add	r1, #1
	mov	r3, #780
	cmp	r1, r3
	bge	donePadle
	b	startErase
donePadle:
	

	pop	{r4, r5, r6, r7, r8, lr}
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
	.int	340
	.int	765

.global	map
map:
	.int	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5
	.int	5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5
	.int	5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5
	.int	5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5
	.int	5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5
	.int	5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	.int	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5




