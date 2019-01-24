##
## Nombre: Ana Isabel Santana Medina
##
## Grupo: 43
##
## Fecha: 04/02/18
################################################################################
################################################################################

# Definición de los segmentos de datos

	.data 0xFFFF0000

	# Registros de los dispositivos de entrada/salida
	
	kControl:						.space 4	# Estado del teclado
	kData:  						.space 4	# Carácter pulsado
	pControl:						.space 4	# Estado de la pantalla
	pData:							.space 4	# Dato en pantalla - Carácter a imprimir 

# Registros de los dispositivos de entrada/salida

	.data 0x10000000

	# Frase a imprimir por el programa principal
	
	frase:							.asciiz "En un lugar de la Mancha cuyo nombre ....\n"

	# Definición del mensaje: "[Pulsación (n) = tecla]"
	
	pulsacion: 						.asciiz " [Pulsacion("
	pulsacionNum: 					.word 0
	parentesis: 					.asciiz ") = "
	letra: 							.space 1
	corchete:						.asciiz "] "

	# Implementación del reloj
	
	horas:							.word 0
	minutos:						.word 0
	segundos:						.word 0
	dosPuntos:						.asciiz ":"
	saltoLinea:						.asciiz "\n"
	
	horaLocal: 						.asciiz "\nHora Local: "				
	introducirHora: 				.asciiz "\nIntroducir Hora: "
	introducirMinutos: 				.asciiz "\nIntroducir Minutos: "
	introducirSegundos: 			.asciiz "\nIntroducir Segundos: "

	# Definición de los mensajes de errores
	
	errorHora: 						.asciiz "\n\tEl valor es incorrecto. Debe ser un numero entre 0 y 23\n"
	errorMinutosSegundos: 			.asciiz "\n\tEl valor es incorrecto. Debe ser un numero entre 0 y 59\n"

	# Referencias de auxiliares
	
	lastAddress:					.word 0		# Variable para guardar la dirección de retorno

# Segmento de texto

	.text 0x400000
	.globl main
	
# Inicio programa principal

main:

	jal Kbd_Timer_IntrEnable

	li $t8, 10				# Si el timer pasa de 9 se pone este a 10
	
	la $t7, 0x12 			#Código de Ctrl + R (Reloj)

	# Bucle que imprime la frase en pantalla de forma indefinida
	
	CargaFrase:
	
		la $s4, frase				# Cargamos la dirección de la frase a imprimir
		
	ImprimeFrase:
	
		lb $t1, 0($s4)				# Se lee un byte de la cadena
		
		beqz $t1, CargaFrase 		# Comprobamos que no es el final de la frase

		jal PrintCharacter			# Saltamos a imprimir el caracter
		addi $s4, $s4, 1			# Avanzamos en la frase
		jal Delay  					# Saltamos al retardo
	j ImprimeFrase					# Volvemos a ImprimeFrase

################################################################################
# PrintCharacter(): Rutina que imprime un dato en pantalla
################################################################################

PrintCharacter:

	la $s1, pControl 		    # Cargamos el registro control de la pantalla
	lb $s2, 0($s1) 					
	
	beqz $s2, PrintCharacter 	# Comprobación para ver si la pantalla está disponible
	
	sw $t1, pData				# Si esta listo guardamos el contenido

	jr $ra 

###########################################
# Delay(): Rutina para realizar un retardo
###########################################

Delay:

	li $s5, 50000				# Guardamos el tiempo de retardo
	
	LoopDelay:
	
		addi $s5, -1			# Decrementamos hasta llegar a 0 
		bnez $s5, LoopDelay	# Bucle que no termina hasta que el contador es 0

	jr $ra 

#####################################################################################
# Kbd_Timer_IntrEnable(): Rutina que habilita las interrupciones de teclado y timer
#####################################################################################

Kbd_Timer_IntrEnable:

	# Habilitación de interrupciones
	
	# 000000000010		=> 0x2		bit0  
	# 100000000001 		=> 0x801 	bit11 - IM3(bit11) - Teclado
	# 1000000000000001	=> 0x8000	bit15 - IM7(bit15) - Timer

	la $s0, kControl			# Carga el registro de control del teclado
	ori $s0, $s0, 0x2			# Habilitación de las interrupciones por teclado
	sw $s0, kControl

	mfc0 $t1, $12			# Lee el registro "status" del coprocesador0
	ori $t1, $t1, 0x8801	# Ponemos a 1 los bits que nos interesa del "status"
	mtc0 $t1, $12			# Carga el registro "status" en el coprocesador0

	# Compare
		li $t1, 1000 		# 1000 mseg > 1 seg (aproximadamente)
		mtc0 $t1, $11		# Carga el registro "compare" en el coprocesador0
	# Count
		mtc0 $0, $9			# Inicializamos el registro "count" a 0 y los cargamos en el coprocesador0

	jr $ra

