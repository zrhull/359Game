
@@r0 should be input@@
.section .text
.include "constants.s"
.global update
update:
	push	{r4-r10, lr}
break2:
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
	mov	r7, #QUIT
	cmp	r10, #3			@ down button pressed
	moveq	r9, #QUIT		@ change cursor to quit
	streq	r9, [r4, #CURSORLOC]	
	bleq	updateCursor		@ draw new cursor
	beq	updateReturn
	cmp	r10, #A			@ A button pressed
	mov	r7, #A
	ldreq	r0, [r4, #CURSORLOC]	@ load cursor location
					@ and pass as new state
	beq	changeState
	b	updateReturn	


updateGame:
break3:
	@@ collision somewhere	

	@@ erase ball
	ldr	r0, =ballCoord
	ldr	r1, =ballDimen
	bl	DrawBackground
	
	@@ Update Ball COORD NEED@@@

	@@ draw new ball
	@bl	drawBall
	
	@@@@@@@@@@@@@@@@@@@@@@@@@@@
	ldr	r0, =powerUp1
	ldr	r1, =powerUpDimen
	bl	DrawBackground

	bl	powerUpdate



	@@@@@@@@@@@@@@@@@@@@@@@@@@@
	


	@@ erase paddle
	ldr	r0, =paddle
	ldr	r1, =paddleDimen
	bl	DrawBackground

	@@ Check input
	@@ if left move left 
	@@ if right move rigt
	@@ 0 right, 1 left, 2 rightfast, 3leftfast

	
	cmp	r10, #RIGHT
	moveq	r0, #0
	@addeq	r2, #3
	cmp	r10, #LEFT
	moveq	r0, #1
	@subeq	r2, #3
	cmp	r10, #ARIGHT
	moveq	r0, #2
	@addeq	r2, #6
	cmp	r10, #ALEFT
	@subeq	r2, #6
	moveq	r0, #3
	@str	r2, [r1]
	bl	PaddleUpdate
	ldr	r0, =Paddle
	bl	drawPadle
	
	ldr	r0, =powerUp1
	ldr	r2, =PowerUp1
	ldr	r1, [r0, #4]
	ldr	r0, [r0]
	bl	drawHardTile	
	
	bl	drawBall

	@@ draw new paddle
	



updatePause:


updateQuit:

updateReturn:
	mov	r0, #30000
	bl	delayMicroseconds
	pop	{r4-r10, lr}
	bx	lr

@ r0 is newState
@ This will help create a transition
changeState:
	push	{r4,lr}
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

	@@JUST FOR TESTING@@@POWERUP
	ldr	r2, =powerUp1
	mov	r1, #250
	mov	r0, #240
	str	r0, [r2]
	str	r1, [r2, #4]
	mov	r0, #240
	ldr	r2, =PowerUp1
	bl	drawHardTile	
	
break4:
stateDone:
	ldr	r0, =gameState
	str	r4, [r0, #STATE]
	pop	{r4, lr}
	bx	lr
	
	
	











	

