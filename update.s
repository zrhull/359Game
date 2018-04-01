
@@r0 should be input@@
.section .text
.include "constants.s"
.global update
update:
	push	{r4-r10, lr}

	mov	r10, r0			@@ Button Pressed

	ldr	r4, =gameState		@@ Get Current State
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


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ updates the location of the cursor depending
@@ on input. If 'A' is pressed then changes
@@ states to either PLAY or QUIT
updateMenu:
	cmp	r10, #UP		@ UP button pressed
	moveq	r9, #PLAY		@ change cursor to play
	streq	r9, [r4, #CURSORLOC]
	bleq	updateCursor		@ draw new cursor
	beq	updateReturn
	@@mov	r7, #QUIT
	cmp	r10, #DOWN		@ down button pressed
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




@@@@@@@@@@@@ Collisions @@@@@@@@@@@@@@
@@ Normal loop first check if playing (useful for pause)
@@ if powerup active and falling, erase it
@@ is anything moving, erase current location
@@ So if left/right or leftA/rightA are pressed then
@@ erase paddle. erase ball. Update locations
@@ check collisions
@@ redraw background where ball/paddle/powerup were
@@ DEAL WITH COLLISION STUFF (powerup with paddle / 
@@ ball with wall/paddle) If brick update score, if
@@ paddle w/ powerup then INC scoore
@@ If ball goes below allowed zone (beneath paddle)
@@ lose a life and start.
@@ 'B' must be pressed to shoot ball.
@@ also redraw background -> brick -> powerup -> paddle -> ball
@@ 

@@ r4 =gameState, r10 button pressed

 
updateGame:
	@@ Start with checking if actively playing or not@@
	@@ if not playing and then B pressed, change to ACTIVE (1)
	ldr	r5, [r4, #PLAYING]
	cmp	r5, #1
	beq	playing
	cmp	r10, #B			@ If B was pressed, means game started
	bne	updateReturn		@ waiting to start game
	mov	r1, #1			@ save #1 into PLAYING
	str	r1, [r4, #PLAYING]
		

playing:
	
	@@cmp	r10, #START
	@@moveq	r0, #PAUSE
	@@bleq	changeState

@@ ONCE WORKING, TEST IF YOU CAN JUST ERASE, UPDATE, DRAW for
@@ powerup then paddle then ball. Might be easier to skip over

@@@@@@@@@@@@ Erase ball, paddle, and powerUps @@@@@@@@@@@@@@
	 
eraseBall:
	ldr	r0, =ballCoord		@ Erase ball
	ldr	r1, =ballDimen
	bl	DrawBackground
	
	
eraseP1:
	@@ First check if powerup1 is active @@

	ldr	r5, =powerUpState
	ldr	r1, [r4, #PU1ACTIVE]
	cmp	r1, #1
	bne	eraseP2

	ldr	r0, =powerUp1		@ Erase PowerUp1
	ldr	r1, =powerUpDimen
	bl	DrawBackground

eraseP2:
	ldr	r1, [r5, #PU2ACTIVE]
	cmp	r1, #1
	bne	erasePaddle

	ldr	r0, =powerUp2		@ Erase PowerUp2
	ldr	r1, =powerUpDimen
	bl	DrawBackground
	
erasePaddle:
	@ldr	r0, =paddleState
	@ldr	r1, =PaddleWH
		
	@bl	DrawBackground

	cmp	r10, #LEFT
	blt	coordUpdate
	cmp	r10, #ARIGHT
	bgt	coordUpdate
	ldr	r0, =paddle	@State	@ Erase Paddle
	ldr	r1, =paddleDimen	@WH
	bl	DrawBackground

@@@@@@@@@@ Update paddle, ball, and powerUp locations @@@@@@

	@@ Update Ball COORD NEED@@@
coordUpdate:
	bl	ballPositionUpdate
	bl	powerUpdate		@ Update PowerUp locations

test:	mov	r0, r10			@ Update Paddle location
	bl	PaddleUpdate

@@@@@@@@@@@ Draw paddle, ball, and powerUps @@@@@@@@@@@@@@@@

	ldr	r0, =Paddle
	bl	drawPadle
	
	
	ldr	r0, =powerUpState	@ Location of powerup coords
	ldr	r2, =PowerUp1		@ Location of powerUp Picture
	ldr	r3, [r0, #PU1ACTIVE]	@ Get powerUp state
	cmp	r3, #1
	ldreq	r1, [r0, #PU1Y]		@ Load Y coord
	ldreq	r0, [r0, #PU1X]		@ Load X coord
	bleq	drawHardTile	
	
	ldr	r0, =powerUpState	@ Location of powerup coords
	ldr	r2, =PowerUp2		@ Location of powerUp Picture
	ldr	r3, [r0, #PU2ACTIVE]	@ Get powerUp state
	cmp	r3, #1
	ldreq	r1, [r0, #PU2Y]		@ Load Y coord
	ldreq	r0, [r0, #PU2X]		@ Load X coord
	bleq	drawHardTile

	bl	drawBall
	b	updateReturn
	


@@ CURSOR
@@
@@
@@
updatePause:



@@ Set ACTIVE to 0,
@@ Change State to 3
@@ draw black screen (NEED METHOD)
@@ NOT MUCH ELSE	
@@
updateQuit:


updateReturn:
	mov	r0, #10000
	bl	delayMicroseconds
	pop	{r4-r10, lr}
	bx	lr

@ r0 is newState
@ This will help create a transition
changeState:
	push	{r4,lr}
	mov	r4, r0			@ move new state into r4
	
	cmp	r4, #MENU		@ if new state menu, redraw whole menu IMPLEMENT THIS SINCE
					@ Anytime going to menu is like restarting program
	bleq	initMenuScreen
	beq	stateDone
	cmp	r4, #PLAY
	beq	changePlay
	@cmp	r4, #PAUSE
	@beq	pause


changePlay:
	ldr	r0, =gameState
	ldr	r1, [r0, #STATE]
	cmp	r1, #MENU		@ If current state was menu, then initialize board
	beq	playINIT
	cmp	r1, #PAUSE
	beq	stateDone		@JUST FOR NOW FIX LATER!!!!!!!
	b	stateDone
playINIT:
	ldr	r0, =ScoreBoard		@Draw scoreboard
	ldr	r1, =ScoreboardDimen
	ldr	r2, =ScoreboardCoord
	bl	drawImage
	bl	setup
	@ldr	r0, =Paddle
	bl	drawPaddle
	bl	drawBall
	@@@@ Draw score / lives @@@@

	ldr	r0, =powerUp1		@@Set PowerUp Locations	
	bl	setPowerUp

	ldr	r0, =powerUp2
	bl	setPowerUp
	b	stateDone	

pause:
	ldr	r0, =gameState
	mov	r1, #0			@ Sets active playing to false
	str	r1, [r0, #PLAYING]
	
	



unpause:



stateDone:
	ldr	r0, =gameState
	str	r4, [r0, #STATE]
	pop	{r4, lr}
	bx	lr
	
	
	
.section .data

dim: .int 0,0










	
