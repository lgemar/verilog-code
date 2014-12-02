init:  add  $1, $0, $0    #r
       addi $2, $0, 85    #g
       addi $3, $0, 170   #b
       addi $4, $0, 255   #blue mask /lsb mask
       sll  $5, $4, 8     #green mask
       sll  $6, $5, 8     #red mask
       or   $7, $0, $0    #data address
       addi $8, $0, 1023  #data address mask
loop:  addi $1, $1, 8     #increment all of the colors, masking out msbs
       addi $2, $2, 8
       addi $3, $3, 8
       and  $1, $1, $4
       and  $2, $2, $4
       and  $3, $3, $4       
       sll  $9, $1, 16    #shift red left two bytes
       sll  $10, $2, 8    #shift green left one byte
       add  $11, $0, $3   #set mixed pixel to blue
       or   $11, $11, $9  #mix in green
       or   $11, $11, $10  #mix in  red
       sw   $9,  0($7)     #write one just red
       sw   $10, 4($7)     #write one just green
       sw   $3,  8($7)     #write one just blue
       sw   $11,12($7)     #write all the colors together
       addi $7, $7, 20    #go to next set of data addresses
       and  $7, $7, $8    #mask out more significant bits
       j loop
last:  j last
