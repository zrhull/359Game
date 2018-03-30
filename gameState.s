.section .data

.global gameState
gameState:
	state:		.int 0		@@0=menu, 1=game, 2=pause, 3=quit
	paddle_x:	.int 50		@NEED TO SET THIS
	paddle_y:	.int 50		@NEED TO SET THIS
	cursorLoc:	.int 0
	gameScore:	.int 0
	