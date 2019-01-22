
@ Code section
	.section .text

	.global getSnes

getSnes:	
	push {r4-r9,lr}
	bl	getGpioPtr				// Get GPIO base address (virtual)
	ldr	r1, =GpioBaseAddr
	str	r0, [r1]

// Initialize GPIO 
	mov	r0,#9					// PIN # 9 = Latch. Set latch to output (1)
	mov	r1,#1
	bl	Init_GPIO

	mov	r0,#10					// PIN # 10 = Data. Set data to input (0)
	mov	r1,#0
	bl	Init_GPIO

	mov	r0,#11					// PIN # 11 = Clock. Set clock to output (1)
	mov	r1,#1
	bl	Init_GPIO

// Start: Ask user to press a button
userInput:
	
	
readS:	
	mov	r1,#-1
	mov	r0,#-1
	bl 	Read_SNES
	mov 	r0,r0
	mov	r1,r1
	pop {r4-r9,lr}
	mov pc,lr
	//cmp	r0,#0
	//blt	readS
	//mov	r1,r0
	//bl	message

////////////////////////////////////////////////////////////////////////////////////////////////////

// WRITING A GPIO LINE. Parameters = r0 = pin number, r1 = output (1), input (0)
Init_GPIO:
	push {r4,r5,r6,r7,r8,r9,lr}
	mov	r5,r0					// Pin # - can be 9, 10 or 11
	mov	r8,r1					// Setting to output or input	

	mov	r9,#0					// r9 = 0
	b 	loop

start:	sub	r5,#10					// Pin # - 10
	add	r9,#1					// r9 ++

