# Test load words and store words
main:   lw	$t0, 0($zero)
	sw	$t0, 80($zero)
	lw	$t1, 4($zero)
	sw	$t1, 84($zero)
	lw	$t2, 8($zero)
	sw	$t2, 88($zero)

	# Test R-type instructions

	and $s0, $t0, $zero
	sw $s0, 92($zero) # out = 0x0

	or $s1, $t0, $zero
	sw $s1, 96($zero) # out = $t0

	add $s2, $t0, $zero
	sw $s2, 100($zero) # out = $t0

	sub $s3, $t0, $t0
	sw $s3, 104($zero) # out = 0

	xor $s4, $t0, $t0
	sw $s4, 108($zero) # out = 0

	nor $s5, $t0, $t0
	sw $s5, 112($zero) # out = !$t0





	
