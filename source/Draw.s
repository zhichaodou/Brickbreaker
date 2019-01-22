
	.section .text
	
@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour

DrawPixel:

	push	{r4, r5}
		
	Xcoord	.req	r0
	Ycoord	.req	r1
	colour	.req	r2
	offset	.req	r4
	fbAddr	.req	r5

	ldr		fbAddr, =frameBufferInfo	

	@ offset = (y * width) + x
	
	ldr	r3, [fbAddr, #4]				@ r3 = width
	mul	Ycoord, r3
	add	offset,	Xcoord, Ycoord
	
//	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl	offset, #2

	@ store the colour (word) at frame buffer pointer + offset
	ldr	Xcoord, [fbAddr]				@ r0 = frame buffer pointer
	str	colour, [Xcoord, offset]

	.unreq	Xcoord
	.unreq	Ycoord
	.unreq	colour
	.unreq	fbAddr

	pop	{r4, r5}
	bx	lr

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	.global DrawImage
DrawImage:
	push	{r4-r11, lr}	
	imgAddr	.req	r4
	px	.req	r5
	py	.req	r6
	Xcoord	.req	r7
	Ycoord	.req	r8	
	width	.req	r9					// These two are the size of the image x and y respectively
	height	.req	r10

	mov	width,r3
	mov 	height,r4
	mov	imgAddr, r0					// Load the address of the image
	mov	py, #0

	mov	Ycoord, r1
	mov	r11, r2

charLoop:
	mov	px, #0						@ init the X coordinate
	mov	Xcoord, r11

rowLoop:
	cmp	px, width					// Compare pixels drawn with image width
	beq	nextRow
	
	mov	r0, Xcoord					// First argument:  x-coordinate
	mov	r1, Ycoord					// Second argument: y-coordinate
	ldr	r2, [imgAddr], #4				// Load colour from image 
	bl	DrawPixel					// Draw pixel on screen

	add	px, #1						// Increment pixels drawn
	add	Xcoord, #1					// Increment the x position on screen
	bl	rowLoop						// Branch to rowLoop

nextRow:
	add	py, #1						// Increment pixels drawn vertically
	add	Ycoord, #1					// Increment y coordinate
	cmp	py, height					// Compare with image height
	beq	end						
	bl	charLoop

end:	.unreq	imgAddr
	.unreq	px
	.unreq	py
	.unreq	Xcoord
	.unreq	Ycoord
	.unreq	width
	.unreq	height

	pop	{r4-r11, pc}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

.global DrawChar

@ Draw the character 
DrawChar:
	push	{r4-r9, lr}

	chAdr	.req	r4
	px	.req	r5
	py	.req	r6
	row	.req	r7
	mask	.req	r8
	xPos	.req	r9

	ldr	chAdr, =font					@ load the address of the font map
	mov	r0, r1						@ load the character into r0
	add	chAdr,	r0, lsl #4				@ char address = font base + (char * 16)

	mov	py, r2						@ init the Y coordinate (pixel coordinate)

	mov	xPos, r3

charLoop$:
	mov	px, xPos					@ init the X coordinate

	mov	mask, #0x01					@ set the bitmask to 1 in the LSB
	
	ldrb	row, [chAdr], #1				@ load the row byte, post increment chAdr

rowLoop$:
	tst	row,mask					@ test row byte against the bitmask
	beq	noPixel$

	mov	r0, px
	mov	r1, py
	mov	r2, #0xFFFFFFFF					@ white
	bl	DrawPixel					@ draw white pixel at (px, py)

noPixel$:
	add	px, #1						@ increment x coordinate by 1
	lsl	mask, #1					@ shift bitmask left by 1

	tst	mask,#0x100					@ test if the bitmask has shifted 8 times (test 9th bit)
	beq	rowLoop$

	add	py, #1						@ increment y coordinate by 1

	tst	chAdr, #0xF
	bne	charLoop$					@ loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask
	.unreq	xPos

	pop	{r4-r9, pc}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	.global drawGrid
drawGrid:
	push 	{r5-r12, lr}
	mov	r11, #0						// Offset for the arrays
	mov	r12, #178					// Y-position of bricks

again:	ldr	r8, =allRows					// load all rows
	ldr	r10, =bricks					// load all colours

	cmp	r11, #24
	bge	finish
	ldr	r10, [r10, r11]					// load colour
	
	beq	finish
	mov	r7, #0						// Counter
			
	ldr	r5, [r8, r11]					// Load row


	mov	r9, #74						// X-position of brick 
draw:	ldr	r6, [r5], #4					// Load index from 1st row 
	cmp	r6, #0						// If there is a 0, then dont draw that brick
	ble	skip						// 
	mov	r0, r10
	mov	r1, r12
	mov	r2, r9
	mov	r3, #40
	mov	r4, #18

	bl	DrawImage					// Draw the brick with the loaded colour

skip:	cmp	r7, #9
	add	r7, #1
	add	r9, #46						// Loop through all the rows and load the specific colours
	blt	draw
	add	r11, #4
	add	r12, #22
	bl	again
	
finish:	pop	{r5-r12,pc}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	.global checkGameOver

checkGameOver:

	push	{r5-r11, lr}

	mov	r11, #0						// Offset for the arrays

again1:	ldr	r8, =allRows					// load all rows

	cmp	r11, #24
	bge	perfect	

	mov	r7, #0						// Counter
			
	ldr	r5, [r8, r11]					// Load row

draw2:
	ldr	r6, [r5], #4					// Load index from that row
	cmp	r6, #0						// If there is a number in that row > 0 then game not over yet
	bgt	continue

skip1:	cmp	r7, #9						
	add	r7, #1

	blt	draw2
	add	r11, #4

	bl	again1						// Keep checking all the rows
	mov	r0, #1

perfect:mov	r0, #1						// Return 1 ig gameOver = True 

continue:
	pop	{r5-r11, pc}

	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	.global setScore

setScore:
	push	{r5-r9, lr}

	digit	.req	r6
	oValue	.req	r7
	value	.req	r8

	mov	digit, #3					// Place value -- max score = 4 digit number

write:
	ldr	r5, =score
	ldrb	value, [r5, digit]				// Load the first char from score -- start from first digit

	mov	oValue, value					// save the original value
	
	cmp	value, #'5'					// If the digit is a 5, change it to 0 now
	beq	zero
	
	mov	value, #'5'					// Otherwise change it to 5
	b	store

zero:	mov	value, #'0'
	
store:	strb	value, [r5, digit]				// Store the digit back

	cmp	oValue, #'0'					// Increment the next digit only if needed (if original value was 5)
	beq	free
	
check:	cmp	digit, #3
	bgt	free

	ldr	r5, =score					// Load the next digit
	sub	digit, #1
	ldrb	value, [r5, digit]

	cmp	value, #'9'					// If it is a 9 then change it to 0 and add 1 to the next digit
	beq	inc
	add	value, #1
	strb	value, [r5,digit]
	b	free

inc:	mov	value, #'0'				
	strb	value, [r5, digit]
	b	check

free:	.unreq	digit
	.unreq	oValue
	.unreq	value	
	pop	{r5-r9, pc}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	.global initGrid

initGrid:
	push	{r5-r9, lr}
	

		
	mov	r11, #0						// Offset for the arrays

nRow:	ldr	r8, =allRows					// load all rows

	cmp	r11, #24
	bge	back	

	mov	r7, #0						// Counter
			
	ldr	r5, [r8, r11]					// Load row

	cmp	r11, #0						// Row 1 - level 3 brick
	beq	first

	cmp	r11, #4						// Row 2 - level 3 brick
	beq	first	

	cmp	r11, #8						// Row 3 - level 2 brick
	beq	third

	cmp	r11, #12					// Row 4 - level 2 brick
	beq	third
				
	cmp	r11, #16					// Row 5 - level 1 brick
	beq	sixth

	cmp	r11, #20					// Row 6 - level 1 brick
	beq	sixth		

sixth:
	cmp	r7, #0						// Special case for the value packs
	beq	sp8

	cmp	r7, #9						// In position 9 in the last row 
	beq	sp9

	mov	r6, #1
	str	r6, [r5], #4					// Load index from 1st row 

	cmp	r7, #9						// Loop 10 times for each of the 10 bricks
	add	r7, #1

	blt	sixth
	add	r11, #4

	bl	nRow
sp8:
	mov	r6, #9
	str	r6, [r5], #4					// Load index from row 

	cmp	r7, #9
	add	r7, #1

	blt	sixth
	add	r11, #4

	bl	nRow

sp9:
	mov	r6, #8						// level 3 bricks
	str	r6, [r5], #4					// Load index from row 

	cmp	r7, #9
	add	r7, #1

	blt	sixth
	add	r11, #4

	bl	nRow




first:	mov	r6, #3						// All bricks in this row are level 3
	str	r6, [r5], #4					// Load index from row 

	cmp	r7, #9
	add	r7, #1

	blt	first
	add	r11, #4

	bl	nRow
	
third:	mov	r6, #2						// All bricks in this row are level 2 
	str	r6, [r5], #4					// Load index from row 

	cmp	r7, #9
	add	r7, #1

	blt	third
	add	r11, #4

	bl	nRow



back:	pop	{r5-r9, pc}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	@ Data section
	.section .data

	.align 4
	.global frameBufferInfo

frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height

	.align 4
font:	.incbin	"font.bin"
