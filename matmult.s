
.global matMult

.equ wordsize, 4

matMult:

	#prologue
	push %ebp
	movl %esp, %ebp
	subl $4*wordsize, %esp

	#cols_mat_b + 24
	#rows_mat_b + 20 
	#mat_b + 16
	#cols_mat_a +12
	#rows_mat_a +8
	#mat_a + 4
	#old ebp

	.equ mat_a, 2*wordsize
	.equ rows_mat_a, 3*wordsize
	.equ cols_mat_a, 4*wordsize
	.equ mat_b, 5*wordsize
	.equ rows_mat_b, 6*wordsize
	.equ cols_mat_b, 7*wordsize
	.equ mat_c, -1*wordsize
	.equ i, -2*wordsize
	.equ j, -3*wordsize
	.equ sum, -4*wordsize

	push %ebx
	push %esi

	#eax will be c
	#ecx is i
	#edx is j

	#in matadd, matt pushes in %ebx and %esi

	movl rows_mat_a(%ebp), %eax
	shll $2, %eax
	push %eax #push into mat_c
	call malloc
	addl $1*wordsize, %esp

	#malloc'd c for rows
	movl %eax, mat_c(%ebp)

	movl $0, %ecx 

	#start the malloc
	movl cols_mat_b(%ebp), %ebx
	shll $2, %ebx
	push %ebx

	row_loop:
		cmpl rows_mat_a(%ebp), %ecx
		jge end_row_loop

		movl %ecx, i(%ebp)

		call malloc

		#c[i]= malloc(cols_mat_b * sizeof(int))
		movl mat_c(%ebp), %edx #restore into register    #why the edx? what does malloc restore? Isn't it in eax?
		movl i(%ebp), %ecx
		movl %eax, (%edx, %ecx, wordsize)
		movl %edx, %eax #%eax now has c
		#movl %eax, mat_c(%ebp)

		movl $0, %edx

		col_loop:
			cmpl cols_mat_b(%ebp), %edx
			jge end_col_loop

			#%esi will be the sum
			#%edi will be the K
			movl $0, sum(%ebp)
			movl $0, %edi

			last_loop:
				cmpl cols_mat_a(%ebp), %edi
				jge end_last_loop

				movl mat_a(%ebp), %esi
				movl (%esi, %ecx, wordsize), %esi
				movl (%esi, %edi, wordsize), %esi # A[i][j]

				movl mat_b(%ebp), %ebx
				movl (%ebx, %edi, wordsize), %ebx
				movl (%ebx, %edx, wordsize), %ebx #esi is B[i][j]

				movl %eax, mat_c(%ebp) # this might fuck something up but it saves c
				movl %edx, j(%ebp) #saves j

				movl %esi, %eax
				mull %ebx 

				addl %eax, sum(%ebp) #sum = sum +a[i][j] * b[i][j]
				movl mat_c(%ebp), %eax  #restore C
				movl j(%ebp), %edx  #restore j


				incl %edi
				jmp last_loop
			end_last_loop:

			movl (%eax , %ecx, wordsize), %esi #esi = c[i]
			movl sum(%ebp), %ebx #ebx is the sum
			movl %ebx, (%esi, %edx, wordsize) # c[i][j] = sum


			incl %edx
			jmp col_loop
		end_col_loop:

		incl %ecx
		jmp  row_loop
	end_row_loop:

	addl $1*wordsize, %esp

	#epilogue
	pop %esi
	pop %ebx

	movl %ebp, %esp
	pop %ebp
ret

