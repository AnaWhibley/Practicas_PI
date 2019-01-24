################################################################################
################################################################################	
# Realizar la programación que estime oportuna para atender al teclado por
# interrupciones. Habilitar el nivel de interrupción pertinente en el 
# procesador y habilitar generación de interrupciones en el teclado. 
# Cada vez se pulse una tecla se generará una interrupción que sera
# atendida por una rutina de servicio cuyo fin será leer el código
# de la tecla pulsada , actualizar un contador de pulsaciones que 
# indique el número de pulsaciones realizadas hasta ese momento,
# enviar a pantalla el mensaje " [Pulsación(número) = tecla pulsada] "
# y retornar al programa principal quedando todo listo para una nueva pulsación.
################################################################################
################################################################################	

# Zona de datos que contiene los registros para acceder a los puertos E/S del teclado y la pantalla
# mapeados por defecto en el MIPS

	.data 0xFFFF0000

tControl: .space 4 # Dirección  del registro de control del teclado (0xFFFF0000)
tData: .space 4 # Dirección  del registro de datos del teclado (0xFFFF0004)
pControl: .space 4 # Dirección  del registro de control de la pantalla (0xFFFF0008)
pData: .space 4 # Dirección del registro de datos de la pantalla (0xFFFF000C)

# Zona de datos en la que vamos a establecer los datos a usar en el programa
	
	.data 0x10000000

# Declaramos la frase que vamos a imprimir por consola
str_frase:	.asciiz "En un lugar de la Mancha cuyo nombre ....\n"
pulsacion: .asciiz " [Pulsacion("
numero_pulsacion: .word 0 # Variable que aumenta cada vez que se genera una interrupción
parentesis: .asciiz ") = "
letra: .space 1 # Variable que va a almacenar la letra pulsada para imprimirla luego
corchete: .asciiz "]\n"

# Variable que usaremos para almacenar la dirección de retorno proporcionada por $ra
# cada vez que se genera una interrupción
pila: .word 0

# Empieza el programa a partir de una dirección establecida por el simulador (0x40000000)
	.text 0x400000
	.globl main
main:

	jal KbdIntrEnable # Llamamos a la subrutina que activa las interrupciones en el teclado

	# Dejamos el programa en bucle continuo esperando interrupción por el teclado
	bucle:
	j bucle 

############################################################
# Utilidades
# -> PrintCharacter(): Imprime un dato en pantalla
###########################################################

# PrintCharacter(): Imprime un carácter en pantalla # $a0: Carácter a imprimir
PrintCharacter:

	la $s0, pControl # Cargamos la direccion del registro de control de la pantalla
	li $s1, 0x1 # Cargamos un 0010 en hexadecimal en s1

	# Comparamos el registro de la pantalla y la dirección 0x1 para saber si 
	# el bit menos significativo de la direccion de la pantalla está a uno (Preparado para recibir caracter)
	beq $s0, $s1, PrintCharacter 

	la $s3, pData # Cargamos la dirección del registro de datos de la pantalla
	sb $t1, 0($s3) # Almacenamos la tecla pulsada(Lo pasamos como t1 ya que lo guardamos en la rutina del servicio del teclado)

	jr $ra 

# KbdIntrEnable(): Subrutina de habilitación de interrupciones del teclado
KbdIntrEnable:
	
	la $s0 tControl # Cargamos la direccion del registro de control del teclado
	li $s1, 0x2 # Cargamos un 0010 en hexadecimal
	# Almacenamos en el registro de control los 4 bits anteriores en las 4 posiciones
	# menos significativas de manera que queda un 1 en el segundo bit y se activan las interrupciones
	sw $s1, 0($s0)

	mfc0 $t1, $12 # Movemos desde el coprocesador 0 hasta t1, el contenido del registro status
	# Hacemos un or del contenido de status con 1000 0000 0001 para poner a 1 el bit IE(Activa interrupciones)
	# y para poner un 1 en el campo IM3 que activa la mascara de interrupciones del teclado en el procesador 
	ori $t1, $t1, 0x801
	mtc0 $t1, $12 # Movemos al procesador los cambios que hemos realizado en el registro status

	jr $ra

# CaseIntr(): Detecta origen de la interrupción (teclado, timer u otros) y llama
# a la rutina de servicio que corresponda (KbdIntr o TimerIntr).
CaseIntr:

	sw $ra, pila # Almacenamos en la variable pila la direccion de retorno

	mfc0 $t1, $13 # Movemos desde el coprocesador 0 hasta t1, el contenido del registro cuase

	# Hacemos un andi con 1000 0000 0000 y lo almacenamos en a0 para saber si el campo IP3
	# del registro cause está a 1 y la interrupcion proviene del teclado
	andi $a0, $t1, 0x800 
	bnez $a0, KbdIntr # Si a0 != 0, la interrupcion proviene del teclado y saltamos a la rutina de servicio del teclado

	lw $ra, pila # Recuperamos de la variable pila la direccion de retorno
	jr $ra


# KbdIntr(): Rutina de servicio del teclado
KbdIntr:

	sw $ra, pila # Almacenamos en la variable pila la direccion de retorno
	lb $t1, tData # Cargamos en t1 el byte almacenado en el registro tData que corresponde a la tecla pulsada

	li $v0, 4 # Linea de código que carga la llamada al sistema predeterminada para imprimir una string
	la $a0, pulsacion # Cargamos en el registro a0 la string a imprimir por pantalla
	syscall # Llamada al sistema que imprimirá a0 por pantalla 

	lw $s1, numero_pulsacion # Cargamos en s1 un entero que representa el número de veces que se ha generado una interrupción por teclado
	addi $s1, $s1, 1 # Sumamos uno a la variable cada vez que se genera interrupción
	sw $s1, numero_pulsacion # Almacenamos el nuevo valor en la variable 
	li $v0, 1 # Linea de código que carga la llamada al sistema predeterminada para imprimir un entero por pantalla
	lw $a0, numero_pulsacion # Cargamos el entero en la variable a0 que por defecto carga los elementos que usarán las llamadas al sistema 
	syscall # Llamada al sistema que imprimirá a0 por pantalla 

	li $v0, 4 # Linea de código que carga la llamada al sistema predeterminada para imprimir una string
	la $a0, parentesis # Cargamos en el registro a0 la string a imprimir por pantalla
	syscall # Llamada al sistema que imprimirá a0 por pantalla 

	lb $t1, tData # Cargamos en t1 el caracter pulsado por teclado que será mandado a la rutina PrintCharacter
	jal PrintCharacter

	li $v0, 4 # Linea de código que carga la llamada al sistema predeterminada para imprimir una string
	la $a0, corchete # Cargamos en el registro a0 la string a imprimir por pantalla
	syscall # Llamada al sistema que imprimirá a0 por pantalla

	lw $ra, pila # Recuperamos de la variable pila la direccion de retorno
	jr $ra











	







