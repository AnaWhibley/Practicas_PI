######################################################################
# Nombre: Ana Isabel Santana Medina
######################################################################

# Zona de datos que contiene los registros para acceder a los puertos E/S del teclado y la pantalla mapeados por defecto en el MIPS

	.data 0xFFFF0000
	
		tControl:		.space 4 #Dirección del registro de control del teclado (0xFFFF0000)
		tData:			.space 4 #Dirección del registro de datos del teclado (0xFFFF0004)
		pControl:		.space 4 #Dirección del registro de control de pantalla (0xFFFF0008)
		pData:			.space 4 #Dirección del registro de datos de pantalla (0xFFFF000C)
		
	#Zona de datos en la que vamos a establecer los datos a usar en el programa
	
	.data 0x10000000
	
	#Declaramos la frase que vamos a imprimir por consola cada vez que pulsemos CNTL-S
	
	trap:			.asciiz "[CNTL-S => TrapException!!]"
	
	# Empieza el programa a partir de una dirección establecida por el simulador (0x00400000)
	
	.text 0x400000
	.globl main

##########################################################################################################
# main(): Programa principal en forma de bucle
##########################################################################################################
	
#Comienzo del programa principal

main: 
	
	jal LeerTeclado 			
	j main
	
##########################################################################################################
# LeerTeclado(): Función que cada vez que es llamada devuelve en $a0 el código ASCII de la tecla pulsada
##########################################################################################################

LeerTeclado:
	
	la $t0, tControl 			#Cargamos la dirección del registro de control del teclado
	lb $a0, 0($t0)				#Cargamos el byte que se encuentra en t0
	
	beqz $a0, LeerTeclado 		#Si no es 1 seguimos comprobando LeerTeclado hasta que se pulse una tecla (en ese momento será 1)
	
	li $t1, 0x13				#Cargamos en t1 el código de CNTL+S (Código 19 = 0x13)
	lb $a0, tData				#Cargamos en el registro de datos del teclado la tecla pulsada 
	
	teq $a0, $t1				#teq $0,$0 es una instrucción que genera una excepción de tipo trap si dos registros son iguales, por lo tanto
								#en el momento en el que la tecla pulsada se corresponda con el código de CNTL+S se generará una excepción
	
##########################################################################################################
# PrintCharacter(): Función que muestra en pantalla el caracter que se le pasa en $a0
##########################################################################################################

PrintCharacter: 
	
	sb $a0, pData 				#Almacenamos el dato de $a0 (el caracter) en el registro de datos de la pantalla
	
	jr $ra
	
##########################################################################################################
# TrapException(): Función que muestra en pantalla el caracter que se le pasa en $a0
##########################################################################################################

TrapException:
	
	li $v0, 4					#Código para imprimir por pantalla el mensaje cuando se produce una excepción de tipo trap
	la $a0, trap
	syscall
	
	jr $ra