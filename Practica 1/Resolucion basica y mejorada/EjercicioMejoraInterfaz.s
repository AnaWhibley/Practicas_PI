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
	
	#Registros de los dispositivos de entrada/salida
	
		tControl:		.space 4  #Dirección del registro de control del teclado (0xFFFF0000)
		tData:			.space 4  #Dirección del registro de datos del teclado (0xFFFF0004)
		pControl:		.space 4  #Dirección del registro de control de pantalla (0xFFFF0008)
		pData:			.space 4  #Dirección del registro de datos de pantalla (0xFFFF000C)

	.data 0x10000000

# Mensajes interfaz

		string1:		.asciiz "*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*		    	Bienvenido a MathQuiz           	    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n\n"

		string2:		.asciiz "*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*			 Que quieres hacer?           	    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*									    *
* CTRL + S -> Calculadora				  	    *
* CTRL + T -> Jugar						    *
* CTRL + X -> Salir						    *
*									    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n\n"

		string3:		.asciiz "*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	        		Vuelve pronto!!!           	    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*									    *
* Autora: Ana Isabel Santana Medina		 		    *
* Grupo: 43							          *
*									    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n\n"
		
		string4:		.asciiz "*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 			  Vamos a jugar!!!			   *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n\n"

		string5:		.asciiz "*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 			  Que quieres calcular?			    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n\n"
 
 		saltoLinea:		.asciiz "\n\n"
		nombre: 		.asciiz "Introduce tu nombre: "
		eNombre:		.space 10							
		bienvenidaN: 	.asciiz "Bienvenid@, "

#Pruebas juego

	#Preguntas

		prueba1: 		.asciiz "Luca debe escribir un texto con 120 palabras y ya ha 
escrito 47. Indica cuantas le faltan: "
		prueba2:		.asciiz "En un tren habian 200 personas. Al llegar a la
estacion bajaron 95 y subieron al tren 30.
Cuantas personas iban en el tren al salir de la estacion? "
		prueba3:		.asciiz "Que numero es menor de 50 y es divisible por 2, 
3 y 5? "
		prueba4:		.asciiz "Hay gatos en un cajon, cada gato en un rincon, 
cada gato ve tres gatos, Sabes cuantos son? "

	# Respuestas
	
		respuesta:		.word 0

		correct:		.asciiz "\n\t~ Muy bien! Respuesta correcta :)\n\n"
		incorrect:		.asciiz "\n\t~ Oh, prueba suerte con la siguiente! Respuesta incorrecta :(\n\n"
		finpregunt:		.asciiz "*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* 	 OH! Se me han acabado las preguntas!		   *
*		Espero que hayas disfrutado			   *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n"
		
		ncorrectas:		.asciiz "\n\t--> El numero de preguntas correctas ha sido = "
		nincorrectas:	.asciiz "\n\t--> El numero de preguntas incorrectas ha sido = "

#Espacio calculadora

		nota:			.asciiz "\nTen en cuenta que si introduces una letra, 
sera como introducir un 0\n"
		primerNumero:	.asciiz "\nIntroducir primer numero: "
		segundoNumero:	.asciiz "\nIntroducir segundo numero: "

		operacion:	.asciiz "\n*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Seleccione la operacion quiera realizar:                *
*                                                         *
*  	Sumar        = 0                                    *
*  	Restar       = 1                                    *
*  	Multiplicar  = 2                                    *
*  	Dividir      = 3                                    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n"

		seleccionada:	.asciiz "\n\t--> Ha seleccionado = "
		resultado:		.asciiz "\n\t--> Resultado = "
		resto:			.asciiz "\n\t--> Resto de la division = "
		firstNum: 		.word -1
		secondNum:		.word 16

		otraVez:	.asciiz "\n*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Desea realizar otra operacion:                          *
*                                                         *
*  	SI  = 0                                             *
*  	NO  = 1                                             *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n"

	fraseFinalCal:	.asciiz "\n*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*       Introduce otro comando si quieres continuar       *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n"

#Variable para guardar dirección de retorno
		lastAddress:	.word 0
		
# Segmento de texto

	.text 0x00400000
	.globl main
	
# Programa principal

main:

	jal KbdIntrEnable
	
	jal PrintWelcome
	
ReadChar:
	
	j ReadChar
	
KbdIntrEnable:

	lw $s3, tControl 			# Carga el registro de control del teclado
	ori $s3, $s3, 2  			# Habilitacion de interrupciones por teclado
	sw $s3, tControl 
	
	mfc0 $t3, $12 				# Cargamos en t3 el registro status
	ori $t3, $t1, 0x801 		# Ponemos a 1 los bits que nos interesan del "status"
	mtc0 $t3, $12 				# Cargamos en el coprocesador t3 habilitando las interrupciones
	
	jr $ra
	
