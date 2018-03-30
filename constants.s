@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ All the constants used throughout the game
@ constants.s				    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.equ	STARTX,		120
.equ	STARTY,		120

@@OFFSETS FOR 
.equ	STATE,		0		
.equ	PADDLEX,	4
.equ	PADDLEY,	8
.equ	CURSORLOC,	12
.equ	GAMESCORE,	16
.equ	PADDLEW,	20
.equ	PADDLEH,	24

@@SNES BUTTONS
.equ	B,		0
.equ	START,		1
.equ	UP,		2
.equ	DOWN,		3
.equ	LEFT,		4
.equ	RIGHT,		6
.equ	A,		8
.equ	ARIGHT,		7
.equ	ALEFT,		5

@@START STATE OF SOME VALUES
.equ	STARTCURSOR,	1

@@STATES
.equ	MENU,		0
.equ	PLAY,		1
.equ	PAUSE,		2
.equ	QUIT,		3

@@PADDLESTUFF
.equ	PADDLEMAX,	560
.equ	PADDLEMIN,	160
