.section .data

.global gameState
gameState:
	state:		.int 0		@@0=menu, 1=game, 2=pause, 3=quit
	cursorLoc:	.int 1		@@ 
	gameScore:	.int 0
	livesLeft:	.int 3		
	winBoolean:	.int 0		@@ 0 = playing, 1 = win, -1 = LOSE
	activePlaying:	.int 0		@@ 0 means not playing, 1 is active playing

.global paddleState
paddleState:
	paddleX:	.int 360
	paddleY:	.int 785

.global ballState
ballState:
	ballX:		.int 396
	ballY:		.int 770
	

.global powerUpState
powerUpState:
	powerUp1X:	.int 0
	powerUp1Y:	.int 0
	pu1active:	.int 0

	powerUp2X:	.int 0
	powerUp2Y:	.int 0
	pu2active:	.int 0
	
.align


@@ To get a particular square, divide by 40, then *4 to get offset?
@.global	map
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