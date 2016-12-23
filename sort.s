
.global sort

.equ wordsize, 4

#sort(int*, int)
sort:

	#prolouge
	pushl %ebp
	movl %esp, %ebp
	subl $1*wordsize, %esp

	#formal parameters
	.equ arr, 2
	.equ len, 3
	.equ temp, -1
	
	pushl %esi	#esi = i
	pushl %edi	#edi = j
	pushl %eax	#eax = arr
	pushl %ebx	#ebx = len

	movl arr(%ebp), %eax	#eax = arr
	

	movl $0, %esi
	
	FORWARD_LOOP:
		incl %esi
		cmpl %esi, len(%ebp)	#i < len
		jz END	#i = 1 <-- start

		movl %esi, %edi	#j = i
		push (%esi)	#save i
	BACKWARD_LOOP:
		cmpl $1, %edi	# j >= 1
		jz FORWARD_LOOP
		
		movl %edi, temp(%ebp)		#temp = j
		decl temp(%ebp)			#temp -= 1
		movl temp(%ebp), %esi		#esi = edi(j) - 1
		
		movl (%eax, %edi, wordsize), %ebx	# ebx = arr[j]

		cmpl %ebx, (%eax, %esi, wordsize) # (arr[j-1] - arr[j]) gt ->>
		

		jle SKIP

		movl %ebx, temp(%ebp)		#temp = arr[j]
		movl (%eax, %esi, wordsize), %ebx	#arr[j] = arr[j-1]
		

		movl temp(%ebp), %ebx		# ebx = temp
		movl %ebx, (%eax, %esi, wordsize)	# arr[j - 1] = ebx
		

		jmp END_BACK	#go to top of loop 
		
	SKIP:
		pop (%esi)	#get i back
		jmp FORWARD_LOOP


	END_BACK:
		dec %edi	#j--
		jmp BACKWARD_LOOP
		

END:
	popl %ebx
	popl %eax
	popl %edi
	popl %esi

	movl %ebp, %esp
	popl %ebp
	
	ret
















