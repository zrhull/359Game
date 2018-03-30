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
.equ	START,		3	
.equ	UP,		4
.equ	DOWN,		5
.equ	LEFT,		6
.equ	RIGHT,		7	
.equ	A,		8
.equ	ARIGHT,		0xFE7F
.equ	ALEFT,		0xFBFF

@@START STATE OF SOME VALUES
.equ	STARTCURSOR,	1

@STATES
.equ	MENU,		0
.equ	PLAY,		1
.equ	PAUSE,		2
.equ	QUIT,		3