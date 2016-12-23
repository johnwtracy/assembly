.global knapsack

.equ wordsize, 4

max:
	#prologue
	push %ebp
	movl %esp, %ebp

	.equ a, 2*wordsize
	.equ b, 3*wordsize
	
	movl a(%ebp), %edx
	cmpl %edx, b(%ebp)
	jg b_is_greater
	  jmp end
	b_is_greater:
	  movl b(%ebp), %edx
	end:
	#epilogue
	movl %ebp, %esp
	pop %ebp
ret




knapsack:

	#prologue
	push %ebp
	movl %esp, %ebp
	subl $2*wordsize, %esp

	.equ weights, 2*wordsize
	.equ values, 3*wordsize
	.equ num_items, 4*wordsize
	.equ capacity, 5*wordsize
	.equ cur_value, 6*wordsize
	.equ i, -1*wordsize
	.equ best_value, -2*wordsize


	movl cur_value(%ebp), %eax
	movl %eax, best_value(%ebp)

	#ESI is i
	#EDX is greater value
	#EAX is best_value
	movl $0, %esi

	top_loop:
	  cmpl num_items(%ebp), %esi
	  jge end_top_loop

	  movl capacity(%ebp), %ebx #ebx has capacity
	  movl weights(%ebp), %ecx #ecx has weights

	  subl (%ecx, %esi, wordsize), %ebx
	  cmpl $0, %ebx
	  jl end_loop

#      best_value = max(best_value, knapsack(weights + i + 1, values + i + 1, num_items - i - 1, capacity - weights[i], cur_value + values[i]));
	  movl cur_value(%ebp), %ebx #ebx has cur_value
	  movl values(%ebp), %ecx #ecx has values
	  addl (%ecx, %esi, wordsize), %ebx #ebx is now cur_value + values[i]
	  push %ebx #pushed argument 5

	  movl capacity(%ebp), %ebx
	  movl weights(%ebp), %ecx
	  subl (%ecx, %esi, wordsize), %ebx #ebx now has capacity - weights[i]
	  push %ebx #pushed argument 4

	  movl num_items(%ebp), %ebx
	  subl %esi, %ebx #num_items - i
	  subl $1, %ebx #num_items - i - 1
	  push %ebx #pushed argument 3

	  movl values(%ebp), %ebx
	  leal (%ebx, %esi, wordsize), %ebx #values + i
	  leal wordsize(%ebx), %ebx #values + i + 1
	  push %ebx #pushed argument 2
	  
	  movl weights(%ebp), %ebx
	  leal (%ebx, %esi, wordsize), %ebx #weights + i
	  leal wordsize(%ebx), %ebx #weights + i + 1
	  push %ebx #pushed argument 1

	  movl %esi, i(%ebp) #save i
	  call knapsack #eax has return value
	  addl $5*wordsize, %esp #clear the arguments

	  movl i(%ebp), %esi
	  movl best_value(%ebp), %ebx #best_value is in ebx
	  push %eax #add argument 1 knapsack()
	  push %ebx #add argument 2 best_value
	  
	  call max #max should end up in edx hopefully !!!!!
	  addl $2*wordsize, %esp #clear the arguments
	  movl %edx, best_value(%ebp)
	  movl %edx, %eax

	end_loop:
	  addl $1, %esi
	  jmp top_loop 

	end_top_loop:





	#epilogue
	movl %ebp, %esp
	pop %ebp
ret


