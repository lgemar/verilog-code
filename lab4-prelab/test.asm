main:	addi	$s0, $zero, 5   	# $s0 = 5
	addi    $s3, $zero, -36 	# $s3 = -36
	add	$s2, $s0, $s3   	# $s2 = $s0 + $s3 = -31
	sub	$t0, $s2, $s0   	# $t0 = $s2 - $s0 = -36
	and	$t4, $t0, $s3
	andi	$t1, $s0, 4095
	or	$t5, $t1, $t0
	ori	$t2, $0, 40		# $t2 gets 40
	xor	$s5, $zero, $s2
	xori	$t3, $0, 17
	nor	$t4, $t4, $t4
	lw	$t5, 4($t2)
	sw	$t4, -16($t2)
	nop
test:	sll	$t1, $s3, 2
	sra	$t1, $s3, 4
	srl	$t1, $s3, 2
	slt     $t0, $s3, $s0
	nop
hello:	slti	$t0, $s3, -40
	beq	$s3, $s0, test
	bne	$s3, $s0, hello
	j	main
	j	test
	jr      $ra
	jr 	$s1
	jal	hello
