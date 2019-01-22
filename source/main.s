
	@ Code section
	.section .text

	.global main

main:
	@ ask for frame buffer information
	ldr 	r0, =frameBufferInfo 				@ frame buffer information structure
	bl	initFbInfo

	ballx 	.req	r5					// Set up register for ball x-axis
	bally 	.req	r6					// Set up register for ball y-axis
	
	//mov 	ballx,#500					// Set up initial position x for ball
	//mov 	bally,#550					// Set up initial position y for ball
	
	paddleX .req	r7					// Set up register for paddle x-axis

gameRestart:
	bl	initGrid
		
	mov 	ballx,#175					// Set up initial position x for ball
	mov 	bally,#590					// Set up initial position y for ball
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////START MENU/////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

	mov 	paddleX,#150	

menuSelection:	
	ldr	r0, =mainMenu2
	mov	r1, #50						// Set X position of image
	mov	r2, #50						// Set Y position of image -- starting position
	mov 	r3, #500					// Image Width
	mov 	r4, #600					// Image Height  
	bl	DrawImage					// Draw the image
	mov	r8,#1						// assume start is on "play menu"

getSnesMenuMovement:
	 bl 	getSnes						// Calls the SNES for movement data
	 mov	r10,r1
checkMenuInput:
	cmp 	r0, #4		           			// If player presses up, start at the default state menu  
	beq 	startMenuStart	
	cmp 	r0, #5						// If palyer presses down, jump to draw the quit-start menu
	beq	startMenuQuit
	cmp 	r10,#8
	beq 	check						// If player press "A", check if they are either starting game or quiting
	b 	getSnesMenuMovement				// Else if no input re-check

startMenuStart:
	ldr	r0, =mainMenu2
	mov	r1, #50						// Set X position of image
	mov	r2, #50						// Set Y position of image -- starting position
	mov 	r3, #500					// Image Width
	mov 	r4, #600					// Image Height  
	bl	DrawImage					// Draw the image
	
	mov	r8,#1						// Sets input to for "A" press checking
	b 	getSnesMenuMovement				// Return to check further input

startMenuQuit:
	ldr	r0, =mainMenu
	mov	r1, #50						// Set X position of image
	mov	r2, #50						// Set Y position of image -- starting position
	mov 	r3, #500					// Image Width
	mov 	r4, #600					// Image Height  
	bl	DrawImage					// Draw the image
	
	mov 	r8,#0						// Sets input to for "A" press checking
	b	 getSnesMenuMovement				// Return to check further input

check:
	cmp 	r8, #1						// Checks the input based on the r8, if on "1" then start game
	beq	before2
	cmp	r8, #0						// Else if "o", then jump to quit
	beq	haltLoop$
	b 	getSnesMenuMovement	

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////LEAVING MAIN SCREEN////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
before2:
	ldr	r0, =background
	mov	r1, #50						// Set X position of image
	mov	r2, #50						// Set Y position of image -- starting position
	mov 	r3, #500					// Image Width
	mov 	r4, #600					// Image Height  
	bl	DrawImage					// Draw the image

	bl	drawGrid

	ldr	r0, =paddle
	mov	r1, #600					// Set Y position of image
	mov	r2, paddleX
	mov 	r3, #60						// Image Width
	mov 	r4, #11						// Image Height  
	bl	DrawImage					// Draw the image

	ldr	r0, =ball
	mov	r1, bally					// Set Y position of ball
	mov	r2, ballx					// Set X position of ball
	mov	r3, #10						// Ball Width
	mov	r4, #10						// Ball Height
	bl	DrawImage					// Draw the image

	mov	r0,paddleX
	mov	r1,ballx
	bl	startBall
	mov	paddleX, r0
	mov	ballx, r1
	b	getSnesInput
	
