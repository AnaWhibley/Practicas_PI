# Definición de los segmentos de datos

	.data 0xFFFF0000
	
	#Registros de los dispositivos de entrada/salida
	
		tControl:		.space 4 #Dirección del registro de control del teclado (0xFFFF0000)
		tData:			.space 4 #Dirección del registro de datos del teclado (0xFFFF0004)
		pControl:		.space 4 #Dirección del registro de control de pantalla (0xFFFF0008)
		pData:			.space 4 #Dirección del registro de datos de pantalla (0xFFFF000C)

	.data 0x10000000

# Frase o carácter a imprimir por el programa principal

		frase: 			.asciiz "En un lugar de la Mancha cuyo nombre...\n"
		pulsacion:		.asciiz " [Pulsacion("
		num_pulsacion:	.word 0 # Variable que aumenta cada vez que se genera una interrupcion
		parentesis:		.asciiz	") = "
		letra:			.space 1 #Variable que va a almacenar la tecla pulsada para imprimirla
		corchete:		.asciiz "] "
		mprueba:		.asciiz "m"

# Variable que usaremos para almacenar la dirección de retorno proporcionada por $ra
# cada vez que se genera una interrupción
pila: 			.word 0

# Segmento de texto

	.text 0x00400000
	.globl main
	
# Programa principal
	
main:

	jal TTInterEnable #Llamamos a la subrutina que activa las interrupciones de teclado y timer
	
	#Bucle que imprimirá la frase infinitamente hasta que se produzca una interrupcion
	
	CargaFrase:

		la $s0, frase #Cargamos la direccion de la frase

	ImprimeFrase:
	
		lb $s1, 0($s0) #Cargamos el primer byte de la frase
	
		beqz $s1, CargaFrase	#Comprobamos que no es el final de la frase
	
		jal PrintCharacter #Saltamos a imprimir el caracter por pantalla
		addi $s0, $s0, 1 #Avanzamos en la frase
		jal Delay #Saltamos a delay
	j ImprimeFrase #Volvemos a imprime frase
	
PrintCharacter:
	
	la $t0, pControl
	lb $t1, 0($t0)
	
	beqz $t1, PrintCharacter
	
	sw $s1, pData
	jr $ra
	
Delay:
	
	li $s5, 50000
	
	Keep:

		addi $s5, $s5, -1
		bnez $s5, Keep
		
	jr $ra
	
TTInterEnable:

# Habilitacion de la interrupciones necesarias
	# 000000000010		=> 0x2		bit0  
	# 100000000001 		=> 0x801 	bit11 - IM3(bit11) - Teclado
	# 1000000000000001	=> 0x8000	bit15 - IM7(bit15) - Timer
	
	lw $s3, tControl #Carga el registro de control del teclado
	ori $s3, $s3, 2  #Habilitacion de interrupciones por teclado
	sw $s3, tControl 
	
	mfc0 $t3, $12 #Cargamos en t3 el registro status
	ori $t3, $t1, 0x8801 #Ponemos a 1 los bits que nos interesan del "status"
	mtc0 $t3, $12 #Cargamos en el coprocesador t3 habilitando las interrupciones
	
	# Compare
		li $t1, 100			# 1 seg (aproximadamente)
		mtc0 $t1, $11		# Carga el registro "compare" en el coprocesador0
	# Count
		mtc0 $0, $9			# Inicializamos el registro "count" a 0 y los cargamos en el coprocesador0

	jr $ra
	
# CaseIntr(): Detecta origen de la interrupción (teclado, timer u otros) y llama
# a la rutina de servicio que corresponda (KbdIntr o TimerIntr).
# $k0 = Al llamar a esta rutina $k0 = Registro de Cause

CaseIntr:
	
	sw $ra, pila # Guardamos la dirección de retorno
	
	mfc0 $t2, $13 	# Obtenemos registro cause del coprocesador0 
					# para ver de donde procede la interrupción
	
	# 0000100000000000 =>  0x800  => IM11
	andi $v0, $t2, 0x800 #Comprobamos si es una interrupcion del teclado
	bnez $v0, TInter
	
	# 1000000000000000 =>  0x8000 => IM15
	andi $v0, $t2, 0x8000 #Comprobamos si es una interrrupcion del timer
	bnez $v0, TimerInter
	
	lw $ra, pila
	jr $ra
	
TInter:

	sw $ra, pila
	
	li $v0, 4
	la $a0, pulsacion
	syscall
	
	lw $s4, num_pulsacion
	addi $s4, $s4, 1
	sw $s4, num_pulsacion
	li $v0, 1
	lw $a0, num_pulsacion
	syscall
	
	li $v0, 4
	la $a0, parentesis
	syscall
	
	lb $s1, tData
	jal PrintCharacter
	
	li $v0, 4
	la $a0, corchete
	syscall
	
	lw $ra, pila
	jr $ra
	
TimerInter:

	sw $ra, pila
	
	li $v0, 4
	la $a0, mprueba
	syscall
	
	mtc0 $0, $9
	lw $ra, pila
	jr $ra
	
	
	