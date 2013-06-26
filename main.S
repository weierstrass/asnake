
.text                           # section declaration

.global _start              	# make _start label visible to linker

_start:				# main label

				# init SDL
	mov	sw, %rdi	# arg 1: width
	mov	sh, %rsi	# arg 2: height
	call 	g_init		# call graphics init routine
	
	push	%rbp		# set up stack base pointer
	mov	%rsp, %rbp
	sub	$64, %rsp	# make space on the stack for the
				# snake array, 64 byte -> 32 segments
	push	$-1		# extra quad for apple -70 and len -72
	movw	$0x0a0b,-70(%rbp) 	# add first apple
	movw	$1, -72(%rbp)		# set start length to 1
	movw	$0x0a0a, -1(%rbp)	# start (x, y) = (10, 10)
	
run:					
	call 	SDL_GetTicks	
	push	%rax		# store loop counter

event:	
	sub	$32, %rsp	# make space for the event struct
	lea	(%rsp), %rdi	# pass stack pointer to pollevent
	call 	SDL_PollEvent	# returns 1 if events to poll (%rax)
	movzb	(%rsp), %rcx	# event.type
	
				# handle quit event
	mov	$12, %rdx	# 12 = quit
	cmp	%rcx, %rdx	# if equal
	je	exit		# jump to exit

				# handle key press events
	mov	8(%rsp), %ebx	# store key code in ebx
	cmp	$274, %ebx	# down pressed ?
	je	down
	cmp	$273, %ebx	# up pressed ?
	je	up
	cmp	$275, %ebx	# right pressed ?
	je	right
	cmp	$276, %ebx	# left pressed ?
	je	left
done:			
	add	$32, %rsp	# restore stack pointer

				# check if there are more events to
				# be polled
	mov	$1, %rdx	
	cmp	$1, %rax 	# if rax == 1 there are more events
	je	event		# poll next event

				# compute segment to visit next
	movb	(%rbp), %dl	# x coordinate
	add	dirx, %dl
	movb	-1(%rbp), %dh	# y coordinate
	add	diry, %dh

				# check if the snake is about to
				# eat an apple
	movw	-70(%rbp), %ax 	# load apple into %ax
	cmp	%ax, %dx	# compare apple with next segment
	jne 	noeat		# if not on apple skip the following
	add	$1, -72(%rbp)	# add snake length by one
	imul	ra, %ax		# generate new 'random' apple by LCG:
	add	rc, %ax		# r_next = ra * r_prev + rc
	movw	%ax, -70(%rbp)	# store new apple

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
	movzb	-72(%rbp), %rsi	# arg 2: length
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
	
# printxy:	
#  	mov    	$clabel,%rdi	# arg 1: format label
#  	mov   	xc,%rsi        	# arg 2: first digit
#  	mov   	yc,%rdx    	# arg 3: second digit
#  	call 	printf		# call printf in clib
#  	ret			# return

ticks:				# get current tick, 64 bit
	xor     %eax, %eax
        cpuid
        rdtsc
	shl 	$32, %rdx
	or 	%rdx, %rax
	ret
.data	                        # data section

clabel:
	.asciz	"(%d, %d)\n"	# coordinate label
	
sw:
	.quad	256
sh:
	.quad	256

dirx:
	.quad	1
diry:
	.quad	0	
sl:
	.quad	64
				# constants for generating 'random' numbers
ra:
	.long	1664525		# multiplier
rc:
	.long	1013904223	# increment
	