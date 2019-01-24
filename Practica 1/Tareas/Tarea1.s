#Realizar una subrutina, de nombre PrintCharacter, para imprimir un 
#caracter al dispositivo de salida (pantalla) utilizando la 
#sincronización por consulta de estado. El caracter a imprimir se le 
#pasa en el registro $a0.

#Definición de los segmentos de datos

#Registros de los dispositivos de entrada/salida
	.data 0xFFFF0008

	#Registros de los dispositivos de entrada/salida
	#kControl:	.space 4	#Estado del teclado
	#kData:  	.space 4	#Carácter pulsado
	pControl:	.space 4	#Estado de la pantalla
	pData:		.space 4	#Dato en pantalla - Carácter a imprimir 

#Registros de los dispositivos de entrada/salida
	.data 0x10000000

	#Caracter a imprimir por el programa principal
	
	caracter: .asciiz "a"

#Segmento de texto
	.text 0x00400000
	.globl main
	
#Programa principal
main:
	
	jal PrintCharacter
	j main
	
#Pantalla preparada
PrintCharacter:

	la $s3, caracter		#Cargamos la dirección de caracter en el registro s3
	lb $a0, 0($s3)			#Cargamos el byte que se encuentra en s3 en a0
	
	la $s1, pControl		#Cargamos la direccion del registro de estado de pantalla
	lb $s2, 0($s1)			#Cargamos el byte que se encuentra en el registro de estado de la pantalla
	
	beqz $s2, PrintCharacter	#Si ese byte es igual a cero retornamos a PrintCharacter pues la pantalla
								#no está lista
	sb $a0, pData				#Guardamos el byte en el espacio para lo que mostramos en pantalla
	
	