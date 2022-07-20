.text
    # Base
    lui $2, 0x1000
    addiu $3, $zero, 0x123
    nop
    nop
    nop
    nop
    sw $3, 0($2)
    nop
    nop
    nop
    nop
    lw $4, 0($2)
    syscall