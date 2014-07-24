
.text

.global _start              	# make _start label visible to linker

_start:				# main label
	
				# init SDL
	mov	sw, %rdi	# arg 1: width
	mov	sh, %rsi	# arg 2: height
	call 	g_init		# call graphics init routine
	
	push	%rbp		# set up stack base pointer
	mov	%rsp, %rbp
	sub	$68, %rsp	# make space on the stack for the
				# snake array, 64 bytes -> 32 segments
				# 2 bytes for apple + 2 bytes length
	movw	$0x0a0b, -66(%rbp) 	# add first apple
	movw	$4, -68(%rbp)		# set start length to 1
	movw	$0x0a0a, -1(%rbp)	# start (x, y) = (10, 10)
	
run:					
	call 	SDL_GetTicks	
	push	%rax		# store loop counter

event:
				# poll for new user interaction
	sub	$32, %rsp	  # make space for the event struct
	lea	(%rsp), %rdi	  # arg 1: event struct
	call 	SDL_PollEvent	  # returns 1 if events to poll -> %rax
	movzb	(%rsp), %rcx	  # event.type -> %rcx
	
				# handle quit event
	mov	$12, %rdx	  # 12 = quit
	cmp	%rcx, %rdx	  # if equal
	je	exit		  # exit program

				# handle key press events
	mov	8(%rsp), %ebx	  # store key code in ebx
	cmp	$274, %ebx	  # down pressed ?
	je	down
	cmp	$273, %ebx	  # up pressed ?
	je	up
	cmp	$275, %ebx	  # right pressed ?
	je	right
	cmp	$276, %ebx	  # left pressed ?
	je	left

done:
	add	$32, %rsp	# restore stack pointer

				# determine segment to visit next
	movb	(%rbp), %dl	  # x coordinate -> %dl
	add	dirx, %dl	  # compute new x coord
	and	$63, %dl	  # mask 
	movb	-1(%rbp), %dh	  # y coordinate -> %dh
	add	diry, %dh	  # compute new y coord
	and	$63, %dh	  # mask
				# check if the snake is about to
				# eat an apple
	movw	-66(%rbp), %ax 	# load apple -> %ax
	cmp	%ax, %dx	# compare apple with next segment
	jne 	noeat		# if not on apple skip the following
	add	$1, -68(%rbp)	# add snake length by one
	imul	ra, %ax		# generate new 'random' apple by LCG:
	add	rc, %ax		# r_next = ra * r_prev + rc
	and	$63, %al
	and 	$63, %ah	
	movw	%ax, -66(%rbp)	# store new apple

noeat:	
				# move snake one segment
				# shift present segments
	mov	$32, %rcx	# 32 segments to shift
	lea	-64(%rbp), %rax	# start with the 'tail'

shift:
	movw	2(%rax), %bx
	movw	%bx, (%rax)
	add	$2, %rax	
	loop	shift
				# add new segment (stored in %dx)
	movb	%dl, (%rbp)	# x
	movb	%dh, -1(%rbp)	# y
	
				# draw content
	mov	%rbp, %rdi	# arg 1: snake array
	movzb	-68(%rbp), %rsi	# arg 2: length
	call 	g_draw
				# regulate frame rate
	call 	SDL_GetTicks
	pop 	%rbx		# get start tick
	sub	%rbx, %rax	# compute execution time
	mov	$50, %rdi	# set frame time to 50 ms <-> 20 fps
	sub	%rax, %rdi	# compute time to wait
	call	SDL_Delay	# wait
	

	jmp 	run		# loop until user closes window

exit:				# exit
	call 	SDL_Quit
	mov    	$0,%rbx         # first argument: exit code
	mov    	$1,%rax         # system call number (sys_exit)
	int     $0x80           # call kernel

down:
	movq	$0, dirx
	movq	$1, diry
	jmp	done
up:
	movq	$0, dirx
	movq	$-1, diry
	jmp	done
left:
	movq	$-1, dirx
	movq	$0, diry
	jmp	done
right:
	movq	$1, dirx
	movq	$0, diry
	jmp	done


.data	                        # data section
	
sw:				# window width
	.quad	256
sh:				# window height
	.quad	256
dirx:				# current x direction
	.quad	1
diry:				# current y direction
	.quad	0	
				# constants for generating 'random' numbers
ra:
	.long	1664525		  # multiplier
rc:
	.long	1013904223	  # increment
