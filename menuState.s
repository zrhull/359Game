

@ Code section
.section .text

.global menuState
menuState:
	push	{r4-r10, lr}
	@b	drawLogo	
	@ldr	r0, =frameBufferInfo
	@bl	initFbInfo
@@@@@@@@@@@@BACKGROUND@@@@@@@@@@@@@@@@@@@
/*
* Right now currently testing drawing multiple images
* Want to look into font size and different texts
* for creator names
*/
	mov	r5, #640
	mov	r6, #560
	mov	r7, #600
	mov	r8, #200
	
	@Set address
	ldr	r0, =menu		@@GET THIS
	
	@Set w and h
	ldr	r1, =imgWH		@@ width and height
	str	r5, [r1]		@@ width = r5
	str	r6, [r1, #4]		@@ height = r6
	
	@Set x and y
	ldr	r2, =xy
	str	r7, [r2]
	str	r8, [r2,#4]
	
	@drawImg
	bl	drawImage		@@r0= address for img, r1 = address for WH
					@@ r2 = address for xy
@@@@@@@@@@ LOGO	@@@@@@@@@@@@@@@@@@@@			
drawLogo:
	mov	r5, #548
	mov	r6, #175
	mov	r7, #650
	mov	r8, #300
	
	@Set address
	ldr	r0, =logo		@@GET THIS
	
	@Set w and h
	ldr	r1, =imgWH		@@ width and height
	str	r5, [r1]		@@ width = r5
	str	r6, [r1, #4]		@@ height = r6
	
	@Set x and y
	ldr	r2, =xy
	str	r7, [r2]
	str	r8, [r2,#4]
	
	@drawImg
	bl	drawImage		@@r0= address for img, r1 = address for WH
					@@ r2 = address for xy
	mov	r9, #0			@@ r9 is location of cursor
					@@ 0 is start 1 is quit
drawCursor:
	mov	r5, #32			@@ Width
	mov	r6, #32			@@ Height
	mov	r7, #680		@@ X, CHANGE VALUES LATER
	
	cmp	r9, #0
	moveq	r8, #500		@@ Y HEIGHT FOR START
	movne	r8, #550		@@ Y HEIGHT FOR QUIT

	ldr	r0, =cursor
	ldr	r1, =imgWH
	str	r5, [r1]
	str	r6, [r1, #4]
	ldr	r2, =xy
	str	r7, [r2]
	str	r8, [r2, #4]
	bl	drawImage

cursorInput:
	bl	find_Button
	cmp	r0, #4
	moveq	r9, #0
	beq	drawCursor
	cmp	r0, #5
	moveq	r9, #1
	beq	drawCursor
	
	cmp	r0, #8
	bne	cursorInput
	mov	r0, r9			@@ Returns what the cursor was pointing
					@@ to. 0 for start game, 1 for Quit	
return:
	pop	{r4-r10, lr}
	bx	lr


@ Data Section
.section .data

imgWH:
	.int 0, 0

xy:
	.int 0,0