####################################################################################################
# CaseIntr(): Detecta origen de la interrupción y llama a la rutina de interrupción correspondiente
####################################################################################################

CaseIntr:

	sw $ra, lastAddress		# Guardamos la dirección de retorno

	mfc0 $t1, $13			# Obtenemos registro cause del coprocesador0 para ver de donde procede la interrupción
	
	andi $v0, $t1, 0x800 		# Comprobamos si es una interrupción del teclado
	bnez $v0, KbdIntr 
	
	andi $v0, $t1, 0x8000 		# Comprobamos si es una interrupción del timer
	bnez $v0, TimerIntr 

	lw $ra, lastAddress			# Cargamos la dirección de retorno
	jr $ra

###############################################################
# KbdIntr(): Rutina de servicio de interrupciones del teclado
###############################################################

KbdIntr:

	sw $ra, lastAddress		# Guardamos la dirección de retorno
	lb $t1, kData 			# Traemos la tecla pulsada
	
	beq $t1, $t7, CtrlR 	# Comprobamos si es una interrupción por CTRL + R
	
	li $v0, 4
	la $a0, pulsacion			# Primera parte "[Pulsacion("
	syscall
	
	lw $s1, pulsacionNum 
	addi $s1, $s1, 1
	sw $s1, pulsacionNum			# Contador 
	lw $a0, pulsacionNum
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, parentesis			# Segunda parte ") = "
	syscall
	
	lb $t1, kData				# Carácter 
	jal PrintCharacter
	
	li $v0, 4
	la $a0, corchete			# Parte final "]"
	syscall

	lw $ra, lastAddress			# Cargamos la dirección de retorno
	jr $ra

##############################################################
# TimerIntr(): Rutina de servicio de interrupciones del timer
##############################################################

TimerIntr:

	sw $ra, lastAddress			# Guardamos la dirección de retorno
	
	ImprimeHoraLocal:			# Subrutina que imprime la hora local
	
		li $v0 4
		la $a0, saltoLinea		# Salto de línea
		syscall

		li $v0 4
		la $a0, horaLocal		# Imprimimos "Hora Local: "
		syscall

		li $v0, 1				# Imprimimos el entero
		la $t2, horas			# Lo guardamos en la variable para horas
		lw $s3, 0($t2)

		bge $s3, $t8, ActualizaHoras	# Comprobamos si el timer pasa de 10

		li $a0, 0				# Si no, pone un 0 antes del número 
		syscall
		
	ActualizaHoras:	
	
		lw $a0, 0($t2)		# Actualizamos el valor de las horas
    	syscall

    	li $v0, 4	
    	la $a0, dosPuntos	# Introducimos dos puntos para la separación
    	syscall

		li $v0, 1			# Imprimimos el entero
		la $t2, minutos		# Lo guardamos en la variable para minutos
		lw $s3, 0($t2)

		bge $s3, $t8, ActualizaMinutos	# Si es mayor o igual que 10, salta a los min

		li $a0, 0 						# Si no pone un 0 antes del digito único
		syscall

	ActualizaMinutos:	
	
		lw $a0, 0($t2)		# Actualizamos el valor de los minutos
    	syscall

    	li $v0, 4
    	la $a0, dosPuntos	# Introducimos dos puntos para la separación
    	syscall

    	li $v0, 1			# Imprimimos el entero
		la $t2, segundos	# Lo guardamos en la variable para segundos
		lw $s3, 0($t2)

		bge $s3, $t8, ActualizaSegundos	# Si es mayor o igual que 10, salta a los segundos
		
		li $a0, 0	# Si no, pone un 0 antes del número 
		syscall

	ActualizaSegundos:	
	
		lw $a0, 0($t2)		# Actualizamos el valor de los segundos
		syscall

		li $v0, 4						
		la $a0, saltoLinea		# Salto de línea		
		syscall							

		addi $s3, $s3, 5			# Suma 5 segundos

		bgt $s3, 59, IncrementarMinutos	# Si es mayor de 59 salta a incrementar los minutos

		sw $s3, 0($t2)	

		j FinalTimeIntr		# Salta al final del reloj

	IncrementarMinutos:
	
		li $s3, 0						# Pone a 0 los segundos
		sw $s3, 0($t2)

		la $t2, minutos

		lw $s3, 0($t2)
		addi $s3, $s3, 1				# Suma 1 minuto

		bgt $s3, 59, IncrementarHoras		# Si es mayor que 59 minutos reinicias

		sw $s3, 0($t2)

		j FinalTimeIntr		# Salta al final del reloj

	IncrementarHoras:
	
		li $s3, 0						# Pone a 0 los minutos
		sw $s3, 0($t2)

		la $t2, horas

		lw $s3, 0($t2)
		addi $s3, $s3, 1			# Suma 1 hora

		bgt $s3, 23, Clock_Reset	# Si es mayor que 24 horas reinicias

		sw $s3, 0($t2)

		j FinalTimeIntr		# Salta al final del reloj

	Clock_Reset:		# Reseteamos el reloj
	
		la $t2, horas 			
		sw $0, 0($t2)			# Pone a 0 las horas. Los minutos y segundos ya están a 0

		j FinalTimeIntr		# Salta al final del reloj

	FinalTimeIntr:
		
		mtc0 $0, $9		# Inicializamos el registro "count" a 0 y los cargamos en el coprocesador0

		lw $ra lastAddress		# Cargamos la dirección de retorno	
		
		jr $ra