before:	
	mov	r0,#150
	mov	r1,#175
	bl	startBall					// Game doesnt start until player releases the ball
	mov	paddleX, r0
	mov	ballx, r1
	mov	bally, #595
	mov	r1,#-10
	ldr	r2,=ballm					// Get the movements for the ball 
	str	r1,[r2,#4]

	ldr	r0,=valueState					// Move 0 for the 1st value state
	mov	r1,#0
	str	r1,[r0]

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////INPUT FOR MOVEMENT////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
getSnesInput:
	bl	getSnes						// Calls the SNES for movement data
	mov	r10,r1
checkInput:
	cmp	r0,#6						// If input is 6, jump to LeftMove
	beq	leftMove
	cmp 	r0,#7						// If input is 7, jump to RightMove
	beq	rightMove					
	cmp	r0,#3
	beq	startSelectDefault
	bne	skip

rightMove:
	ldr	r0, =paddleMerge
	mov	r1, #600					// Set X position of image
	mov	r2, paddleX					// Set Y position of image -- starting position
	mov 	r3, #60						// Image Width
	mov 	r4, #11						// Image Height  
	bl	DrawImage					// Draw the image
	mov	r8, #465	
	cmp	paddleX,r8
	bgt	bounds
	cmp	r10,#8
	addeq	paddleX,#20
	addne 	paddleX,#10

bounds:
	ldr	r0, =paddle
	mov	r1, #600					// Set Y position of image
	mov	r2, paddleX
	mov 	r3, #60						// Image Width
	mov 	r4, #11						// Image Height  
	bl	DrawImage					// Draw the image
	b 	skip


leftMove:
	ldr	r0, =paddleMerge
	mov	r1, #600					// Set X position of image
	mov	r2, paddleX					// Set Y position of image -- starting position
	mov 	r3, #60						// Image Width
	mov 	r4, #11						// Image Height  
	bl	DrawImage					// Draw the image
	cmp	paddleX,#74
	blt	oBounds
	cmp	r10,#8
	subeq	paddleX,#20
	subne 	paddleX, #10
oBounds:	
	ldr	r0, =paddle
	mov	r1, #600					// Set Y position of image
	mov	r2, paddleX
	mov 	r3, #60						// Image Width
	mov 	r4, #11						// Image Height  
	bl	DrawImage					// Draw the image

	b	skip

	
startSelectDefault:						// Sets up the default for the menu while in-game
	ldr 	r0, =menuRestart
	mov 	r1, #50
	mov 	r2, #50
	mov 	r3, #500
	mov 	r4, #600
	bl 	DrawImage

	mov 	r9, #0

reLoopStartSelect:						// If player presses start,
	bl 	getSnes

	cmp	r0, #4
	beq 	startSelectRestart				// Restart game if restart selected 
 	cmp 	r0, #5
	beq	startSelectQuit					
	cmp 	r1, #8
	beq     startSelectSelection

	cmp	r0, #6
	beq	resetStart					// Check if any other button is pressed

	cmp	r0, #7
	beq	resetStart					// Resume game if anythign else is pressed.

	cmp	r0, #11
	beq	resetStart

	cmp	r0, #10
	beq	resetStart

	cmp	r0, #1
	beq	resetStart

	cmp	r0, #9
	beq	resetStart

	cmp	r0, #2
	beq	resetStart

	cmp	r0, #3
	beq	resetStart

	cmp	r0, #0
	beq	resetStart

	b	reLoopStartSelect				// Wait for selection - keep looping


resetStart:
	
	ldr	r0, =background
	mov	r1, #50						// Set X position of image
	mov	r2, #50						// Set Y position of image -- starting position
	mov 	r3, #500					// Image Width
	mov 	r4, #600					// Image Height  
	bl	DrawImage					// Draw the image

	bl	drawGrid

	ldr	r0, =paddle
	mov	r1, #600					// Set Y position of image
	mov	r2, paddleX
	mov 	r3, #60						// Image Width
	mov 	r4, #11						// Image Height  
	bl	DrawImage					// Draw the image

	ldr	r0, =ball
	mov	r1, bally					// Set Y position of ball
	mov	r2, ballx					// Set X position of ball
	mov	r3, #10						// Ball Width
	mov	r4, #10						// Ball Height
	bl	DrawImage					// Draw the image

	b	getSnesInput
	
startSelectRestart:						// Restart selected, displays the menu for that
	
	ldr 	r0, =menuRestart
	mov 	r1, #50
	mov 	r2, #50
	mov 	r3, #500
	mov 	r4, #600
	bl 	DrawImage					// Draw restart screen

	mov 	r9, #0

	b 	reLoopStartSelect

startSelectQuit:
	
	ldr 	r0, =menuQuit					// Quit menu screen
	mov 	r1, #50
	mov 	r2, #50
	mov 	r3, #500
	mov 	r4, #600
	bl 	DrawImage					// Draw Quit

	mov 	r9, #1

	b 	reLoopStartSelect
	
startSelectSelection:

	cmp 	r9, #0
	beq 	gameRestart					// If restart selected, restart game

	cmp 	r9, #1
	beq	gameOver					// Otherwise blank grid, for quit
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////GAME START/////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

skip:
	
	ldr	r0, =paddle
	mov	r1, #600					// Set X position of image
	mov	r2, paddleX					// Set Y position of image -- starting position
	mov 	r3, #60						// Image Width
	mov 	r4, #11						// Image Height  
	bl	DrawImage					// Draw the image


	mov	r0, ballx
	mov	r1, bally
	bl	collisionDetect					// As soon as the ball moves check for collision

move:	bl	drawGrid					// Draw grid afterwards in case any blocks were hit
	ldr	r0,=valueState
	ldr	r0,[r0]
	cmp	r0,#1
	beq	start1
	
	ldr	r0,=valueState					// Load the values for the ball from memory
	ldr	r0,[r0,#4]
	
	cmp	r0,#1
	bne	shift
	
	mov	r0,#450
	mov	r1,#4
	bl	startValue					// Move the ball and detection contact with paddle
	mov	r0,#450
	mov	r1,#4
	mov	r2,paddleX
	bl	valueDetect
	
	b	shift						// Shift the ball up or down
	
start1:	
	mov	r0,#75
	mov	r1,#0
	bl	startValue
	
	mov	r0,#70
	mov	r1,#0
	mov	r2,paddleX
	bl	valueDetect	
shift:	ldr	r0,=valueState
	ldr	r0,[r0]
	cmp	r0,#2
	bne	wait
	b	before
	
wait:	ldr	r0, =ballMerge					// Overlap the old position of the ball with the background 
	mov	r1, bally
	mov	r2, ballx
	mov	r3, #10
	mov	r4, #10
	bl	DrawImage

	ldr	r0,=valueState
	ldr	r0,[r0,#4]
	cmp	r0,#2
	bne	wait2
	ldr	r0,=increball					// Increment the ball in the same direction
	mov	r1,#5
	mov	r2,#-5
	str	r1,[r0]
	str	r2,[r0,#4]
	
wait2:	bl	drawGrid					// Draw the grid first then move the ball
	mov	r0,ballx
	mov	r1,bally
 	bl 	walls
	ldr	r0,=ballm					// Load the directions for the ball movements
	ldr	r1,[r0]
	add	ballx,r1
	ldr	r1,[r0,#4]
	add	bally,r1

	mov	r0,ballx					// Move the ball and detect if the ball hit the paddle
	mov	r1,bally
	mov	r2,paddleX
	bl	paddleDetect
	cmp	r0,#0
	beq	before

dBall:
	ldr	r0, =ball
	mov	r1, bally
	mov	r2, ballx
	mov	r3, #10
	mov	r4, #10
	bl	DrawImage					// Draw ball

	
	mov	r9, #0
	mov	r8, #480
drawScore:							// Write score
	ldr	r1, =score
	ldrb	r1, [r1, r9]
	mov	r2, #95
	mov	r3, r8
	add	r8, #10
	bl	DrawChar
	cmp	r9, #3
	add	r9, #1
	ble	drawScore					// Loop for each character - 4 times
	

drawLives:
	ldr	r1, =lives					// Image description for lives
	ldrb	r1, [r1]
	mov	r2, #95
	mov	r3, #95
	
	cmp	r1, #'/'					// Char before '0'
	beq	gameOver
	
	bl	DrawChar					// Draw lives left	

	bl	checkGameOver
	
	cmp	r0,#1
	beq	gameOver
	
	b	getSnesInput

// GameOver state: just displays the game without bricks
gameOver:
	ldr	r0, =background
	mov	r1, #50
	mov	r2, #50
	mov	r3, #500
	mov	r4, #600
	bl	DrawImage


@ stop
haltLoop$:
	b	haltLoop$
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

	@ data section
	.section .data

	.global lives
	.align 1
lives:	.byte	'3'

//	.align 4
	.global bricks
bricks:	.word grey, red, orange, pink, yellow, green

	.global score
	.align	1
score:	.byte	'0','0','0','0'
end:

// Used to keep track of each block type
	.align	4
	
row1:	.word	3,3,3,3,3,3,3,3,3,3
		
row2:	.word	3,3,3,3,3,3,3,3,3,3

row3:	.word	2,2,2,2,2,2,2,2,2,2

row4:	.word	2,2,2,2,2,2,2,2,2,2

row5:	.word	1,1,1,1,1,1,1,1,1,1

row6:	.word	9,1,1,1,1,1,1,1,1,8

	.align 4
	.global allRows
allRows: .word row1, row2, row3, row4, row5, row6

	.global ballm
	.global	valueY
	.global	valueState
	.global first
	.global	value2State
	.global	value2y
	.global	increball
	
valueState:
	.word  0,0
	
valueY:	.word 	330,330

	.global endGame
ballm:	.word	10,-10

increball:
	.word	10,-10

endGame:.word 0
