# Test load words and store words
main: addi $sp, $zero, 200
	lw	$t0, 0($zero)
	sw	$t0, 0($sp)
	lw	$t1, 4($zero)
	sw	$t1, 4($sp)
	lw	$t2, 8($zero)
	sw	$t2, 8($sp)

	# Test R-type instructions
	addi $t3, $zero, 3
	addi $t4, $zero, 7
	and $s0, $t3, $t4
	sw $s0, 12($sp) # out = 3
	or $s1, $t3, $t4
	sw $s1, 16($sp) # out = 7
	add $s2, $t3, $t4
	sw $s2, 20($sp) # out = 10

	# I-type instructions
	ori $s7, $s2, 5
	sw $s7, 24($sp) # out = f

	xori $s7, $s2, 5
	sw $s7, 28($sp) # out = f

	andi $s7, $s2, 5
	sw $s7, 32($sp) # out = 0

	slti $s7, $s2, 5
	sw $s7, 36($sp) # out = 0

	slti $s7, $s2, 15
	sw $s7, 40($sp) # out = 1

	# Test branches
	bne $s0, $s0, finish
	beq $s0, $s0, dest2

dest1: nor $s5, $t3, $t4
   sw $s5, 52($sp) # out = something crazy
	# Jump to the finish
   j finish

dest2: sub $s3, $t4, $t3
	sw $s3, 44($sp) # out = 4
	xor $s4, $t3, $t4
	sw $s4, 48($sp) # out = 4
	beq $s4, $s4, dest1

finish: addi $t0, $zero, 32
		sll $t1, $t0, 2
	    sw $t1, 56($sp) # out = 128
		srl $t2, $t0, 2
   		sw $t2, 60($sp) # out = 8
		sra $t3, $t0, 2
   		sw $t3, 64($sp) # out = 8
