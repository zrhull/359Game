@@Zachary Hull     10109756	CPSC 359 Assignment 3

@@This program is a driver for the SNES controller, it sets up the latch
@@data and clock lines then pulses every 12 microseconds getting data from
@@the controller and then printing on screen what was pressed. It loops to 
@@keep asking for new buttons.

@@2 quick notes. First, every once in awhile if you press "Y" just right it will
@@twice for some reason. Its not too common and I donnot know why it is
@@happening. Second is when you press start it needs to be helf down for a
@@second before it knows it is pressed. Perhaps that is just the controller I am
@@using though.

@ Code section
.section    .text


.global Driver
Driver: 
	bl	getGpioPtr			@ get Gpio base address
	ldr	r1, =gpioBase
	str	r0, [r1]			@ store gpio base

	mov	r0, #10				@ Set GPIO pin 10(DATA) to input
	mov	r1, #0
	bl	Init_GPIO

	mov	r0, #11
	mov	r1, #1
	bl	Init_GPIO			@ set GPIO pin 11 (clock) to output

	mov	r0, #9				@ set GPIO pin 9 (Latch) to output
	mov	r1, #1
	bl	Init_GPIO

	ldr	r0, =hello			@ print creator name
	bl	printf

buttonWasPressed:

newButton:
	ldr	r5, =buttons
	mov	r6, #0				@ reset buttons to 0
	str	r6, [r5]
	bl	readSNES			@ call the button function
	ldr	r9, [r5]			@ save buttons pressed

	mov	r7, #0xffff			@ move 16 1's into a register
	teq	r9, r7				@ if no button was pressed loop for a new button
	beq	newButton

	tst	r9, #(1<<15)			@ 12 individual bit testers to see if
	bne	Yc				@ the button was pressed
	b	done
Yc:
	tst	r9, #(1<<14)			@ test for Y
	bne	Slc
	b	done
Slc:
	tst	r9, #(1<<13)			@ test for Sl
	bne	Stc
	b	done
Stc:
	tst	r9, #(1<<12)			@ test for St
	bne	Upc
	b	terminate			@ end the program
Upc:
	tst	r9, #(1<<11)			@ test for Joy pad up
	bne	Downc
	b	done
Downc:
	tst	r9, #(1<<10)			@ test for joy pad down
	bne	Leftc
	b	done
Leftc:
	tst	r9, #(1<<9)			@ test for joy pad left
	bne	Rightc
	tst	r9, #(1<<7)
	moveq	r0, #-6
	movne	r0, #-3
	bl	drawPadle
	b	done
Rightc:
	tst	r9, #(1<<8)			@ test for joy pad right
	bne	Ac
	tst	r9, #(1<<7)
	moveq	r0, #6
	movne	r0, #3
	bl	drawPadle
	b	done
Ac:
	tst	r9, #(1<<7)			@ test for A
	bne	Xc
	b	done
Xc:
	tst	r9, #(1<<6)			@ test for X
	bne	Lc
	b	done
	bl	printf
Lc:
	tst	r9, #(1<<5)			@ test for left bumper
	bne	Rc
	b	done
Rc:
	tst	r9, #(1<<4)			@ test for right bumper
	bne	done
	
	tst	r9, #(1<<3)			@ not used as of now
	tst	r9, #(1<<2)
	tst	r9, #(1<<1)
	tst	r9, #(1<<0)
done:	
	mov	r0, #30000			@ delay while the button is being pushed
	bl	delayMicroseconds

	ldr	r0, =buttons			@ reset buttons
	mov	r1, #0
	str	r1, [r0]

	mov	r0, #45				@ delay a few micro seconds
	bl	delayMicroseconds
	bl	readSNES			@ read buttons
	ldr	r0, =buttons
	ldr	r0, [r0]			@ load buttons pressed
	tst	r0, #(1<<9)
	beq	buttonWasPressed
	tst	r0, #(1<<8)
	beq	buttonWasPressed
	mov	r11, #0xffff
	teq	r0, r11				@ test if no buttons were pressed
	bne	done				@ /if the pressed button was released
	

	b	buttonWasPressed		@ loop again

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

