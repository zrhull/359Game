
@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 	r0, =frameBufferInfo 	@ frame buffer information structure
	bl	initFbInfo
	
breakTest:
	bl	initMenuScreen
	@bl	setup
	bl	Driver
loop:
	bl	newButton
	bl	update
	
	b	loop

@ stop
haltLoop$:


@ Data section
.section .data

.align
.globl frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height


