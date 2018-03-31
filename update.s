
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
@@@@@@@@@@@@ Collisions @@@@@@@@@@@@@@


	@@ collision somewhere	


@@@@@@@@@@@@ Erase ball, paddle, and powerUps @@@@@@@@@@@@@@

	ldr	r0, =ballCoord		@ Erase ball
	ldr	r1, =ballDimen
	bl	DrawBackground

	ldr	r0, =powerUp1		@ Erase PowerUp1
	ldr	r1, =powerUpDimen
	bl	DrawBackground

	ldr	r0, =powerUp2		@ Erase PowerUp2
	ldr	r1, =powerUpDimen
	bl	DrawBackground

	ldr	r0, =paddle		@ Erase Paddle
	ldr	r1, =paddleDimen
	bl	DrawBackground

@@@@@@@@@@ Update paddle, ball, and powerUp locations @@@@@@

	@@ Update Ball COORD NEED@@@

	bl	powerUpdate		@ Update PowerUp locations

	mov	r0, r10			@ Update Paddle location
	bl	PaddleUpdate

@@@@@@@@@@@ Draw paddle, ball, and powerUps @@@@@@@@@@@@@@@@

	ldr	r0, =Paddle
	bl	drawPadle
	
	ldr	r0, =powerUp1		@ Location of powerup coords
	ldr	r2, =PowerUp1		@ Location of powerUp Picture
	ldr	r3, [r0, #8]		@ Get powerUp state
	cmp	r3, #1
	ldreq	r1, [r0, #4]		@ Load Y coord
	ldreq	r0, [r0]		@ Load X coord
	bleq	drawHardTile	
	
	ldr	r0, =powerUp2		@ Location of powerup coords
	ldr	r2, =PowerUp2		@ Location of powerUp Picture
	ldr	r3, [r0, #8]		@ Get powerUp state
	cmp	r3, #1
	ldreq	r1, [r0, #4]		@ Load Y coord
	ldreq	r0, [r0]		@ Load X coord
	bleq	drawHardTile

	bl	drawBall
	



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

	ldr	r0, =powerUp1		@@Set PowerUp Locations	
	bl	setPowerUp

	ldr	r0, =powerUp2
	bl	setPowerUp	

break4:
stateDone:
	ldr	r0, =gameState
	str	r4, [r0, #STATE]
	pop	{r4, lr}
	bx	lr
	
	
	











	