readSNES:				@ function to sample the buttons and returned pressed
	ldr	r1, =lrSave			@ store the link register
	str	lr, [r1]

	mov	r0, #1				@ set the clock to 1
	bl	writeClock			@ rising edge

	mov	r0, #1				@ set the Latch to 1
	bl	writeLatch

	mov	r0, #12
	bl	delayMicroseconds		@ delay 12 us

	mov	r0, #0				@ function code sor setLatch
	bl	writeLatch			@ call setLatch

	ldr	r0, =i				@ set i = 0
	mov	r1, #0
	str	r1, [r0]
	
pulseLoop:					@ loop for every button 
	mov	r0, #6
	bl	delayMicroseconds		@ delay 6 us
	
	mov	r0, #0				@ write 1 to clock line
	bl	writeClock			@ falling edge

	mov	r0, #6
	bl	delayMicroseconds		@ delay 6 us

	bl	readGPIO			@ get button pressed
	ldr	r2, =buttons
	ldr	r1, [r2]
	lsl	r1, #1
	orr	r1, r0				@ shift in the value returned	

	str	r1, [r2]
	
	mov	r0, #1				@ write clock to 1
	bl	writeClock			@ rising edge of clock

	ldr	r3, =i
	ldr	r2, [r3]
	add	r2, #1				@ Load, increment, and store i
	str	r2, [r3]
bot:	cmp	r2, #16
	blt	pulseLoop			@ compare and branch if i is < 16

	ldr	r1, =lrSave			@ to be returned
	ldr	lr, [r1]			@ load link register
	bx	lr				@ return

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

readGPIO:				@ read from GPIO (DATA)
	ldr	r1, =gpioBase			@ load GPIOBase
	ldr	r1, [r1]
	ldr	r0, [r1, #0x34]			@ load GPLEV0 
	tst	r0, #(1<<10)
	moveq	r0, #0 				@ return 0
	movne	r0, #1				@ return 1
	bx	lr				@ return

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

writeClock:				@ function to write to the clock GPIO line
	ldr	r1, =gpioBase			@ base address for GPIO
	ldr	r1, [r1]			@ load the address
	mov	r2, #1
	lsl	r2, #11				@ align pin's bit
	teq	r0, #0
	streq	r2, [r1, #40]			@ store 0
	strne	r2, [r1, #28]			@ store 1
	bx	lr				@ return

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

writeLatch:				@ function to write to the latch GPIO line
	ldr	r1, =gpioBase			@ base address for GPIO
	ldr	r1, [r1]			@ load the address
	mov	r2, #1
	lsl	r2, #9				@ align pin's bit
	teq	r0, #0
	streq	r2, [r1, #40]			@ store 0
	strne	r2, [r1, #28]			@ store 1
	bx	lr				@ return

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Init_GPIO:				@ set GPIO pin to given function code
	ldr	r2, =gpioBase			@ Load GPIOBase
	ldr	r2, [r2]
	teq	r0, #9				@ test if the input line is 9
	addne	r2, #0x4			@ if it is not increment GPFSEL0 to 1 
	moveq	r0, #27				@ make offset by 27
	teq	r0, #10				@ test if pin is 10
	moveq	r0, #0				@ no offset
	teq	r0, #11				@ test if pin is 11
	moveq	r0, #3				@ offset is 3
	ldr	r3, [r2]			@ Copy GPFSEL into r3
	teq	r1, #1
	mov	r1, #7				@ binary 0111
	lsl	r1, r0				@ offset for pin
	bic	r3, r1				@ clear pin's bits
	moveq	r1, #1				@ move function code back into r1
	movne	r1, #0
	lsl	r1, r0
	orr	r3, r1				@ set pin in r3
	str	r3, [r2]			@ write back to GPFSEL
	bx	lr				@ return
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

terminate:				@ end the program
	ldr	r0, =progTerm			@ print the program is terminated
	bl	printf

	haltLoop$:  
		b       haltLoop$

@ Data section
.section	.data

hello:	.asciz	"Created By: Zachary Hull\r\n"

progTerm:	.asciz	"Program is terminating...\r\n"

i:		.int	0x0

gpioBase:	.int	0x00000000

lrSave:		.int	0x00000000

lrSave2:	.int	0x00000000

lastPressed:	.int	0x0000

buttons:	.int	0x0000

