/**
 * 
 * Autor: Ana Isabel Santana Medina
 * Grupo: 43
 * Fecha: 26/04/18
 * 
 */
 
//################################################################################################
// Definición de variables del programa
//################################################################################################


/**
 * Variables del play 7 Segmentos
 */

const int unidades = 49;    // Señal D4-C1 (pin 49, PL0)
const int decenas = 48;     // Señal D3-C2 (pin 48, PL1)
const int centenas = 47;  // Señal D2-C3 (pin 47, PL2)
const int millares = 46;  // Señal D1-nn (pin46, PL3)

int unidad = 0;   // Número a mostrar en el 7S
int decena = 0;   // Número a mostrar en el 7S
int centena = 0;  // Número a mostrar en el 7S
int millar = 0;   // Número a mostrar en el 7S

const int numeros[10] = {63,6,91,79,102,109,125,7,127,103};  // Números del 0 al 9 en hexadecimal

/**
 * Variables de los pulsadores y altavoz 
 */

const int pup = 34; // Pin botón arriba (PC3-in)
const int pdown = 31; // Pin botón abajo (PC6-in)
const int pright = 30; // Pin botón derecha (PC7-in)
const int pleft = 32; // Pin botón izquierda (PC5-in)
const int penter = 33; // Pin botón centro (enter) (PC4-in)

const int speaker = 37; // Pin altavoz (PC0-out)

/**
 * Variables auxiliares
 */

int puntero = 0;              // Variable controlar barrido

int frecuencia = 200;       // Variable para guardar el tono actual
char alm = ' ';       // Buffer donde almacena el '*' si se pulso

//################################################################################################
// Comienzo del programa
//################################################################################################

/**
 * Preparación en la que activamos los puertos, sus correspondientes y las interrupciones.
 * Esta solo se realiza una vez.
 */

void setup() {
  
  Serial.begin(9600);     // Monitor Serie
  
//###########################################################################################################################################################

  DDRA = B11111111; // Definimos el PORTA de salida (Bus de salida conectado al 7S)

  DDRC = B00000001; // Definimos el PORTC de entrada (pulsadores) salvo PC0 (salida frecuencia del altavoz)
  PORTC = B11111000; // Activamos el pull-up interno de las líneas entrada 

  DDRL = B00001111; // Definimos el PORTL de entrada (teclado) menos los que son de salida (7S)
  PORTL = B11111111; // Activamos el pull-up interno de las líneas entrada PC7-PC3

//##########################################################################################################################################################

  tone(3, 100); // tone(pin, frequency) permite generar una señal por un pin de la frecuencia que se desee
  attachInterrupt(1, interruption, CHANGE); // Activamos interrupciones
}

/**
 * Bucle único y principal, todo lo demás son métodos adicionales
 */
 
void loop() {
  
  if(digitalRead(pup)) == LOW){ 
    incrementarUnidad();
    beep();
  }else if(digitalRead(pdown) == LOW){ 
    decrementarUnidad();
    beep();
  }else if(digitalRead(pup) == LOW && digitalRead(pdown)){
    decena = 0;
    unidad = 0;
    beep();
  }
  delay(100);
}

//################################################################################################
// Funciones del turnomatic
//################################################################################################

/**
  * Manejador de interrupciones
 */
 
void interruption(){
  
  // Manejador 7 Segmentos
  
  if(puntero == 0){
    encenderplay(unidad, puntero);
  }else if(puntero == 1){
    encenderplay(decena, puntero);
  }else if(puntero == 2){
    PORTA = 0;          // Evitar efecto fantasma
    PORTL = B11111011;  // Encender centenas
  }
  
  // Manejador teclado
  char tecla = lecturaTeclado();
  if (tecla != 'n'){ 
    cambiarFrecuencia(tecla);
  }

  if(puntero == 2){
    PORTL = B11111111;  // Apagar centenas
  }

  puntero++;
  
  // Resetear
  if(puntero == 3){
    puntero = 0;
  }
}

/**
  * Funcion detecta que tecla hemos apretado
 */
 
char lecturaTeclado(){
  if(puntero == 0){
    if (digitalRead(42) == LOW){
      return '1';
    }else if (digitalRead(43) == LOW){
      return '4';
    }else if (digitalRead(44) == LOW){
      return '7';
    }else if (digitalRead(45) == LOW){
      return '*';
    }
  }else if(puntero == 1){
    if (digitalRead(42) == LOW){
      return '2';
    }else if (digitalRead(43) == LOW){
      return '5';
    }else if (digitalRead(44) == LOW){
      return '8';
    }else if (digitalRead(45) == LOW){
      return '0';
    }
  }else{
    if (digitalRead(42) == LOW){
      return '3';
    }else if (digitalRead(43) == LOW){
      return '6';
    }else if (digitalRead(44) == LOW){
      return '9';
    }else if (digitalRead(45) == LOW){
      return '#';
    }
  }
  return 'n';
}

/**
  * Funcion para cambiar la frecuencia con la que se emite el sonido del turnomatic al gusto siempre y cuando se haya pulsado '*' antes
 */
 
void cambiarFrecuencia (char c)
{
  if (alm == '*'){
    switch(c){
      case '0':
        frecuencia = 200;
        alm = ' ';
        break;
      case '1':
        frecuencia = 400;
        alm = ' ';
        break;
      case '2':
        frecuencia = 600;
        alm = ' ';
        break;
      case '3':
        frecuencia = 800;
        alm = ' ';
        break;
      case '4':
        frecuencia = 1000;
        alm = ' ';
        break;
      case '5':
        frecuencia = 1200;
        alm = ' ';
        break;
      case '6':
        frecuencia = 1400;
        alm = ' ';
        break;
      case '7':
        frecuencia = 1600;
        alm = ' ';
        break;
      case '8':
        frecuencia = 1800;
        alm = ' ';
        break;
      case '9':
        frecuencia = 2000;
        alm = ' ';
        break;
      default:
        break;
    }
  }else if (c == '*'){
    alm = c;
  }
}

/**
  * Funcion para manejar las decenas y unidades con el turnomatic
 */
 
void encenderplay(int n, int p){
  if (p == 0){
    PORTL = B11111110;  // Encender unidades
    PORTA = numeros[n];
  }else if(p == 1){
    PORTL = B11111101;  // Encender decenas
    PORTA = numeros[n];
  }
}

/**
  * Función que incementa las unidades
 */
 
void incrementarUnidad(){
  unidad++;
  if (unidad > 9){
    unidad = 0;
    incrementarDecena();
  }
}

/**
  * Función que incrementa las decenas
 */
void incrementarDecena(){
  decena++;
  if (decena > 9){
    decena = 0;
    unidad = 0;
  }
}

/**
  * Función que decrementa las unidades
 */
void decrementarUnidad(){
  unidad--;
  if (unidad < 0 && decena > 0){
    decrementarDecena();
    unidad = 9;
  }else if (unidad < 0){
    unidad = 9;
    decena = 9;
  }
}

/**
  * Función que decrementa las decenas
 */
void decrementarDecena(){
  decena--;
  if (decena == 0){
    unidad = 0;
  }else if (decena < 0){
    decena = 0;
  }
}

/**
 * Función que reproduce un pitido con una frecuencia determinada
 */

void beep(){
    noTone(3);  // noTone(pin) Desactivamos para aplicar la modificacion de la frecuencia
    tone(speaker, frecuencia, 100);  // tone(pin, frequency, duration) Pita
    delay(100);
    noTone(speaker);  // Dejamos de aplicar la frecuencia al pin del speaker
    tone(3, 100); // Ponemos la frecuencia por defecto
}


