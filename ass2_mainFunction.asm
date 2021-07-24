.data
# -9999 marks the end of the list
firstList: .word 8, 3, 6, 10, 13, 7, 4, 5, -9999

# other examples for testing your code
secondList: .word 8, 3, 6, 6, 10, 13, 7, 4, 5, -9999
thirdList: .word 8, 3, 6, 10, 13, -9999, 7, 4, 5, -9999

# assertEquals data
failf: .asciiz " failed\n"
passf: .asciiz " passed\n"
buildTest: .asciiz " Build test"
insertTest: .asciiz " Insert test"
findTest: .asciiz " Find test"
asertNumber: .word 0


.text
main:

    # The test code assumes your root node's address is stored at $s0 and at tree argument at all times
    # Although it's not needed, you can:
    #         - modify the test cases if you must
    #         - add code between test cases
    #

    la $s0, tree

    # build a tree using the firstList
    move $a1, $s0
    la $a0, firstList
    jal build

    # Start of the test cases----------------------------------------------------

    # check build procedure
    lw $t0, 4($s0) # address of the left child of the root
    lw $a0, 0($t0) # real value of the left child of the root
    li $a1, 3 # expected value of the left child of the root
    la $a2, buildTest # the name of the test
    # if left child != 3 then print failed 
    jal assertEquals

    # check insert procedure
    li $a0, 11 # new value to be inserted
    move $a1, $s0 # address of the root
    jal insert
    # no need to reload 11 to $a0
    lw $a1, 0($v0) # value from the returned address
    la $a2, insertTest # the name of the test
    # if returned address's value != 11 print failed 
    jal assertEquals

    # check find procedure
    li $a0, 11 # search value
    move $a1, $s0 # adress of the root
    jal find 
    # no need to reload 11 to $a0
    lw $a1, 0($v1) # value from the found adress
    la $a2, findTest # the name of the test
    # if returned address's value != 11 print failed 
    jal assertEquals

    # check find procedure 2
    li $a0, 44 # search value
    move $a1, $s0 # adress of the root
    jal find
    move $a0, $v0 # result of the search
    li $a1, 0 # expected result of the search
    la $a2, findTest # the name of the test
    # if returned value of $v0 != 0 print failed
    jal assertEquals

    move $a0, $s0
    jal printTree # print tree for visual inspection

    # End of the test cases----------------------------------------------------

    # End program
    li $v0, 10
    syscall

assertEquals:
    move $t2, $a0
    # increment count of total assertions.
    la $t0, asertNumber
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0) 

    # print the test number
    add $a0, $t1, $zero
    li $v0, 1
    syscall
    
    # print the test name
    move $a0, $a2
    li $v0, 4
    syscall

    # print passed or failed.
    beq $t2, $a1, passed
    la $a0, failf
    li $v0, 4
    syscall
    j $ra
passed:
    la $a0, passf
    li $v0, 4
    syscall
    j $ra
