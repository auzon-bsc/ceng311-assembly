# Implementation details
# $s0 holds the address of the root node
# $s7 holds -9999 which represents end of the list
# 'n' represents null
# 'x' represents empty node
.globl tree
.globl build
.globl insert
.globl find
.globl printTree

.data
MAXINT: .word -9999
newline: .asciiz "\n"
null: .word 'n'
dash: .word '-'
four_space: .asciiz "    "
empty: .word 'x'
tree: .word 'n', 'n', 'n', 'n'
.text
#   build procedure
build: # a0: address of the first integer in the list, a1: address of the root node
    lw $s7, MAXINT # s7 = -9999
build_insert: 
    # t0: content of address from given list
    lw $t0, 0($a0) # load content of address that points in given list
    beq $t0, $s7, build_exit # if list ends(last integer is -9999) then exit loop
    addi $sp, $sp, -12 # allocate space in the stack
    sw $ra, 8($sp) # save return address
    sw $a0, 4($sp) # add address of the integer to the stack
    sw $a1, 0($sp) # add address of the root node to the stack
    lw $a0, 0($a0) # load content to a0 
    jal insert # insert the content of the address a0 to tree with address a1
    lw $a1, 0($sp) # pop address of the root node from stack
    lw $a0, 4($sp) # pop address of the element from stack
    lw $ra, 8($sp) # pop return address
    addi $sp, $sp, 12 # trim the allocated stack space
    addi $a0, $a0, 4 # increment address for the next element in the list
    j build_insert # loop for rest of the list
build_exit: # exit when all the elements are inserted in

    jr $ra

#   insert procedure
insert:
    # a0: value to add
    # a1: address of the top root node
    # t1: value of the top root
    # t9 = 'n' (null) 
    lw $t9, null # for null check
    lw $t1, 0($a1) # load vale of top root to t1
    bne $t1, $t9, insert_recursive # if root != null branch to insert_subtree
    sw $a0, 0($a1) # root = value
    jr $ra
insert_recursive:
    # this branch assumes there is already at least one value inserted to tree
    # t1: value of the root of the current tree
    lw $t1, 0($a1) # load vale of root to t1
    blt $a0, $t1, insert_lookleft # if value < root look left subtree
    bge $a0, $t1, insert_lookright # if value >= root look right subtree
insert_lookleft:
    # t2: address of the left subtree
    lw $t2, 4($a1) # load the address of the left subtree
    beq $t2, $t9, insert_toleft # if address is empty create new node
    addi $sp, $sp, -8 # adjust stack for 2 items
    sw $a1, 4($sp) # store a1
    sw $ra, 0($sp) # store ra
    addi $a1, $a1, 4 # load address of the left node's address to a1
    lw $a1, 0($a1) # load address of the left node to a1
    jal insert_recursive # recursive call to left subtree
    lw $ra, 0($sp) # restore ra
    lw $a1, 4($sp) # restore a1
    addi $sp, $sp, 8 # fix stack
    jr $ra
insert_toleft:
    addi $sp, $sp, -4 # make 4byte space in stack
    sw $a0, 0($sp) # push a0 to the stack
    li $v0, 9 # for system call sbrk
    li $a0, 16 # for allocation of 16 byte
    syscall
    lw $a0, 0($sp) # restore a0
    addi $sp, $sp, 4 # shrink stack
    sw $a0, 0($v0) # set value of the new node
    sw $t9, 4($v0) # set left tree address to 'n'
    sw $t9, 8($v0) # set right tree address to 'n'
    sw $a1, 12($v0) # set parent root address
    sw $v0, 4($a1) # set left tree address of the parent node
    jr $ra
insert_lookright:
    # t2: address of the right subtree
    lw $t2, 8($a1) # load the address of the right subtree
    beq $t2, $t9, insert_toright # if address is empty create new node
    addi $sp, $sp, -8 # adjust stack for 2 items
    sw $a1, 4($sp) # store a1
    sw $ra, 0($sp) # store ra
    addi $a1, $a1, 8 # load address of the right node's address to a1
    lw $a1, 0($a1) # load address of the right node to a1
    jal insert_recursive # recursive call to right subtree
    lw $ra, 0($sp) # restore ra
    lw $a1, 4($sp) # restore a1
    addi $sp, $sp, 8 # fix stack
    jr $ra
