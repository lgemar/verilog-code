# Test load words and store words
main:   lw	$t0, 0($zero)
	sw	$t0, 80($zero)
	lw	$t1, 4($zero)
	sw	$t1, 84($zero)
	lw	$t2, 8($zero)
	sw	$t2, 88($zero)

	# Test R-type instructions
	addi $t3, $zero, 3
	addi $t4, $zero, 7
	and $s0, $t3, $t4
	sw $s0, 92($zero) # out = 3
	or $s1, $t3, $t4
	sw $s1, 96($zero) # out = 7
	add $s2, $t3, $t4
	sw $s2, 100($zero) # out = 10
	beq $s0, $s0, dest2

	# I-type instructions

dest1: nor $s5, $t3, $t4
   sw $s5, 112($zero) # out = something crazy
   beq $s5, $s5, finish # always true

dest2: sub $s3, $t4, $t3
	sw $s3, 104($zero) # out = 4
	xor $s4, $t3, $t4
	sw $s4, 108($zero) # out = 4
	beq $s4, $s4, dest1

finish: add $zero, $zero, $zero #dummy instruction
