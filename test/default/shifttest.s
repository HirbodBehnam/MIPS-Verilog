        # Basic shift tests
	.text
main:   
        ori $3, $zero, 65535
        nop
        nop
        nop
        nop
        nop
        sll   $4, $3, 16
        nop
        nop
        nop
        nop
        nop
        sll   $5, $3, 6
        nop
        nop
        nop
        nop
        nop
        sra   $6, $4, 10
        nop
        nop
        nop
        nop
        nop
        sra   $7, $5, 16
        nop
        nop
        nop
        nop
        nop
        srl   $8, $4, 8
        nop
        nop
        nop
        nop
        nop
        srl   $9, $5, 16
        nop
        nop
        nop
        nop
        nop
        addiu $2, $zero, 0xa
        syscall