insert_toright:
    addi $sp, $sp, -4 # make 4byte space in stack
    sw $a0, 0($sp) # push a0 to the stack
    li $v0, 9 # for system call sbrk
    li $a0, 16 # for allocation of 16 byte
    syscall
    lw $a0, 0($sp) # restore a0
    addi $sp, $sp, 4 # shrink stack
    sw $a0, 0($v0) # set value of the new node
    sw $t9, 4($v0) # set left tree address to 'n'
    sw $t9, 8($v0) # set right tree address to 'n'
    sw $a1, 12($v0) # set parent root address
    sw $v0, 8($a1) # set right tree address of the parent node
    jr $ra

#   find procedure
find:
    # a0: value | the value to find
    # a1: tree | address of the root node
    # t1: value of the root node
    # t9: null
    lw $t9, null # load null to t9
    beq $a1, $t9, find_failed # if root address == null it couldn't find
    lw $t1, 0($a1) # load value of the root
    beq $a0, $t1, find_success # if value == root found
    blt $a0, $t1, find_leftree # if value < root recurse to left sub-tree
    bge $a0, $t1, find_rightree # if value >= root recurse to right sub-tree
find_failed:
    li $v0, 1 # set v0 = 1 bc it is failed
    jr $ra
find_success:
    li $v0, 0 # set v0 = 0 bc value found
    move $v1, $a1 # set v1 to address of the found node
    jr $ra
find_leftree:
    addi $sp, $sp, -8 # allocate 8 byte space
    sw $a1, 4($sp) # save a1 to stack
    sw $ra, 0($sp) # save ra to stack
    addi $a1, $a1, 4 # prepare for left recursive call
    lw $a1, 0($a1) # load the left address
    jal find
    lw $ra, 0($sp) # restore ra from stack
    lw $a1, 4($sp) # restore a1 from stack
    addi $sp, $sp, 8 # shrink stack
    jr $ra
find_rightree:
    addi $sp, $sp, -8 # allocate 8 byte space
    sw $a1, 4($sp) # save a1 to stack
    sw $ra, 0($sp) # save ra to stack
    addi $a1, $a1, 8 # prepare for right recursive call
    lw $a1, 0($a1) # load the right address
    jal find
    lw $ra, 0($sp) # restore ra from stack
    lw $a1, 4($sp) # restore a1 from stack
    addi $sp, $sp, 8 # shrink stack
    jr $ra

#   printTree procedure
printTree:
    # a0: address of the tree
    # t0: level to be printed
    # t1: tree height
    li $t0, 1 # initialize level to 1
    li $t1, 0 # initialize tree height to 0

    addi $sp, $sp, -8 # allocate 8 byte space
    sw $a0, 4($sp) # save a0 to stack
    sw $ra, 0($sp) # save ra to stack
    jal getheight
    move $t1, $v0 # set real height of tree
    lw $ra, 0($sp) # restore ra from stack
    lw $a0, 4($sp) # restore a0 from stack
    addi $sp, $sp, 8 # shrink stack

printTree_loop:
    # t2: number of already printed nodes in that level
    li $t2, 0 # initialize printed nodes to 0
    
    addi $sp, $sp, -12 # allocate space for 3 items
    sw $a1, 8($sp) # save a1 to stack
    sw $a2, 4($sp) # save a2 to stack
    sw $ra, 0($sp) # save ra to stack
    move $a1, $t0 # move current level to a1
    move $a2, $t2 # move printed nodes to a2
    jal printTree_level
    lw $ra, 0($sp) # restore ra from stack
    lw $a1, 4($sp) # restore a2 from stack
    lw $a2, 8($sp) # restore a3 to stack
    addi $sp, $sp, 12 # shrink stack

    addi $t0, $t0, 1 # increment level before loop
    ble $t0, $t1, printTree_loop # if level <= height loop  

    jr $ra

