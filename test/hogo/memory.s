        # Basic LW/SW test
	.text
main:
        #;;  Set a base address
        lui $t0, 0x0000
        ori $t0 ,0x4000
        lui $t1, 0x0000
        ori $t1 ,0x8000


        addiu  $t2, $zero, 255
        nop
	nop
	nop
	nop
	nop
        add    $t3, $t2, $t2
	nop
	nop
	nop
	nop
	nop
        add    $t4, $t3, $t3
	nop
	nop
	nop
	nop
	nop
        add    $t5, $t3, $t4
        nop
        
        #;; Place a test pattern in memory
        sw $t2 , 0($t0) #miss to save
        sw $t3 , 0($t0) #hit to save
        lw $t6 , 0($t0) #hit to load
        sw $t5 , 0($t1) #miss to save , dirty bit = 1
        lw $t7 , 0($t0) #miss to load , dirty bit = 1
        lw $t8 , 0($t1) #miss to load , dirty bit = 0
        

        #;; Calculate a "checksum" for easy comparison
        nop
        nop
        nop
        nop
        nop
        add    $s0, $t7, $t8
        
        #;;  Quit out 
        addiu $v0, $zero, 0xa
        syscall
        