loop:	cmp	r5,#10					// r5 can be 1, 0, or -1
	bge	start					// If greater or equal to 10 branch to start

	ldr	r7, =GpioBaseAddr			// Get GPIO Base Address
	ldr	r7,[r7]					// Copy into r7
	ldr	r4, [r7,r9,lsl #2]			// Load into r4 
	mov	r1, #3					// r1 = 3
	mov	r2, #7					// 111 - used for clearing
	mul	r1,r5					// r1 = 3 x PIN Number (least sig digit)
	lsl	r2,r1					// Shift output code to appropriate location
	bic	r4, r2,lsl r1				// Set pin function
	orr	r1, r8, lsl r1				
	str	r1, [r7,r9,lsl #2]			// Write back to GPFSELn

	pop 	{r4,r5,r6,r7,r8,r9,lr}
	mov	pc,lr

////////////////////////////////////////////////////////////////////////////////////////////////////

// Write 1 or 1 to Latch line 
Write_Latch:
	push	{r4,r5,r6,r7,lr}
	mov	r4, r0					// Value to write = 0 or 1
	mov	r5, #9					// Pin #9 = Latch Line
	ldr	r1, =GpioBaseAddr			// GPIO Base Address
	ldr	r7,[r1]					// Copy to r7
	mov	r6, #1					// Always 1
	lsl	r6, r5					// Align bit for pin #9
	teq	r4, #0					// Test Equivalence 
	streq	r6, [r7, #40]				// If r4 == 0: GPCLR0 (Write 0)
	strne	r6, [r7, #28]				// If r4 == 1: GPSET0 (Write 1) 
	pop	{r4,r5,r6,r7,lr}
	mov	pc, lr	

/////////////////////////////////////////////////////////////////////////////////////////////////////

// Write 0 or 1 to Clock line
Write_Clock:

        push	{r4,r5,r6,r7,lr}                                                                                               
	mov	r4, r0					// Value to write (0 or 1)
	mov	r5, #11					// Pin #11 = clock line
	ldr	r1, =GpioBaseAddr			// GPIO Base Address
	ldr	r7,[r1]					// Copy to r7
	mov	r6, #1					// Always 1
	lsl	r6, r5					// Align bit for pin 11
	teq	r4, #0					// Test equivalence 
	streq	r6, [r7, #40]				// If r4 == 0: GPCLR0 (Write 0)
	strne	r6, [r7, #28]				// If r4 == 1: GPSET0 (Write 1)
	pop	{r4,r5,r6,r7,lr}
	mov	pc, lr
	
////////////////////////////////////////////////////////////////////////////////////////////////////

// Read Data SNES Loop 16 times. Reading GPIO Line. Reads and returns 0 or 1. 
Read_Data:
	push	{r4,r5,r6,r7,lr}
	mov	r5, #10					// Pin #10 = Data Line
	ldr	r1, =GpioBaseAddr			// Base GPIO Address
	ldr	r7,[r1]					// Copy into r7
	ldr	r4, [r7, #52]				// GPLEV0
	tst	r4,#(1<<10)				// 
	moveq	r0, #0					// If r4 == 0: Return 0
	movne	r0, #1					// If r4 == 1: Return 1
	pop	{r4,r5,r6,r7,lr}
	mov	pc, lr
		
//////////////////////////////////////////////////////////////////////////////////////////////////////

// Main SNES subroutine that reads input (button pressed) from the controller. 
// Returns the code of a pressed button in a register. 	
Read_SNES:
	push	{r7,r8,r9,lr}
	
	mov	r7,r0
	mov	r0, #1
	bl	Write_Clock				// Write 1 to Clock line	

	mov	r0, #1
	bl	Write_Latch				// Write 1 to Latch line
	
	mov	r0, #6000
	bl	delayMicroseconds			// Delay 12 us

	mov	r0, #0
	bl	Write_Latch				// Write 0 to Latch

	mov	r8, #0					// i = 0 - Variable loop				

clockLoop:
	mov	r0, #6000
	bl	delayMicroseconds			// Wait 6us
	
	mov	r0, #0
	bl	Write_Clock				// Falling edge
	
	mov	r0, #5000
	bl	delayMicroseconds			// Wait 6us
	
 	bl	Read_Data				// Read bit i

	cmp	r0, #0					// r0 = return value - 0 or 1
	bne	continue				// If r0 != 0: then branch to continue
	cmp	r8,#8 
	moveq	r9,r8
	movne	r7,r8
	movne	r9,#-1  					// Otherwise r0 = 0 and r7(button) = loop counter (i) 
	
continue:
	mov	r0, #1					// Rising edge
	bl	Write_Clock	

	add	r8, #1					// i++
	cmp	r8, #12					// If (i < 12): Branch to clockLoop
	blt	clockLoop				
	mov	r0,r7
	mov	r1,r9					// Return value = buttons = r7. Returns button pressed. 
	pop	{r7,r8,r9,lr}
	mov 	pc,lr

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
// print statements for each input
pressB:	ldr	r0, =buttonB		
	bl	printf					// Prints for button B
	b	userInput	

pressY:	ldr	r0, =buttonY
	bl	printf
	b	userInput				// Prints for button Y

select:	ldr	r0, =slctBtn
	bl	printf
	b	userInput				// Prints for button SELECT

srtBtn:ldr	r0, =strtBtn
	bl	printf				
	b	haltLoop$				// Prints for button START

pressU:	ldr	r0, =joyPadU
	bl	printf					// Prints for button UP
	b	userInput
	
pressD:	ldr	r0, =joyPadD		
	bl	printf					// Prints for button DOWN			
	b	userInput

pressL:	ldr	r0, =joyPadL
	bl	printf					// Prints for button LEFT
	b	userInput

pressR:	ldr	r0, =joyPadR
	bl	printf					// Prints for button RIGHT
	b	userInput

pressA:	ldr	r0, =buttonA
	bl	printf					// Prints for button A
	b	userInput

pressX:	ldr	r0, =buttonX
	bl	printf					// Prints for button X
	b	userInput

left:	ldr	r0, =leftBtn
	bl	printf					// Prints for LEFT-trigger
	b	userInput

right:	ldr	r0, =rghtBtn
	bl	printf					// Prints for RIGHT-trigger
	b	userInput

//checking buttons
message:
	cmp	r1, #0					// Checks if r1 = 0, if pressed B
	beq	pressB	
	
	cmp	r1, #1					// Checks if r1 = 1, if pressed Y
	beq	pressY
	
	cmp	r1, #2					// Checks if r1 = 2, if pressed SELECT
	beq	select	
	
	cmp	r1, #3					// Checks if r1 = 3, if pressed STARTS 
	beq	srtBtn
	
	cmp	r1, #4					// Checks if r1 = 4, if pressed Up-arrow
	beq	pressU
	
	cmp	r1, #5					// Checks if r1 = 5, if pressed Down-arrow
	beq	pressD
	
	cmp	r1, #6					// Checks if r1 = 6, if pressed Left-arrow
	beq	pressL
	
	cmp	r1, #7					// Checks if r1 = 7, if pressed Right-arrow
	beq	pressR
	
	cmp	r1, #8					// Checks if r1 = 8, if pressed A
	beq	pressA
	
	cmp	r1, #9					// Checks if r1 = 9, if pressed X
	beq	pressX
	
	cmp	r1, #10					// Checks if r1 = 10, if pressed Left-trigger
	beq	left
	
	cmp	r1, #11					// Checks if r1 = 11, if pressed Right-trigger
	beq	right
		
*/
haltLoop$:b	haltLoop$

@ Data section
	.section .data

GpioBaseAddr:
	.word
