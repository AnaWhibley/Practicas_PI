# Definición de los segmentos de datos

# Registros de los dispositivos de entrada/salida
	.data 0xFFFF0000

	# Registros de los dispositivos de entrada/salida
	kControl:	.space 4	# Estado del teclado
	kData:  	.space 4	# Carácter pulsado
	pControl:	.space 4	# Estado de la pantalla
	pData:		.space 4	# Dato en pantalla - Carácter a imprimir 

# Registros de los dispositivos de entrada/salida
	.data 0x10000000

	# Caracter a imprimir por el programa principal
	frase:	.asciiz "Esto es una frase de prueba \n"
	
# Segmento de texto
	.text 0x00400000
	.globl main

# Programa principal
main:
	
	jal PrintCharacter
	j main

PrintCharacter:
	
	la $s1, frase 			#Cargamos la dirección de la frase 
	
checkPantalla:

	la $s2, pControl  		#Con esta rutina comprobamos si la pantalla está lista 
	lb $s3, 0($s2)
	
	beqz $s3, checkPantalla
	
printPantalla:

	lb $s4, 0($s1) 			#Si está lista, almacenamos el primer byte de la frase 
	sb $s4, pData 			#y lo guardamos en pData
	beqz $s4, PrintCharacter 
	
	addi $s1, $s1, 1 		#Sumamos 1 para avanzar al siguiente caracter de la frase
	jal Delay 				#Saltamos al retardo
	j printPantalla 		#Cuando volvemos del retardo saltamos a imprimir por pantalla para seguir imprimiendo la frase
	
Delay:
	
	li $s5, 50000 			#Cargamos un valor inmediato que será el tiempo que tarde en mostrar el caracter
	
keep:

	addi $s5, $s5, -1 		#Decrementamos el tiempo
	bnez $s5, keep 			#Hasta que no sea cero no retornamos
	jr $ra