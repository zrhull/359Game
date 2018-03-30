
@@r0 should be input@@
.section .text
.include "constants.s"
.global update
update:
	push	{r4-r10, lr}

	mov	r10, r0			@Button Pressed
	ldr	r4, =gameState
	ldr	r5, [r4, #STATE]
	cmp	r5, #MENU
	beq	updateMenu
	cmp	r5, #PLAY
	beq	updateGame
	cmp	r5, #PAUSE
	beq	updatePause
	cmp	r5, #QUIT
	beq	updateQuit

return:
	pop	{r4-r10, lr}
	bx	lr

haltLoop$:
	b	haltLoop$		@ should not get here

updateMenu:
	cmp	r10, #UP		@ UP button pressed
	moveq	r9, #PLAY		@ change cursor to play
	streq	r9, [r4, #CURSORLOC]
	bleq	updateCursor		@ draw new cursor
	beq	updateReturn
	cmp	r10, #DOWN		@ down button pressed
	moveq	r9, #QUIT		@ change cursor to quit
	streq	r9, [r4, #CURSORLOC]	
	bleq	updateCursor		@ draw new cursor
	beq	updateReturn
	cmp	r10, #A			@ A button pressed

	ldreq	r0, [r4, #CURSORLOC]	@ load cursor location
					@ and pass as new state
	beq	changeState
	b	updateReturn	


updateGame:

	@@ collision somewhere	

	@@ erase ball
	@@ draw new ball

	@@ Check input
	@@ if left move left 
	@@ if right move rigt
	@@ 0 right, 1 left, 2 rightfast, 3leftfast
	ldr	r4, =paddle
	ldr	r0, [r4]
	ldr	r1, [r4, #4]
	ldr	r2, [r4, #8]
	mov	r3, #15		
	bl	DrawBackground
	
	cmp	r10, #RIGHT
	moveq	r0, #0
	cmp	r10, #LEFT
	moveq	r0, #1
	@cmp	r10, #ARIGHT
	@moveq	r0, #2
	@cmp	r10, #ALEFT
	@moveq	r0, #3
	bl	PaddleUpdate
	
	ldr	r0, =Paddle
	bl	drawPadle
		

	@@ draw new paddle
	



updatePause:


updateQuit:

updateReturn:
	pop	{r4-r10, lr}
	bx	lr

@ r0 is newState
@ This will help create a transition
changeState:
	pop	{r4,lr}
	mov	r4, r0			@ move new state into r4
	
	cmp	r4, #MENU		@ if new state menu, redraw whole menu
	@bleq	initMenuScreen
	beq	stateDone
	cmp	r4, #PLAY
	beq	changePlay


changePlay:
	ldr	r0, =gameState
	ldr	r1, [r0, #STATE]
	cmp	r1, #MENU		@ If current state was menu, then initialize board
	beq	playINIT
	cmp	r1, #PAUSE
	beq	stateDone		@JUST FOR NOW FIX LATER!!!!!!!
	b	stateDone
playINIT:
	bl	setup
	ldr	r0, =Paddle
	bl	drawPadle
	bl	drawBall

stateDone:
	ldr	r0, =gameState
	str	r4, [r0, #STATE]
	pop	{r4, lr}
	bx	lr
	
	
	











	

