.global get_combs

.equ wordsize, 4

#void combinationUtil(int arr[], int data[], int start, int end, int index, int r(but really K), int** combs)
combinationUtil:

	#prologue
	push %ebp
	movl %esp, %ebp
	subl $2*wordsize, %esp

	.equ arr, 2*wordsize
	.equ data, 3*wordsize
	.equ start, 4*wordsize
	.equ end, 5*wordsize
	.equ index, 6*wordsize
	.equ r, 7*wordsize
	.equ combs, 8*wordsize
	.equ i, -1*wordsize
	.equ j, -2*wordsize
	#.equ combsIndex, 8*wordsize its in ESI
	push %ebx
	push %esi               #CHECK IF WE SHOULD DO THIS IS COMBINDEX STILL FINE
	push %edi 
	#EBX is index
	#ECX is r
	movl index(%ebp), %ebx	
	movl r(%ebp), %ecx
	#if (index == r)
	cmpl %ebx, %ecx
	jnz else

	#    int j;
    #for (j = 0; j < r; j++)
    #{
    #  combs[*combsIndex][j] = data[j]; 
   # }
    #*combsIndex = *combsIndex + 1;
    #return;
  #}

	movl $0, %ebx # j is ebx, r is ecx
	for_loop:
	    cmpl %ecx, %ebx #I JUST SWITCHED THIS
	    jge end_for_loop

	    movl data(%ebp), %edx #edx is data
	    movl (%edx, %ebx, wordsize), %edx #edx is data[j]
	    movl combs(%ebp), %eax #eax has combs
	    movl (%eax, %esi, wordsize), %eax #eax has combs[*combsIndex]
	    movl (%eax, %ebx, wordsize), %eax #eax has combs[*combsIndex][j]
	    movl %edx, %eax #combs[*combsIndex][j] = data[j]

	    incl %ebx
	    jmp for_loop
	  end_for_loop:

	  incl %esi
	  jmp end_else

	else:
	#  for (i = start; i <= end && end - i + 1 >= r - index; i++)
	top_for_loop:
	movl start(%ebp), %ebx # i is ebx
	movl end(%ebp), %edx # end is in edx, r is in ecx
	movl index(%ebp), %edi # index is edi

	cmpl %ebx, %edx # end - i
	jg end_else

	subl %ebx, %edx  #end - i 
	incl %edx # edx has end - i + 1
	subl %edi, %ecx #ecx has r - index
	#cmpl %ecx, %edx #(end - i + 1) - (r - index)
	jl end_else

	#ebx is i
	#edi is index
	movl data(%ebp), %ecx #ecx is data
	movl arr(%ebp), %edx #edx is arr
	movl (%edx, %ebx, wordsize), %edx #edx is arr[i]
	movl (%ecx, %edi, wordsize), %ecx #ecx is data[index]
	movl %edx, %ecx # data[index] = arr[i]

	movl combs(%ebp), %ecx
	push %ecx #pushed combs
	movl r(%ebp), %ecx
	push %ecx #pushed r
	movl index(%ebp), %ecx
	incl %ecx
	push %ecx #pushed index + 1
	movl end(%ebp), %ecx
	push %ecx #pushed end
	movl %ebx, %ecx
	incl %ecx
	push %ecx #pushed i + 1
	movl data(%ebp), %ecx
	push %ecx #pushed data
	movl arr(%ebp), %ecx
	push %ecx #pushed arr
	movl %ebx, i(%ebp)
	call combinationUtil
	addl $7*wordsize, %esp
	movl i(%ebp), %ebx
	incl %ebx
	jmp top_for_loop



	end_else:
	#epilogue
	pop %ebx
	pop %esi
	pop %edi

	movl %ebp, %esp
	pop %ebp
	ret

get_combs:

	#prologue
	push %ebp
	movl %esp, %ebp
	subl $5*wordsize, %esp

	.equ items, 2*wordsize
	.equ k, 3*wordsize
	.equ len, 4*wordsize
	.equ data, -1*wordsize
	.equ combs, -2*wordsize
	.equ j, -3*wordsize
	.equ combsIndex, -4*wordsize
	.equ x, -5*wordsize

	push %ebx
	push %esi

	#ESI is combsIndex
	#EBX is num_combinations

	#allocating room for data
	movl $0, %esi
	movl k(%ebp), %eax
	push %eax
	call malloc	
	addl $1*wordsize, %esp
	movl %eax, data(%ebp)
	
	#get num_combs
	movl k(%ebp), %eax
	movl len(%ebp), %ebx
	push %eax
	push %ebx
	call num_combs
	addl $2*wordsize, %esp #clear the stack
	movl %eax, x(%ebp) #move num_combs back to stack

	#combs = malloc(x * sizeof(int*));
	shll $2, %eax
	push %eax
	call malloc
	addl $1*wordsize, %esp #clear the stack
	movl %eax, %ebx #ebx has combs

	movl $0, %edx #j has edx

	#malloc(y * sizeof(int));
	movl k(%ebp), %ecx #ecx has k  #IS K CHANGING 
	shll $2, %ecx
	push %ecx #ecx now has K * sizeof(int)

	#for (j = 0; j < x; j++)
	row_loop:
	cmpl x(%ebp), %edx  
	jge end_row_loop
		#combs[j] =  malloc(y * sizeof(int));
		movl %edx, j(%ebp)
		movl %ebx, combs(%ebp)
		call malloc
		movl j(%ebp), %edx
		movl combs(%ebp), %ebx
		movl %eax, (%ebx, %edx, wordsize)

		incl %edx
		jmp row_loop
	end_row_loop:
	#
	#ebx has combs
	addl $1*wordsize, %esp

	#combinationUtil(items, data, 0, len-1, 0, y, combs);
	push %ebx # push combs
	movl k(%ebp), %ebx
	push %ebx # push k (y)
	movl $0, %ebx
	push %ebx # push 0
	movl len(%ebp), %ebx
	decl %ebx
	push %ebx #push len - 1
	movl $0, %ebx
	push %ebx #push 0
	movl data(%ebp), %ebx
	push %ebx #push data
	movl items(%ebp), %ebx
	push %ebx #push items

	call combinationUtil
	addl $7*wordsize, %esp # clear everything up 
	movl combs(%ebp), %eax
	#epilogue
	pop %ebx
	pop %esi

	movl %ebp, %esp
	pop %ebp
	ret