printTree_level:
    # a0: address of the tree
    # a1: current level to be printed
    # a2: number of printed nodes so far
    # t3: delimiter for printed nodes
    # t4: format number: for determining wheter dash or tab(four space) will be printed
    # t5: number of loop for empty node print operation
    # t6: static variable for storing level to be printed

    # t8: 1 needed for recursive condition check
    # t9: 'n' null
    
    li $t3, 1 # initialize delimiter
    li $t4, 1 # initialize format number
    li $t8, 1 # initialize t8
    li $t5, 1 # initialize empty node loop number
    move $t6, $a1 # initialize static level number
    lw $t9, null # intialize null

    addi $sp, $sp, -4 # allocate space for 1 item
    sw $a1, 0($sp) # save a1 to stack
    addi $a1, $a1, -1 # decrement a1 for delimiter calculation
    sll $t3, $t3, $a1 # perform delimiter calculation
    lw $a1, 0($sp) # restore a1
    addi $sp, $sp, 4 # shrink stack

printTree_levelrecurse:
    bge $a2, $t3, printTree_levelexit # if printed nodes >= delimiter exit(return)
    beq $a0, $t9, printTree_emptyprint # if address is null go emptyprint
    bne $a1, $t8, printTree_levelsubtree # if current level is not 1 branch to subtree
printTree_printop:
    addi $sp, $sp, -8 # allocate space for 3 items
    sw $a0, 4($sp) # save a0 to stack
    sw $ra, 0($sp) # save ra to stack
    jal printcontent
    lw $ra, 0($sp) # restore ra from stack
    lw $a0, 4($sp) # restore a0 to stack
    addi $sp, $sp, 8 # shrink stack
    
    jr $ra
printTree_emptyprint:

    addi $sp, $sp, -4 # stack allocation for 1 item
    sw $ra, 0($sp) # store ra
    jal printTree_printop
    lw $ra, 0($sp) # restore ra
    addi $sp, $sp, 4 # shrink stack
    addi $t5, $t5, -1 # decrease t5 by 1 for loop condition
    bne $t5, $zero, printTree_emptyprint

    jr $ra
printTree_levelsubtree:

    addi $sp, $sp, -12 # allocate space for 3 items
    sw $a0, 8($sp) # save a0 to stack
    sw $a1, 4($sp) # save a1 to stack
    sw $ra, 0($sp) # save ra to stack
    lw $a0, 4($a0) # load the root address of the left subtree
    addi $a1, $a1, -1 # decrement current level for condition check

    li $t5, 1 # reset empty node loop number
    addi $a1, $a1, -1 # adjust a1 for calculation
    sll $t5, $t5, $a1 # perform empty node loop number calculation
    addi $a1, $a1, 1 # restore a1

    jal printTree_levelrecurse # recurse to left subtree
    lw $ra, 0($sp) # restore ra from stack
    lw $a1, 4($sp) # restore a1 from stack
    lw $a0, 8($sp) # restore a0 to stack
    addi $sp, $sp, 12 # shrink stack

    addi $sp, $sp, -12 # allocate space for 3 items
    sw $a0, 8($sp) # save a0 to stack
    sw $a1, 4($sp) # save a1 to stack
    sw $ra, 0($sp) # save ra to stack
    lw $a0, 8($a0) # load the root address of the right subtree
    addi $a1, $a1, -1 # decrement current level for condition check

    li $t5, 1 # reset empty node loop number
    addi $a1, $a1, -1 # adjust a1 for calculation
    sll $t5, $t5, $a1 # perform empty node loop number calculation
    addi $a1, $a1, 1 # restore a1

    jal printTree_levelrecurse # recurse to right subtree
    lw $ra, 0($sp) # restore ra from stack
    lw $a1, 4($sp) # restore a1 from stack
    lw $a0, 8($sp) # restore a0 to stack
    addi $sp, $sp, 12 # shrink stack

    jr $ra
printTree_levelexit:
    jr $ra

maxof:
    # a0: first number
    # a1: second number
    bgt $a0, $a1, maxof_firstbigger # if first is bigger branch and set return value to that
    move $v0, $a1 # second is bigger, set second to return value
    
    jr $ra
maxof_firstbigger:
    move $v0, $a0
    
    jr $ra

getheight:
    # a0: address of the root node
    bne $a0, $t9, getheight_recurse # if address is not null begin recursive
    li $v0, 0
    jr $ra
