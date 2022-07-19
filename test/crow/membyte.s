        # Basic LB/SB test
	.text
main:
        #;;  Set a base address
        lui    $3, 0x1000

        addiu  $5, $zero, 0x1F
        addiu  $6, $zero, 0x2
        addiu  $7, $zero, 0x22F
        addiu  $8, $zero, 0x2F

        nop # One is good I think
        
        #;; Place a test pattern in memory
        sb     $5, 0($3)
        sb     $6, 1($3)
        sb     $7, 2($3)
        sb     $8, 3($3)

        lb     $9,  0($3)
        lb     $10, 1($3)
        lb     $11, 2($3)
        lb     $12, 3($3)

        
        #;;  Quit out 
        addiu $v0, $zero, 0xa
        syscall
        