CaseIntr:
	
	sw $ra, lastAddress			# Guardamos la dirección de retorno
	 
	mfc0 $t2, $13 				# Obtenemos registro cause del coprocesador0 para ver de donde procede la interrupción
	
	andi $v0, $t2, 0x800 		#Comprobamos si es una interrupcion del teclado
	bnez $v0, KbdIntr
	
	lw $ra, lastAddress
	jr $ra
	
KbdIntr:

	sw $ra, lastAddress
	
	lb $t1, tData
	
	beq $t1, 0x13, Calculadora	#Comprobamos si es igual a CTRL+S
	beq $t1, 0x14, Juego		#Comprobamos si es igual a CTRL+T
	beq $t1, 0x18, Exit			#Comprobamos si es igual a CTRL+X
	
	lw $ra, lastAddress
	jr $ra
	
PrintWelcome:

	sw $ra, lastAddress
	
	li $v0, 4
	la $a0, string1				# Imprimimos frase de MathQuiz
	syscall
	
	li $v0, 4
	la $a0, nombre				# Pedimos nombre
	syscall
	
	li $v0, 8
	la $a0, eNombre				# Guardamos nombre
	li $a1, 10
	syscall
	
	li $v0, 4
	la $a0, saltoLinea			# Salto de línea
	syscall
	
	li $v0, 4
	la $a0, bienvenidaN			# Imprimimos la bienvenida con el nombre
	syscall
	
	li $v0, 4
	la $a0, eNombre				
	syscall
	
	li $v0, 4
	la $a0, saltoLinea			# Salto de línea
	syscall
	
	li $v0, 4
	la $a0, string2				# Preguntamos que quiere hacer el usuario
	syscall
	
	lw $ra, lastAddress
	
	jr $ra
	
Juego:
	
	la $t2, respuesta
	
	li $v0, 4
	la $a0, string4			# Imprime "Vamos a jugar!!"
	syscall

	Pregunta1:
		
		li $v0, 4
		la $a0, prueba1		# Imprime la pregunta 1
		syscall
			
		li $v0, 5
		syscall				# Lee el entero que se introduce por teclado
			
		move $t4, $v0		# Guardamos el entero en una variable para compararlo
			
		addi $t2, $0, 73	# Guardamos la respuesta en una variable
	
		beq $t2, $t4, Correcto1		# Si ambos son iguales saltamos a mostrar el mensaje de correcto
	
		li $v0, 4
		la $a0, incorrect	# Mostramos mensaje de incorrecto
		syscall
		
		addi $t6, $t6, 1	# Contador respuestas incorrectas
		
	Pregunta2:
	
		and $t2, $t2, $0	# Reiniciamos los registros, el resto funciona
		and $t4, $t4, $0	# de la misma manera que el método anterior
		
		li $v0, 4
		la $a0, prueba2	
		syscall
		
		li $v0, 5
		syscall
		
		move $t4, $v0
		
		addi $t2, $0, 135

		beq $t4, $t2, Correcto2

		li $v0, 4
		la $a0, incorrect
		syscall
			
		addi $t6, $t6, 1
		
	Pregunta3:
	
		and $t2, $t2, $0	# Reiniciamos los registros, el resto funciona
		and $t4, $t4, $0	# de la misma manera que el método anterior
		
		li $v0, 4
		la $a0, prueba3		#Pregunta 3
		syscall
			
		li $v0, 5
		syscall
		
		move $t4, $v0
			
		addi $t2, $0, 30
	
		beq $t4, $t2, Correcto3
	
		li $v0, 4
		la $a0, incorrect
		syscall
		
		addi $t6, $t6, 1
		
	Pregunta4:
	
		and $t2, $t2, $0	# Reiniciamos los registros, el resto funciona
		and $t4, $t4, $0	# de la misma manera que el método anterior
		
		li $v0, 4
		la $a0, prueba4		#Pregunta 4
		syscall
			
		li $v0, 5
		syscall
		
		move $t4, $v0
			
		addi $t2, $0, 4
	
		beq $t4, $t2, Correcto4
	
		li $v0, 4
		la $a0, incorrect
		syscall
		
		addi $t6, $t6, 1
			
	FinPreguntas:
		
		li $v0, 4 
		la $a0, finpregunt		# Mensaje fin de las preguntas
		syscall
		
		li $v0, 4
		la $a0, ncorrectas		# Preguntas correctas
		syscall
		
		li $v0, 1
		add $a0, $0, $t5
		syscall
		
		li $v0, 4
		la $a0, nincorrectas	# Preguntas incorrectas
		syscall
		
		li $v0, 1
		add $a0, $0, $t6
		syscall
		
		li $v0 4
		la $a0, saltoLinea		# Salto de línea
		syscall
			
		jal Exit
	
	Correcto1: 
	
		li $v0, 4
		la $a0, correct		# Mostramos mensaje de correcto
		syscall
		
		addi $t5, $t5, 1	# Contador preguntas correctas
		
		jal Pregunta2
	
	Correcto2:	

		li $v0, 4
		la $a0, correct		# Mostramos mensaje de correcto
		syscall
		
		addi $t5, $t5, 1	# Contador preguntas correctas
	
		jal Pregunta3
	
	Correcto3: 

		li $v0, 4
		la $a0, correct		# Mostramos mensaje de correcto
		syscall
	
		addi $t5, $t5, 1	# Contador preguntas correctas
	
		jal Pregunta4
	
	Correcto4:

		li $v0, 4
		la $a0, correct		# Mostramos mensaje de correcto
		syscall
	
		addi $t5, $t5, 1	# Contador preguntas correctas
	
		jal FinPreguntas
	
