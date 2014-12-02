init:           sll  $0, $0, 0      
                addi $10, $0, 1024          #$10 = frame limit (# of frames until next step of the game of life. 1 is good for simulation, 1024 is good for synthesis)
                add  $1, $0, $0          #$1 = current_frame
                add  $2, $0, $10         #$2 = next_frame (for 1 Hz Vsync)
                and  $3, $0, $0          #$3 = cell
                or   $4, $0, $0          #$4 = cell_neighbor
                xori $5, $0, 0           #$5 = number of living neighbors
                or   $6, $0, $0          #$6 = neighbor status
                addi $30, $0, 1          #$30 = 1
                addi $29, $0, 3          #$29 = 3
                addi $28, $0, 1020       #$28 = 1020
main:           lw   $1, 2048($0)        #get the current frame number 
                slt  $7, $2, $1          #see if the current frame is less than the next vsync frame ($7 = 1 if not enough time has elapsed, equals zero if enough time has passed)
                beq  $7, $0, main        #go back to main if the current frammips/tests/game_of_life.memhe is less than the next vsync frame
                add  $2, $2, $10         #increment the next frame count
                addi $3, $0, 1024        #reset cell address to 1024 (will decrement down to zero)
cell_loop:      addi $3, $3, -4          #decrement cell address
	    		add  $5, $0, $0          #zero out number of living neighbors
    			slt  $7, $3, $0          #start updating the frame if cell is less than zero 
    			beq  $7, $30, update_frame 
			    addi $4, $3, -4          #check left neighbor
			    jal  check_neighbor
    			addi $4, $3, 4           #check right neighbor
    			jal  check_neighbor
			    addi $4, $3, -64         #check top neighbor
			    jal  check_neighbor
			    addi $4, $3, 64          #check bottom neighbor
			    jal  check_neighbor
			    addi $4, $3, -68         #check top-left neighbor
			    jal  check_neighbor
    			addi $4, $3, -60         #check top-right neighbor
    			jal  check_neighbor
			    addi $4, $3, +60         #check bottom-left neighbor
			    jal  check_neighbor
			    addi $4, $3, +68         #check bottom-right neighbor
			    jal  check_neighbor
			    lw   $8, 0($3)           #get the current cell's status
			    beq  $8, $0, dead_cell   #if the cell is dead...
live_cell:      slti $7, $5, 2           #if living neighbors less than 2 ($7=1 if cell should die, 0 if it should live)
				bne  $7, $0, cell_death
				slti $7, $5, 4           #if living neighbors is less than 4, $7 = 1, cell should live, 0 it should die
				bne  $7, $0, cell_birth  
				j cell_death         
dead_cell:     	addi $7, $5, -3
                beq $7, $zero, cell_birth
                j cell_death
cell_death:     sw   $0, 1024($3)        #set the next cell to dead
				j cell_loop
cell_birth:     sw   $30, 1024($3)       #set the cell to 1 in the scratchpad
                j cell_loop              #back to start of cell loop
                j main                   #jump back to start of main loop
check_neighbor: slt  $7, $4, $0          #$7 = ($4 < $0) = if cell_neighbor < 0, $7 = 1, out of bounds, return
                beq  $7, $30, cn_return
                slt  $7, $28, $4         #$7 = (1020 < cell_neighbor), if $7 = 1, out of bounds, return
                beq  $7, $30, cn_return
                lw   $6, 0($4)           #get the current value of the cell's neighbor
                beq  $6, $0, cn_return   #if the cell is dead return
                addi $5, $5, 1           #increment living neighbor count by neighbor's status
cn_return:      jr $31                   #go back to where we left off
update_frame:   addi $3, $0, 1020        #initialize cell to zero
uf_loop:        slt  $7, $3, $0          #go back to main if cell is less than zero ($7 = 1 -> go back to main)
                beq  $7, $30, main       #go back to main if the update loop is done
    			lw   $27, 1024($3)       #get the new cell value...
    			sw   $27, 0($3)          #...and store it into the part of memory that gets displayed
                addi $3, $3, -4          #decrement counter
                j uf_loop
last:           j last                   #catch all, if this instruction is reached something failed
