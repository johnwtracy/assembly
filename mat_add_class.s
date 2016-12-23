#this program adds two matrices together
.global _start

.equ wordsize, 4

.equ num_rows, 3
.equ num_cols, 4

.data
  
A:
   .long 0
   .long 1
   .long 2
   .long 3
   .long 4
   .long 5
   .long 6
   .long 7
   .long 8
   .long 9
   .long 10
   .long 11
   
B:
 .rept num_rows * num_cols
    .long 100
 .endr
   
C:
  .space num_rows * num_cols * wordsize
    
i:
	.long 0
    
.text
_start:
    #eax will be i
    #ebx will be j
    #ecx will be A[i][j]
    #edx will be B[i][j]
    
    movl $0, %eax # set i = 0
		row_loop: #for(i = 0; i < num_rows; i++)
			# i < num_rows
			# i - num_rows < 0
			# negation i -num_rows >= 0
			cmpl $num_rows, %eax
			jge end_row_loop
		
			movl $0, %ebx #j = 0
			col_loop: #for(j = 0; j < num_cols; j++)
				#j < num_cols
				#j - num_cols < 0
				#negation j - num_cols >= 0
				cmpl $num_cols, %ebx
				jge end_col_loop
				
				movl %eax, i #save the value of i
				movl $num_cols, %esi
				imull %esi #eax has i * num_cols
				addl %ebx, %eax #i *num_rows + j
				
				movl A(,%eax, wordsize), %ecx #ecx = A[i][j]
				addl B(,%eax, wordsize), %ecx #ecx = A[i][j] + B[i][j]
				
				movl %ecx, C(,%eax, wordsize) #C[i][j] = A[i][j] + B[i][j]
				
				movl i, %eax
				
				
				incl %ebx #j++
				jmp col_loop
				end_col_loop:
			incl %eax #i++
			jmp row_loop #go to next iteration
		end_row_loop:
			
done:
	movl %eax, %eax
	
   