Calculadora:

	sw $ra, lastAddress
	
	li $v0, 4
	la $a0, string5
	syscall
	
	getPrimerNumero:
	
		li $v0 4
		la $a0, nota
		syscall

		li $v0 4
		la $a0, primerNumero	# Pedimos el primer número
		syscall

		li $v0, 5				# Guardamos el número y lo almacenamos
		syscall

		la $s1, firstNum	
		sw $v0, 0($s1)
		
	getSegundoNumero:
	
		li $v0 4
		la $a0, segundoNumero	# Pedimos el segundo número
		syscall

		li $v0, 5				# Guardamos el número y lo almacenamos		
		syscall

		la $s2, secondNum
		sw $v0, 0($s2)
		
	getOperacion:
	
		li $v0 4
		la $a0, operacion		# Pedimos la operación que se desea realizar
		syscall

		li $v0 4
		la $a0, seleccionada	# Operacion a realizar
		syscall

		li $v0, 5				# Opción
		syscall

	hacerOperacion:
	
		la $s1, firstNum		# Primer número
		lw $s2, 0($s1)

		la $s1, secondNum		#Segundo número
		lw $s3, 0($s1)

		# Comparamos con la opción seleccionada
		
		beq $v0, 0, sumar
		beq $v0, 1, restar
		beq $v0, 2, multiplicar
		beq $v0, 3, dividir
			
			sumar:
			
				jal ImprimirFraseResultado
				add $a0, $s2, $s3 			# Sumar
				jal ImprimirResultado
				j OperacionFinal
				
			restar:
			
				jal ImprimirFraseResultado
				sub $a0, $s2, $s3 			# Restar
				jal ImprimirResultado
				j OperacionFinal
				
			multiplicar:
			
				jal ImprimirFraseResultado

				mult $s2, $s3				# Multiplicar

				mfhi $a0					# Guarda el valor más significativo
				bnez $t0 ImprimirResultado

				mflo $a0 					# Guarda el valor menos significativo
				jal ImprimirResultado

				j OperacionFinal
				
			dividir:
			
				jal ImprimirFraseResultado

				div $s2, $s3

				mflo $a0				# Cociente
				jal ImprimirResultado

				li $v0, 4
				la $a0, resto 			# Resto
				syscall

				mfhi $a0
				jal ImprimirResultado
					
				j OperacionFinal

		ImprimirFraseResultado:
		
			li $v0, 4
			la $a0, resultado		# Imprime frase "Resultado = "
			syscall
			
			jr $ra

		ImprimirResultado:
		
			li $v0, 1		# Imprime el resultado
			syscall
			
			jr $ra

	OperacionFinal:
		
		li $v0 4
		la $a0, saltoLinea		# Salto de línea
		syscall

		li $v0 4
		la $a0, otraVez		# Preguntamos si se quiere realizar otra operacion
		syscall

		li $v0 4
		la $a0, seleccionada	# Opción seleccionada
		syscall

		li $v0, 5					# Opción			
		syscall

		beqz $v0, Calculadora		# Si es cero es que se quiere realizar otra operación

	final_Calculadora:
	
		li $v0 4
		la $a0, fraseFinalCal		# Si es un 1, saltamos aquí, mostramos frase de
		syscall						# final de calculadora

		li $v0 4
		la $a0, saltoLinea			# Salto de línea
		syscall

		lw $ra lastAddress			# Volveremos al bucle de pulsar un comando
		jr $ra
	
Exit:
	
	li $v0, 4
	la $a0, string3		# Imprimimos string de despedida
	syscall
	
	li $v0, 10
	syscall				# Fin de programa

