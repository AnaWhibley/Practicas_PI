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
	frase:	.space 4
	
# Segmento de texto
	.text 0x00400000
	.globl main
	
# Programa principal
main:

	jal ReadCharacter		
	j main

ReadCharacter:
		
	la $s1, kControl #Cargamos la direccion del registro del teclado
	lb $s2, 0($s1) #Cargamos el byte que se encuentra en el registro
	
	beqz $s2, ReadCharacter #Si ese byte es cero es que no se ha pulsado ningun caracter
	
	lb $a0, kData	#Cargamos el caracter pulsado en kData

PrintCharacter:
	
	la $s1, pControl #Cargamos la direccion del registro de pantalla
	lb $s2, 0($s1)	#Cargamos el byte que se encuentra en el registro anterior
	
	beqz $s2, PrintCharacter #Si ese byte está a cero es que la pantalla no esta lista
	
	sb $a0, pData #Guardamos el byte en pData para imprimir por pantalla
	
	jr $ra