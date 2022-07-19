        # Basic LW/SW test
	.text
main:
        #;;  Set a base address
        lui $t0, 0x1000
        nop
        nop
        nop
        nop
        nop
        ori $t0 ,0xE100
        nop
        nop
        nop
        nop
        nop
        lui $t1, 0x1000
        nop
        nop
        nop
        nop
        nop
        ori $t1 ,0x6100


        addi  $t2, $zero, 0x14
        addi  $t3, $zero, 0xa3 # test -16
        addi  $t4, $zero, 0x62
        addi  $t5, $zero, 0x85
        
        nop # One no-op is fine i guess?
        #;; Place a test pattern in memory
        
        sb $t2 , 0($t0) #hit to save
        sb $t3 , 1($t0) #miss to save
        sb $t4 , 2($t0) #miss to save
        sb $t5 , 3($t0) #miss to save
                
        lb $t6 , 0($t0) #hit to load
        lb $t7 , 1($t0) #hit to load
        lb $t8 , 2($t0) #hit to load
        lb $t9 , 3($t0) #hit to load

        lw $s0 , 0($t0) #hit to load

        #;;  Quit out 
        addiu $v0, $zero, 0xa
        syscall
        
