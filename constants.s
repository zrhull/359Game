@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ All the constants used throughout the game
@ constants.s				    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@ CONSTANTS @@@@@@@@@
.equ	STARTX,		120
.equ	STARTY,		120
.equ	TILEW,		40
.equ	TILEH,		25
.equ	BOARDW,		14
.equ	BOARDH,		28
.equ	BALLW,		8
.equ	BALLH,		8

@@@@@@@@@@@@@@@@@@@@@@@
@@ OFFSETS FOR GAME @@@@@
.equ	STATE,		0		
.equ	CURSORLOC,	4
.equ	GAMESCORE,	8
.equ	LIVESLEFT,	12
.equ	WINBOOLEAN,	16
.equ	PLAYING,	20

@@@@ PADDLE VARIABLES "paddleState" @@
.equ	PADDLEX,	0
.equ	PADDLEY,	4



@@ OFFSETS FOR BALL "ballState" @@
.equ	BALLX,		0
.equ	BALLY,		4


@@ power up offsets "powerUpState" @@
.equ	PU1X,		0
.equ	PU1Y,		4
.equ	PU1ACTIVE,	8
.equ	PU2X,		12
.equ	PU2Y,		16
.equ	PU2ACTIVE,	20

@@SNES BUTTONS@@@@@@@@@
.equ	B,		0
.equ	START,		1
.equ	UP,		2
.equ	DOWN,		3
.equ	LEFT,		4
.equ	RIGHT,		6
.equ	A,		8
.equ	ARIGHT,		7
.equ	ALEFT,		5

@@@@@ START STATE OF SOME VALUES@@@@@@
.equ	STARTCURSOR,	1
.equ	STARTLIVES,	3
.equ	STARTSCORE,	0
.equ	STARTBALLX,	396
.equ	STARTBALLY,	777

@@ STATES
.equ	MENU,		0
.equ	PLAY,		1
.equ	PAUSE,		2
.equ	QUIT,		3

@@ PADDLESTUFF
.equ	PADDLEMAX,	560
.equ	PADDLEMIN,	160
