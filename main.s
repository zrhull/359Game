
@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 	r0, =frameBufferInfo 	@ frame buffer information structure
	bl	initFbInfo
	bl	initMenuScreen
	@bl	setup
loop:
	bl	find_Button
	bl	update
	
	b	loop
	
	mov	r4, r0
	mov	r0, #0
	cmp	r4, #0
	
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


