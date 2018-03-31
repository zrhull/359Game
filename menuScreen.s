
@ Code section
.section .text
.include "constants.s"
.global initMenuScreen
initMenuScreen:
	push	{r4-r10, lr}
@@@@@@@@@@@@BACKGROUND@@@@@@@@@@@@@@@@@@@
/*
* Right now currently testing drawing multiple images
* Want to look into font size and different texts
* for creator names
*/	
	ldr	r0, =gameState
	mov	r1, #STARTCURSOR
	str	r1, [r0, #CURSORLOC]
	mov	r7, #STARTX	
	mov	r8, #STARTY
	@Set address
	ldr	r0, =menu		@@GET THIS
	mov	r1, #120
	mov	r2, #120
	@Set w and h
	ldr	r1, =menuWH		@@ width and height
	@str	r5, [r1]		@@ width = r5
	@str	r6, [r1, #4]		@@ height = r6
	
	@Set x and y
	ldr	r2, =xy
	str	r7, [r2]
	str	r8, [r2,#4]
	
	@drawImg
	bl	drawImage		@@r0= address for img, r1 = address for WH
					@@ r2 = address for xy

	@drawImg
	@bl	drawImage
	b	drawCursor
@@@@@@@@@@ LOGO	@@@@@@@@@@@@@@@@@@@@			
drawLogo:
	mov	r5, #548
	mov	r6, #175
	mov	r7, #140
	mov	r8, #130
	
	@Set address
	ldr	r0, =logo		@@GET THIS
	
	@Set w and h
	@ldr	r1, =imgWH		@@ width and height
	@str	r5, [r1]		@@ width = r5
	@str	r6, [r1, #4]		@@ height = r6
	
	@Set x and y
	ldr	r2, =xy
	str	r7, [r2]
	str	r8, [r2,#4]
	
	@drawImg
	bl	drawImage		@@r0= address for img, r1 = address for WH
					@@ r2 = address for xy

	ldr	r9,=gameState
	ldr	r9, [r9, #CURSORLOC]
	@mov	r9, #0			@@ r9 is location of cursor
					@@ 0 is start 1 is quit
drawCursor:
	
	@mov	r5, #32			@@ Width
	@mov	r6, #32			@@ Height
	mov	r7, #270		@@ X, CHANGE VALUES LATER
	@ldr	r9,=gameState
	@ldr	r9, [r9, #CURSORLOC]
	@cmp	r9, #0			
	mov	r8, #475		@@ Y HEIGHT FOR START
	@movne	r8, #450		@@ Y HEIGHT FOR QUIT

	ldr	r0, =cursor
	ldr	r1, =cursorWH
	@str	r5, [r1]
	@str	r6, [r1, #4]
	ldr	r2, =xy
	str	r7, [r2]
	str	r8, [r2, #4]
	bl	drawImage
	pop	{r4-r10, lr}
	bx	lr

.global updateCursor
updateCursor:
	push	{r4-r10, lr}
	@@@ First erase old cursor@@@
	ldr	r9,=gameState
	ldr	r9, [r9, #CURSORLOC]
	mov	r7, #270		@@ X, CHANGE VALUES LATER
	cmp	r9, #PLAY			
	movne	r8, #475		@@ Y HEIGHT FOR START
	moveq	r8, #535		@@ Y HEIGHT FOR QUIT
	
	ldr	r0, =blackTile
	ldr	r1, =blackTileWH
	ldr	r2, =xy
	str	r7, [r2]
	str	r8, [r2, #4]
	bl	drawImage
	@@@@@@@ Draw new cursor@@@@@
	@ldr	r9,=gameState
	@ldr	r9, [r9, #CURSORLOC]

	mov	r7, #270		@@ X, CHANGE VALUES LATER
	cmp	r9, #PLAY		
	moveq	r8, #475		@@ Y HEIGHT FOR START
	movne	r8, #535		@@ Y HEIGHT FOR QUIT

	ldr	r0, =cursor
	ldr	r1, =cursorWH
	ldr	r2, =xy
	str	r7, [r2]
	str	r8, [r2, #4]
	bl	drawImage
		
return:
	pop	{r4-r10, lr}
	bx	lr


@ Data Section
.section .data


xy:
	.int 0,0
