.text
        .set noreorder
main:   
        addi $a0, $0, 5
        addi $a1, $0, 10
        nop
        nop
        nop
        nop
        nop
        jal jamkon
        addi $ra, $0, 0 # Zero the address because of re allocation
        addi $t0, $v0, 0
        addi $v0, $0, 10
        syscall
jamkon:
        add $v0, $a0, $a1
        nop
        nop
        nop
        nop
        nop
        jr $ra