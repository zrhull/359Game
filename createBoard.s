.section .text
@code section
.include "constants.s"

.global createBoard, eraseObjects
createBoard:
	push	{r4-r10, lr}	@@ add more if need be
	mov	r4, #BOARDW	@@ width counter
	mov	r5, #BOARDH	@@ height counter
	ldr	r6, =map	@@ map address
	mov	r7, #STARTX	
	mov	r8, #STARTY
	@@ First load tile #
	@@ 6 is left corner
	@@ 8 is right corner
	@@ 5 is left wall
	@@ 9 is rigth wall
	@@ 7 is ceiling
	@@ 10 is background  START WITH THIS

	@@ For drawImage,r0 address
	@@ r1 wh, r2 xy
xLoop1:
	ldr	r0, [r6], #4
	cmp	r0, #6
	ldreq	r0, =wallLeftCorner

	cmp	r0, #8
	ldreq	r0, =wallRightCorner

	cmp	r0, #7
	ldreq	r0, =ceiling

	cmp	r0, #5
	ldreq	r0, =wallLeft

	cmp	r0, #9
	ldreq	r0, =wallRight

	cmp	r0, #10
	ldreq	r0, =background

	cmp	r0, #1
	ldreq	r0, =yellowBrick

	cmp	r0, #2
	ldreq 	r0, =orangeBrick

	cmp	r0, #3
	ldreq 	r0, =redBrick

	ldr	r1, =wh

	ldr	r2, =xyCoord
	str	r7, [r2]
	str	r8, [r2, #4]
	bl	drawImage		
	
	add	r7, #TILEW		@@ inc X
	sub	r4, #1			@@ subtract 1 from X counter
	cmp	r4, #0
	bne	xLoop1

yLoop1:
	sub	r5, #1
	cmp	r5, #0
	beq	doneBoard
	mov	r4, #BOARDW		@@ reset x counters
	mov	r7, #STARTX
	add	r8, #TILEH
	b	xLoop1

doneBoard:
	pop	{r4-r10, lr}
	bx	lr	
	
	
@@ r0 = coords (x,y)
@@ r1 = dim (w,h)
eraseObjects:
	push	{r4-r10, lr}
	ldr	r4, [r0]		@ x coord
	ldr	r5, [r0, #4]		@ y coord
	
	ldr	r6, [r1]		@ width
	ldr	r7, [r1, #4]		@ height

	sub	r4, #120		@ x -120
	mov	r0, #TILEW		@
	sdiv	r4, r4, r0		@ x/40
	
	sub	r5, #120		@ y-120
	mov	r0, #TILEH
	sdiv	r5, r5, r0		@ y/25

	mov	r0, #BOARDW		
	mul	r8, r5, r0		@ y*width
	add	r8, r8, r4		@ (y*width) +x
	mov	r0, #4			@ offset
	mul	r8, r0
	
	ldr	r0, =map
	ldr	r0, [r0, r8]	

	cmp	r0, #10
	ldreq	r0, =background

	cmp	r0, #1
	ldreq	r0, =yellowBrick

	cmp	r0, #2
	ldreq 	r0, =orangeBrick

	cmp	r0, #3
	ldreq 	r0, =redBrick
	
	ldr	r1, =wh

	ldr	r2, =xyCoord
	str	r7, [r2]
	str	r8, [r2, #4]
	bl	drawImage	
	
	


	
@@@ NEEDS WORK @@@
@@@ HAVE TO INTEGRATE MULTIPLE SQUARES @@


allErased:
	pop	{r4-r10, lr}
	bx	lr
	


.section .data

xyCoord: .int 0,0
wh: .int 40,25 
