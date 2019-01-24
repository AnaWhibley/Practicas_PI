	.data 0xFFFF0000
	
tControl: 		.space 4
tData:			.space 4
pCotrol:		.space 4
pData:			.space 4

	.data 0x10000000
	
buffer: 	.space 10
			.align 2

	.text 0x00400000
	.globl main
	
main:
	
	jal LeerTeclado
	j main
	
LeerTeclado:

	la $t0, tControl
	lb $a0, 0($t0)
	
	beqz $a0, LeerTeclado
	
	lb $a0, tData
	beq $a0, 0x14, bucle
	
	sb $a0, buffer($t1)
	addi $t1, $t1, 1
		
	jr $ra
	
	bucle:
		li $t2, 0x20
		sb $t2, buffer($t1)
		addi $t1, $t1, 1
		break 5
		
		jr $ra

BreakException:
	
	la $a0, buffer
	li $v0, 4
	syscall
	
	and $t1, $t1, $0
	
	jr $ra
