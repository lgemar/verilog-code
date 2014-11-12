main:				addi $s0, $0, 256		#set loop max to 256
					and  $s1, $0, $0		#set frame to zero
					add  $s7, $s1, $0		#set the next frame to the current frame
					or   $a0, $0, $0        #a0 = frame count (number of frames drawn)
reset:				add  $s1, $s7, $0 		#set the current frame
					xori $s7, $s1, 2048		#set next frame
					addi $s2, $0, 1024	    #set current_address to 1024
					add  $s2, $s2, $s1      #add in the frame
vsync:				addi $t0, $0, 8192      #frame counter address is 8192,
					lw $t8, 0($t0)			#get the current frame counter value
					bne $a0, $t8, new_frame #if a new frame has been drawn...
					j vsync					#else keep checking
new_frame:			add $a0, $t8, $0        #frame_count = new frame_count
  					addi $t7, $s2, 1024      #set max address
					j loop					#start computing the next frame!
loop:				beq $s2, $t7, reset		#jump to reset if the counter is too big
					lw $s6, 0($s2)			#get the current cell's value
					xori $s3, $s2, 2048		#compute the next iteration of the cell's address
					and $s5, $0, $0			#set the sum to zero
					addi $s4, $s2, -4		#start computing the number of living neighbors
					jal check_neighbor		
					addi $s4, $s2, 4		
					jal check_neighbor
					addi $s4, $s2, -64
					jal check_neighbor
					addi $s4, $s2, 64		
					jal check_neighbor
					addi $s4, $s2, -60		
					jal check_neighbor
					addi $s4, $s2, 60		
					jal check_neighbor
					addi $s4, $s2, -68		
					jal check_neighbor
					addi $s4, $s2, 68		
					jal check_neighbor
					beq $s6, $0, check_cell_dead
check_cell_alive:	slti $t0, $s5, 2		#if sum < 2
					bne $t0, $0, cell_death
					slti $t0, $s5, 4
					bne $t0, $0, cell_birth
					j cell_death
check_neighbor:		lw $t1, 0($s4)
					bne $t1, $0, neighbor_alive
					jr $ra
neighbor_alive:		addi $s5, $s5, 1
					jr $ra
check_cell_dead:	addi $t0, $s5, -3
					beq $t0, $zero, cell_birth
					j cell_death
cell_death:			sw $0, 0($s3)
					j end_of_loop
cell_birth:			addi $t2, $0, 1
					sw $t2, 0($s3)
					j end_of_loop
end_of_loop:		addi $s2, $s2, 4
					j loop
end:			j end
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
					nop
