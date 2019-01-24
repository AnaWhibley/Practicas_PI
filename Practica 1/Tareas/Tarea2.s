#Realizar una subrutina, de nombre PrintCharacter, para imprimir un 
#caracter al dispositivo de salida (pantalla) utilizando la 
#sincronización por consulta de estado. El caracter a imprimir se le 
#pasa en el registro $a0.

#Definición de los segmentos de datos

#Registros de los dispositivos de entrada/salida
	.data 0xFFFF0000

	#Registros de los dispositivos de entrada/salida
	kControl:	.space 4	#Estado del teclado
	kData:  	.space 4	#Carácter pulsado
	pControl:	.space 4	#Estado de la pantalla
	pData:		.space 4	#Dato en pantalla - Carácter a imprimir 

#Registros de los dispositivos de entrada/salida
	.data 0x10000000

	#Caracter a leer por el programa principal
	
	caracter: .space 4

#Segmento de texto
	.text 0x00400000
	.globl main
	
#Programa principal
main:
	jal ReadCharacter 
	j main
	
ReadCharacter:
	la $s1, kControl #Cargamos la dirección en la que se encuentra el registro de control del teclado
	lb $s2, 0($s1) #Cargamos el byte que se encuentra en el registro anterior
	
	beqz $s2, ReadCharacter #Si dicho byte es cero es que el teclado no ha recibido nada
	
	lb $s3, kData 	#Cargamos el byte en el espacio para guardar el caracter pulsado
	
	jr $ra