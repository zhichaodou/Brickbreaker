	.section .text
	
	.global startBall
//r0 will contain paddlex
//r1 will contain ballx
startBall:
	push 	{r4-r9,lr}
	mov	r5,r0
	mov	r6,r1
kickOff:	
	bl 	getSnes
	cmp	r0,#0
	beq	perfected				// If the ball is released from start
	cmp	r0,#7
	beq	Mright
	cmp	r0,#6
	beq	Mleft
	b	kickOff					// Otherwise keep looping until player releases ball then start game

Mright:
	ldr	r0, =paddleMerge
	mov	r1, #600				// Set X position of image
	mov	r2, r5					// Set Y position of image -- starting position
	mov 	r3, #60					// Image Width
	mov 	r4, #11					// Image Height  
	bl	DrawImage				// Draw the image

	ldr	r0, =paddleMerge
	mov	r1, #590				// Set X position of image
	mov	r2, r6					// Set Y position of image -- starting position
	mov 	r3, #10					// Image Width
	mov 	r4, #10					// Image Height  
	bl	DrawImage				// Draw the image
	mov	r4, #480
	cmp	r6, r4
	bgt	staleMate
	add	r6,#10
	add	r5,#10
	b	staleMate

Mleft:	ldr	r0, =paddleMerge
	mov	r1, #600				// Set X position of image
	mov	r2, r5					// Set Y position of image -- starting position
	mov 	r3, #60					// Image Width
	mov 	r4, #11					// Image Height  
	bl	DrawImage
	
	ldr	r0, =ballMerge
	mov	r1, #590				// Set X position of image
	mov	r2, r6					// Set Y position of image -- starting position
	mov 	r3, #10					// Image Width
	mov 	r4, #10					// Image Height  
	bl	DrawImage				// Draw the image

	cmp	r6,#106
	blt	staleMate
	sub	r6,#10
	sub	r5,#10

staleMate:
	ldr	r0, =ball
	mov	r1, #590
	mov	r2, r6
	mov	r3, #10
	mov	r4, #10
	bl	DrawImage				// Draw ball on screen 

	ldr	r0, =paddle
	mov	r1, #600				// Set Y position of image
	mov	r2, r5	
	mov 	r3, #60					// Image Width
	mov 	r4, #11					// Image Height  
	bl	DrawImage
	b	kickOff
	
perfected:	
	mov	r0,r5
	mov	r1,r6
	pop	{r4-r9,pc}

	.section .data


	.align 4
	.global ball

ball:
.ascii "\370\370\370\326\311\311\311\354\245\245\245\355\210\210\210\377"
