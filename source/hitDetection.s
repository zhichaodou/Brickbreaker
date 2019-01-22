//Version: Mar 30 2017
//Creators: Stackoverflow

	.section .text

	.global walls
//check to see if the ball is on the verge of hitting the wall or the roof
walls:	push	{r4-r9,lr}
	
	ldr	r4,=ballm
	cmp 	r0,#74
	blt 	less
	cmp 	r0,#500
	bgt 	greater
	cmp	r1,#140
	bgt	done

//	ldr	r5,=increball
//	ldr	r5,[r5,#4]
	mov	r5,#10
//	mov	r6,#1
	str	r5,[r4,#4]
	b	done

less:
	ldr	r5,=increball
	ldr	r5,[r5]
//	mov 	r5,#5
	str	r5,[r4]
	b	done

greater:
	ldr	r5,=increball
	ldr	r5,[r5,#4]
//	ldr	r0,=ballm
	str	r5,[r4]
	b	done
done:	
	
	pop	{r4-r9,lr}
 	mov 	pc,lr

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

	.global collisionDetect
//checks the y value of the balls curretn state 
//if the y value is in a state of where its possible to see if the block can be broken  
// Repeated for each of the 6 rows
collisionDetect:

	push {r5-r9, lr}
	
	Xcoord	.req	r5
	Ycoord	.req	r6

	mov	Xcoord, r0
	mov	Ycoord, r1

	mov	r7,#315					// Row 6
	cmp	Ycoord, r7
	bgt	skip					// Check if the ball is in that range for the row,

////////////////////////////////////////////////
	mov	r7, #273
	cmp	Ycoord, r7	
	ble	y2
///////////////////////////////////////////////

	mov	r0,#20
	mov	r1,Xcoord
	bl	findX					// THen find which block is in contact with the ball

y2:	mov	r7, #290				// Row 5
 	cmp	Ycoord, r7
	bgt	skip
	
/////////////////////////////////////////////	
	mov	r7, #250
	cmp	Ycoord, r7	
	ble	y3
/////////////////////////////////////////////

	mov	r0,#16
	mov	r1, Xcoord
	bl 	findX

y3:	mov	r7, #270				// Row 4
	cmp	Ycoord, r7	
	bgt	skip	

/////////////////////////////////////////////	
	mov	r7, #210
	cmp	Ycoord, r7	
	ble	y4
/////////////////////////////////////////////

	mov	r0,#12
	mov	r1, Xcoord
	bl 	findX

y4:	cmp	Ycoord, #240				// Row 3
	bgt	skip	


/////////////////////////////////////////////	
	mov	r7, #180
	cmp	Ycoord, r7	
	ble	y5
/////////////////////////////////////////////

	mov	r0,#8
	mov	r1, Xcoord
	bl 	findX

y5:	cmp	Ycoord, #220				// Row 2
	bgt	skip	

/////////////////////////////////////////////	
	mov	r7, #154
	cmp	Ycoord, r7	
	ble	y6
/////////////////////////////////////////////

	mov	r0,#4
	mov	r1, Xcoord
	bl 	findX

y6:	cmp	Ycoord, #209				// First row = bottom row
	bgt	skip	
	mov	r0,#0
	mov	r1, Xcoord
	bl 	findX

skip:
	.unreq	Xcoord
	.unreq	Ycoord		

	pop	{r5-r9,pc}
 	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Deflects the ball when a block is hit	
//by reversing the y axis 
deflect:
	push 	{r4-r9,lr}
	ldr	r4,=ballm				// Load the current ball movement
	mov	r5,#10
//	ldr	r5,=increball
//	ldr	r5,[r5]
	ldr	r2,[r4,#4]
	cmp	r5,r2
	ble	negate
	str	r5,[r4,#4]
	b 	complete
	
negate:	mov	r5,#-10
	ldr	r4,=ballm
	//ldr	r5,[r5,#4]
	str	r5,[r4,#4]
	b	complete
	
complete:
	bl	setScore				// redraw the background, set the score cuz the block was hit
	ldr	r0, =background
	mov	r1, #50 
	mov	r2, #50
	mov	r3, #500
	mov	r4, #600
	bl	DrawImage
	bl	drawGrid				// Erase the block that was hit
	pop 	{r4-r9,lr}


	mov	pc,lr


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Starts the process of seeing if any bricks need to be broken
//simply checks each part of the array which hlds the nstate of the block
breaker:

	push	{r4-r9, lr}

	mov	r5, r1

	ldr	r7, =allRows
	ldr	r8, [r7, r0]			// row 1	
	ldr	r9, [r8, r5]			//load number

	cmp	r9,#9				// check if there is a value pack
	beq	fPack
	cmp	r9,#8
	bne	nValue
	mov	r0,#4
	bl	sValue
	b	change

fPack:	mov 	r0,#0
	bl	sValue

change:	
	mov	r9,#1

nValue:	sub	r9, r9, #1			// Break the value pack and break the brick
	str	r9, [r8, r5]
	cmp	r9,#0
	blt	finisd
	bl	deflect

finisd:	
	pop	{r4-r9, pc}	

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//find which x is being hit if any x is being hit at all
//relates to only the block hit detection
// Specfic range for each block
findX:
	push	{r4-r9, lr}

	row	.req	r5
	Xcoord	.req	r6
	
	mov	Xcoord, r1
	mov	row, r0
		
	cmp	Xcoord, #118				// Block 0 - first block
	mov	r0, row
	mov	r1, #0
	bge	x2	
	bl	breaker

	b	fin
	

x2:	cmp	Xcoord, #164				// Block 1 - check if hit and then break if it was	
	mov	r0, row
	mov	r1, #4
	bge	x3
	bl	breaker					// Break the block if the ball is in range

	b	fin

x3:	cmp	Xcoord, #210				// Block 2
	mov	r0, row
	mov	r1, #8
	bge	x4
	bl	breaker

	b	fin

x4:	cmp	Xcoord, #256				// Third block
	mov	r0, row
	mov	r1, #12
	bge	x5
	bl	breaker

	b	fin
	
x5:	mov	r7, #302				// 4th block
	cmp	Xcoord, r7	
	mov	r0, row
	mov	r1, #16
	bge	x6
	bl	breaker

	b	fin

x6:	cmp	Xcoord, #348				// fifth block
	mov	r0, row
	mov	r1, #20
	bge	x7
	bl	breaker

	b	fin

x7:	mov	r7, #394				// Block 6
	cmp	Xcoord, r7
	mov	r0, row
	mov	r1, #24
	bge	x8
	bl	breaker

	b	fin

x8:	cmp	Xcoord, #440				// Block 7
	mov	r0, row
	mov	r1, #28
	bge	x9
	bl	breaker

	b	fin
	
x9:	mov	r7, #486				// BLock 8
	cmp	Xcoord, r7	
	mov	r0, row
	mov	r1, #32
	bge	x10
	bl	breaker

	b	fin
	
x10:	cmp	Xcoord, #532				// Block 10 
	mov	r0, row
	mov	r1, #36
	bge	fin
	bl	breaker

fin:	.unreq	row
	.unreq	Xcoord
	pop	{r4-r9, pc}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

	.global paddleDetect

//r0 is x cord of ball
//r1 is y cord of ball
//r2 is the x cord of the paddle
//detects if the padddle and the ball are about to make contact 	
paddleDetect:

	push {r4-r9,lr}

	mov	r5,#1
	mov	r4,#600
	cmp	r1,r4
	blt	noHit		
	cmp	r1,#620
	bgt	dead
	cmp	r0,r2
	blt	noHit
	add	r2,#60
	cmp	r0,r2
	bgt	noHit

	ldr	r0,=ballm
	//	mov	r1,#-10
	ldr	r1,=increball
	ldr	r1,[r1,#4]
	str	r1,[r0,#4]
//	mov	r0,#1
	b	noHit

dead:	ldr	r0, =lives
	ldrb	r1, [r0]
	sub	r1, #1
	strb	r1, [r0]
	mov	r5,#0
	
noHit:
	mov	r0,r5
	pop	{r4-r9,lr}
	mov 	pc,lr

sValue:
	push	{r4-r9,lr}
	ldr	r4,=valueState
	mov	r1,#1
	str	r1,[r4,r0]

	mov	r0,#1
	pop	{r4-r9,pc}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

	.global startValue
//Draws the value pack when needed 
//also takes care of drawing the previous value packs so no
//duplicates occur
startValue:
	push	{r4-r9,lr}
	mov	r7,r0		//argument should contain 74
	mov	r9,r1
	ldr	r0, =paddleMerge
	ldr	r2,=valueY
	ldr	r1,[r2,r9]
	mov	r2,r7
//	ldr	r8,=valueY
//	ldr	r2,[r8,r9] 
//	mov	r2,r8
	mov	r3,#60
	mov	r4,#11	


	ldr	r0,=valueY
	ldr	r5,[r0,r9]

	ldr	r0, =packMerge
	mov	r1, r5
	mov	r2, r7
	mov	r3, #40
	mov	r4, #13
	bl	DrawImage

	ldr	r0,=valueY
	ldr	r5,[r0,r9]

	add	r5,#5
	str	r5,[r0,r9]
	ldr	r0, =valuePack
	mov	r1, r5
	mov	r2, r7
	mov	r3, #40
	mov	r4, #13
	bl	DrawImage

	pop	{r4-r9,pc}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

	.global valueDetect

//r0 contains x of paddle
valueDetect:

	//	r0 will be the start if the x value 
	//	r1 will be the offset
	//	r2 will be the paddle x
	push	{r4-r10,lr}
	mov	r10,r0		//should be 70
	mov	r6,r2
	mov	r7,#40
	ldr	r9,=valueY
	ldr	r7,[r9,r1]
	cmp	r7,#600
	bne	notYet
	cmp	r6,r10 	//make range not exact
	blt	gone
	add	r10,#80
	cmp	r6,r10
	bgt	gone
	mov	r8,#2
	ldr	r4,=valueState
	str	r8,[r4,r1]
	b	notYet
gone:
	ldr	r4,=valueState
	mov     r8,#0
	str	r8,[r4,r1]

notYet:
	pop	{r4-r10,pc}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