############################################################################
# CtrlR(): Rutina que se ejecuta al presionar Ctrl + R, y solicita la hora
############################################################################

CtrlR:

		li $v0 4
		la $a0, saltoLinea		# Salto de línea
		syscall

	PedirHoras:
	
		li $v0, 4
		la $a0, introducirHora 	# Imprimimos "Introducir Hora: "
		syscall

		li $v0, 5				# Solicitamos un valor
		syscall

		addi $t0, $0, 0 		# Código para el error
		blt $v0, 0, Error_CtrlR	# Comprobamos que la hora no sea < 0
		bge $v0, 24, Error_CtrlR	# Comprobamos que la hora no sea >= 24

		la $t2, horas
		sw $v0, 0($t2)

	PedirMinutos:
	
		li $v0, 4
		la $a0, introducirMinutos 	# Imprimimos "Introducir Minutos: "
		syscall

		li $v0, 5 					# Solicitamos un valor
		syscall

		addi $t0, $0, 1 			# Código para el error
		blt $v0, 0, Error_CtrlR		# Comprobamos que los minutos no sean < 60
		bge $v0, 60, Error_CtrlR	# Comprobamos que los minutos no sean >= 60
		
		la $t2, minutos
		sw $v0, 0($t2)
		
	PedirSegundos:
	
		li $v0, 4
		la $a0, introducirSegundos 	# Imprimimos "Introducir Segundos: "
		syscall

		li $v0, 5					# Solicitamos un valor
		syscall

		addi $t0, $0, 2 			# Código para el error
		blt $v0, 0, Error_CtrlR		# Comprobamos que los segundos no sean < 60
		bge $v0, 60, Error_CtrlR	# Comprobamos que los segundos no sean >= 60

		la $t2, segundos
		sw $v0, 0($t2)

		li $v0 4
		la $a0, saltoLinea			# Salto de línea
		syscall

		lw $ra lastAddress			# Cargamos la dirección de retorno
		jr $ra

##################################################################################
# Error_CtrlR(): Rutina que se ejecuta al ocurrir un error en la hora introducida
##################################################################################

Error_CtrlR:

	# Saltar dependiendo del codigo de error al intruducir la hora local
	# 0 -> hora
	# 1 -> minutos
	# 2 -> segundos
	
	beqz $t0, ErrorHoras		# Si es igual a cero es que fue un error al introducir la hora
	
	la $a0, errorMinutosSegundos 	# Si no, fue un error de minutos o segundos, cargamos mensaje	
									# minutos y segundos
	j PrintError

ErrorHoras:
	
	la $a0, errorHora 		# Mensaje error horas
		
PrintError:
	
	li $v0 4						# Imprimimos la cadena previamente cargada
	syscall
	
	beqz $t0, PedirHoras				# Si es igual a cero, retornamos a pedir la hora

	addi $s1, $0, 1 					# Si es igual a uno 
	beq $t0, $s1, PedirMinutos			# Retornamos a pedir los minutos
	j PedirSegundos						# Si no, retornamos a pedir los segundos








