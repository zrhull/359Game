
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
	bleq	changeState
	b	updateReturn	

updatePause:

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
	bne	resume			@ and pass as new state
	bleq	changeState
	beq	updateReturn
	@@@@@@@@@@@@@@@
	@@@@@@ TEST for unpause
	@@@@@@@@@@@@@

resume:
	cmp	r10, #START
	bne	updateReturn


	ldr	r0, =gameState
	mov	r1, #PLAY
	str	r1, [r0, #STATE]	@@ change state to play
buttonReleasedResume:
	bl	newButton
	cmp	r0, #NOBUTTON
	bne	buttonReleasedResume
	
	bl	setup
	ldr	r4, =gameState
	mov	r1, #1			@@ save #1 into PLAYING
	str	r1, [r4, #PLAYING]	@@ activates playing	
	
	b	updateReturn

	@@@ IF START IS PRESSED AGAIN, RESUME PLAY @@
	@@ CALLING SETUP SHOULD WORK??@@@
	@cmp	r10, #START
	@bleq	setup
	@ldr	r4, =gameState
	@mov	r1, #1			@@ save #1 into PLAYING
	@str	r1, [r4, #PLAYING]	@@ activates playing


	@ldr	r0, =gameState
	@mov	r1, #PLAY
	@str	r1, [r0, #STATE]	@@ change state to play
	
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
	cmp	r10, #START
	moveq	r0, #PAUSE
	bleq	changeState

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

	mov	r0, r10			@ Update Paddle location
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
	cmp	r4, #PAUSE
	beq	pause
	cmp	r4, #QUIT
	beq	quitting
	b	stateDone


changePlay:
	ldr	r0, =gameState
	ldr	r1, [r0, #STATE]
	cmp	r1, #MENU		@ If current state was menu, then initialize board
	beq	playINIT
	cmp	r1, #PAUSE
	bleq	restartGame		@ If current state is pause, then redraw whole board with current values
	beq	playINIT		@ and set playing to active
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
	bl	drawPause
buttonReleased:
	bl	newButton
	cmp	r0, #NOBUTTON
	bne	buttonReleased	
	b	stateDone

quitting:
	ldr	r0, =gameState
	ldr	r1, [r0, #STATE]
	cmp	r1, #MENU
	bleq	drawQuit
	
	cmp	r1, #PAUSE
	
	moveq	r4, #MENU		@@ DO THIS SINCE QUITTING FROM PAUSE
	bleq	initMenuScreen			@@ RETURNS TO MENU AND DOES NOT QUIT

buttonReleased2:
	bl	newButton
	cmp	r0, #NOBUTTON
	bne	buttonReleased	
	@b	stateDone


	

stateDone:
	ldr	r0, =gameState
	str	r4, [r0, #STATE]
	pop	{r4, lr}
	bx	lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.global restart
reset:
	push	{r4,r5,lr}
	@@ draw new board with paddle @@
	ldr	r4, =paddle
	mov	r5, #STARTPADX
	str	r5, [r4]
	mov	r5, #STARTPADY
	str	r5, [r4, #4]

	@@ ball init	
	ldr	r4, =ballCoord
	mov	r5, #STARTBALLX
	str	r5, [r4]
	mov	r5, #STARTBALLY
	str	r5, [r4, #4]
	
	@@TL of ball
	ldr	r4, =TL
	mov	r5, #STARTBALLX
	str	r5, [r4]
	mov	r5, #STARTBALLY
	str	r5, [r4, #4]
	@@TR of ball
	ldr	r4, =TR
	mov	r5, #STARTBALLX
	add	r5, #7
	str	r5, [r4]
	mov	r5, #STARTBALLY
	str	r5, [r4, #4]
	@@BL of ball
	ldr	r4, =BL
	mov	r5, #STARTBALLX
	str	r5, [r4]
	mov	r5, #STARTBALLY
	add	r5, #7
	str	r5, [r4, #4]
	@@BR of ball
	ldr	r4, =BR
	mov	r5, #STARTBALLX
	add	r5, #7
	str	r5, [r4]
	mov	r5, #STARTBALLY
	add	r5, #7
	str	r5, [r4, #4]
	@@ RESTART ANGLE OF BALL and VALUES
	@ldr	r4, =angle
	@mov	r5, #45
	@str	r5, [r4]

	@ldr	r4, =horizDirection
	@mov	r5, #1
	@str	r5, [r4]
	@ldr	r4, =vertDirections
	@str	r5, [r4]


	pop	{r4,r5,lr}
	bx	lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@ restartGame, will use the mapINIT to copy its values
@@@@ over to the current map
@@@@ Change ball/paddle/score/lives to initial value
@@@@ ball TR TL BR BL stuff?
restartGame:


@@@ ADJUST SO RESTART GAME CALLS RESET, WHICH ONLY DOES PADDLE/BALL@@	
	push	{r4-r10, lr}
	ldr	r4, =mapINIT
	
	ldr	r6, =map

	.rept	392

	ldr	r5, [r4], #4
	str	r5, [r6], #4
	
	.endr

	bl	reset
	@@@ Set lives/score to init
	ldr	r4, =gameState
	mov	r5, #PLAY		@@ chage state to play
	str	r5, [r4]
	mov	r5, #STARTSCORE		@@ change score to 0
	str	r5, [r4, #8]
	mov	r5, #STARTLIVES
	str	r5, [r4, #12]

	pop	{r4-r10, lr}
	bx	lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
	
.section .data

dim: .int 0,0
xy: .int 0,0









	