getheight_recurse:
    addi $sp, $sp, -8 # s for 2 items
    sw $t0, 4($sp) # store t0
    sw $t1, 0($sp) # store t1

    addi $sp, $sp, -12 # s for 3 items
    sw $v0, 8($sp) # store v0
    sw $a0, 4($sp) # store a0
    sw $ra, 0($sp) # store ra
    lw $a0, 4($a0) # load address of the left tree
    jal getheight
    move $t0, $v0 # result of left recursion
    lw $ra, 0($sp) # restore ra
    lw $a0, 4($sp) # restore a0
    lw $v0, 8($sp) # restore v0
    addi $sp, $sp, 12 # shrink stack

    addi $sp, $sp, -12 # s for 3 items
    sw $v0, 8($sp) # store v0
    sw $a0, 4($sp) # store a0
    sw $ra, 0($sp) # store ra
    lw $a0, 8($a0) # load address of the right tree
    jal getheight
    move $t1, $v0 # result of right recursion
    lw $ra, 0($sp) # restore ra
    lw $a0, 4($sp) # restore a0
    lw $v0, 8($sp) # restore v0
    addi $sp, $sp, 12 # shrink stack

    addi $sp, $sp, -12 # allocate 8 byte space
    sw $a0, 8($sp) # store a0
    sw $a1, 4($sp) # store a1
    sw $ra, 0($sp) # save ra to stack
    move $a0, $t0 # move to a0 from t0
    move $a1, $t1 # move to a1 from t1
    jal maxof
    addi $v0, $v0, 1
    lw $ra, 0($sp) # restore ra
    lw $a1, 4($sp) # restore a1  
    lw $a0, 8($sp) # restore a0    
    addi $sp, $sp, 12 # shrink stack
        
    lw $t1, 0($sp) # restore t1
    lw $t0, 4($sp) # restore t0
    addi $sp, $sp, 8 # shrink stack

    jr $ra

printcontent:
    # a0: address to be printed
    # a2: printed nodes so far
    # t4: format number
    blt $a2, $t3, printcontent_nodeformat # if printed nodes < delimiter branch to nodeformat
    jr $ra
printcontent_nodeformat:
    beq $a0, $t9, printcontent_nulladdress # if address is null branch nulladdress
    
    addi $sp, $sp, -4 # stack alloc for 1 item
    sw $a0, 0($sp) # store a0
    lw $a0, 0($a0) # load content of the address to a0
    li $v0, 1 # for system call print character
    syscall
    lw $a0, 0($sp) # restore a0
    addi $sp, $sp, 4 # shrink stack

    addi $a2, $a2, 1 # increment printed nodes so far

    j printcontent_formatcharacter
printcontent_nulladdress:
    
    addi $sp, $sp, -4 # stack alloc for 1 item
    sw $a0, 0($sp) # store a0
    lw $a0, empty # set a0 to 'x'
    li $v0, 11 # for system call print character
    syscall
    lw $a0, 0($sp) # restore a0
    addi $sp, $sp, 4 # shrink stack

    addi $a2, $a2, 1 # increment printed nodes so far

    j printcontent_formatcharacter
printcontent_formatcharacter: 
    # it prints four space by default
    bge $a2, $t3, printcontent_newline # if printed nodes >= delimiter print new line character
    beq $a2, $t4, printcontent_dash # if printed nodes == format number print dash

    addi $sp, $sp, -4 # stack alloc for 1 item
    sw $a0, 0($sp) # store a0
    la $a0, four_space # set a0 to "    "
    li $v0, 4 # for system call print string
    syscall
    lw $a0, 0($sp) # restore a0
    addi $sp, $sp, 4 # shrink stack

    jr $ra
printcontent_newline:
    
    addi $sp, $sp, -4 # stack alloc for 1 item
    sw $a0, 0($sp) # store a0
    la $a0, newline # set a0 to "\n"
    li $v0, 4 # for system call print string
    syscall
    lw $a0, 0($sp) # restore a0
    addi $sp, $sp, 4 # shrink stack

    jr $ra
printcontent_dash:
    
    addi $sp, $sp, -4 # stack alloc for 1 item
    sw $a0, 0($sp) # store a0
    lw $a0, dash # set a0 to '-'
    li $v0, 11 # for system call print char
    syscall
    lw $a0, 0($sp) # restore a0
    addi $sp, $sp, 4 # shrink stack

    addi $t4, $t4, 2 # increment format number by 2

    jr $ra