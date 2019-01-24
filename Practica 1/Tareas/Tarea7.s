	.data 0xFFFF0000
	
tControl:		.space 4
tData:			.space 4
pControl:		.space 4
pData:			.space 4

	.data 0x10000000
	
frase: 			.asciiz "En un lugar de la Mancha cuyo nombre...\n"
pulsacion:		.asciiz " [Pulsacion("
num_pulsacion:	.word 0
parentesis:		.asciiz	") = "
letra:			.space 1
corchete:		.asciiz "] "

pila: 			.word 0

	.text 0x00400000
	.globl main
	
main:

	jal TInterEnable 	# Saltamos a la activación de las interrupciones
	
	CargaFrase:

		la $s3, frase	# Cargamos la frase para luego imprimirla

	ImprimeFrase:
	
		lb $s2, 0($s3)		# Cargamos un byte de la frase
	
		beqz $s2, CargaFrase	# Comprobamos que no es el final de la cadena
	
		jal PrintCharacter	# Imprimimos el carácter
		addi $s3, $s3, 1	# Avanzamos en la cadena
		jal Delay			# Saltamos al retardo de la impresión
	j ImprimeFrase			#Volvemos a imprimir el siguiente carácter
	
PrintCharacter:
	
	la $t0, pControl		# Comprobamos el estado de la pantalla
	lb $t1, 0($t0)
	
	beqz $t1, PrintCharacter	
	
	sw $s2, pData		# Almacenamos el byte correspondiente en el registro
						# de datos de la pantalla
	jr $ra
	
Delay:			# Rutina de retardo
	
	li $s5, 50000
	
	Keep:

		addi $s5, $s5, -1
		bnez $s5, Keep
		
	jr $ra
	
TInterEnable:		# Rutina de interrupción del teclado

	la $s0, tControl		#Cargamos la direccion del registro de control del teclado
	li $s1, 0x2				#Cargamos un 0010 en hexadecimal
	
	sw $s1, 0($s0)
	
	mfc0 $t1, $12			#Movemos desde el coprocesador 0 hasta t1, el contenido del registro status
	
	ori $t1, $t1, 0x801
	mtc0 $t1, $12			#Movemos al procesador los cambios que hemos realizado 

	jr $ra
	
CaseIntr:		# Rutina que identifica de donde procede la interrupción
	
	sw $ra, pila		# Almacenamos en la variable pila la dirección de retorno
	
	mfc0 $t1, $13		# Movemos desde el coprocesador 0 hasta t1, el contenido del registro cause
	
	andi $s0, $t1, 0x800 # Si a0 != 0, la interrupción proviene del teclado y saltamos a la rutina de servicio del teclado
	bnez $s0, TInter
	
	lw $ra, pila		# Recuperamos la dirección de retorno
	jr $ra
	
TInter:		# Rutina de servicio de interrupción del teclado

	sw $ra, pila		# Almacenamos en la variable pila la dirección de retorno
	
	li $v0, 4
	la $a0, pulsacion	# Impresión “[Pulsación(“
	syscall
	
	lw $s1, num_pulsacion	# Entero que representa el número de veces que se ha generado una interrupción por teclado
	addi $s1, $s1, 1
	sw $s1, num_pulsacion
	
	li $v0, 1
	lw $a0, num_pulsacion	# Imprimir entero
	syscall
	
	li $v0, 4
	la $a0, parentesis		# Impresión “) = “ 
	syscall
	
	lb $s2, tData			# Cargamos el carácter pulsado por teclado que será mandado a la rutina PrintCharacter
	jal PrintCharacter
	
	li $v0, 4
	la $a0, corchete		# Impresión “] “
	syscall
	
	lw $ra, pila		# Recuperamos la dirección de retorno
	jr $ra