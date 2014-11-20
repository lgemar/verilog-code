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
	beq $s0, $s0, dest2

	# I-type instructions

dest1: nor $s5, $t3, $t4
   sw $s5, 32($sp) # out = something crazy
   beq $s5, $s5, finish # always true

dest2: sub $s3, $t4, $t3
	sw $s3, 24($sp) # out = 4
	xor $s4, $t3, $t4
	sw $s4, 28($sp) # out = 4
	beq $s4, $s4, dest1

finish: add $zero, $zero, $zero #dummy instruction
