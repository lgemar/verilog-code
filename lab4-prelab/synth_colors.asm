init:  add  $at, $zero, $zero    #r
       addi $v0, $v0, 85    #g
       addi $v1, $zero, 170   #b
       addi $a0, $zero, 255   #blue mask /lsb mask
       sll  $a1, $a0, 8     #green mask
       sll  $a2, $a1, 8     #red mask
       or   $a3, $zero, $zero    #data address
       addi $t0, $zero, 1023  #data address mask
loop:  addi $at, $at, 8     #increment all of the colors, masking out msbs
       addi $v0, $v0, 8
       addi $v1, $v1, 8
       and  $at, $at, $a0
       and  $v0, $v0, $a0
       and  $v1, $v1, $a0       
       sll  $t1, $at, 16    #shift red left two bytes
       sll  $at0, $v0, 8    #shift green left one byte
       add  $at1, $zero, $v1   #set mixed pixel to blue
       or   $at1, $at1, $t1  #mix in green
       or   $at1, $at1, $at0  #mix in  red
       sw   $t1,  0($a3)     #write one just red
       sw   $at0, 4($a3)     #write one just green
       sw   $v1,  8($a3)     #write one just blue
       sw   $at1, 12($a3)     #write all the colors together
       addi $a3, $a3, 20    #go to next set of data addresses
       and  $a3, $a3, $t0    #mask out more significant bits
       j loop
last:  j last
