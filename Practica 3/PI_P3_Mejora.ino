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
 * String con el menú que se muestra
 */

const String menu[] = {
    "Funciones principales: \n\n",                                                   /** 0[1] */
    "  1.- Turnomatic\n",                                                            /** 1[2] */
    "Funciones adicionales: \n",                                                     /** 3[4] */
    "\n  2.- Encender segmento (1-7)\n",                                             /** 4[5] */
    "  3.- Cambiar frecuencia (0, 8, 9) o reproducir cancion (*, #)\n\n"             /** 5[6] */
};

/**
 * Variables del display 7 Segmentos
 */

const int unidades = 49;    // Señal D4-C1 (pin 49, PL0)
const int decenas = 48;     // Señal D3-C2 (pin 48, PL1)
const int centenas = 47;    // Señal D2-C3 (pin 47, PL2)
const int millares = 46;    // Señal D1-nn (pin46, PL3)

int unidad = 0;   // Número a mostrar en el 7S
int decena = 0;   // Número a mostrar en el 7S
int centena = 0;  // Número a mostrar en el 7S
int millar = 0;   // Número a mostrar en el 7S

const int numeros[10] = {63,6,91,79,102,109,125,7,127,103};  // Números del 0 al 9 en hexadecimal
const int segmentos[7] = {1, 2, 4, 8, 16, 32, 64}; // Situación de los segmentos

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

boolean asterisco = false;  // Variable booleana para el asterisco
boolean teclaMejora = false;  // Variable booleana para el 0, 8, 9, *, #

int frecuenciaMejora;

/**
 * Notas musicales
 */

int c[5]={131,262,523,1046,2093};   // 4 octavas de Do
int cs[5]={139,277,554,1108,2217};  // Do#
int d[5]={147,294,587,1175,2349};   // Re
int ds[5]={156,311,622,1244,2489};  // Re#
int e[5]={165,330,659,1319,2637};   // Mi
int f[5]={175,349,698,1397,2794};   // Fa
int fs[5]={185,370,740,1480,2960};  // Fa#
int g[5]={196,392,784,1568,3136};   // Sol
int gs[5]={208,415,831,1661,3322};  // Sol#
int a[5]={220,440,880,1760,3520};   // La
int as[5]={233,466,932,1866,3729};  // La#
int b[5]={247,494,988,1976,3951};   // Si

//################################################################################################
// Comienzo del programa
//################################################################################################

/**
 * Preparación en la que activamos los puertos, sus correspondientes y las interrupciones.
 * Esta solo se realiza una vez.
 */

void setup() {

  Serial.begin(9600);     // Monitor Serie

  Serial.println("______   _____  ________  ____  _____  ____   ____  ________  ____  _____  _____  ______      ___    ");
  Serial.println("|_   _ \\ |_   _||_   __  ||_   \\|_   _||_  _| |_  _||_   __  ||_   \\|_   _||_   _||_   _ `.  .'   `.  ");
  Serial.println(" | |_) |  | |    | |_ \\_|  |   \\ | |    \\ \\   / /    | |_ \\_|  |   \\ | |    | |    | | `. \\/  .-.  \\ ");
  Serial.println(" |  __'.  | |    |  _| _   | |\\ \\| |     \\ \\ / /     |  _| _   | |\\ \\| |    | |    | |  | || |   | | ");  // Mensaje de bienvenida
  Serial.println("_| |__) |_| |_  _| |__/ | _| |_\\   |_     \\ ' /     _| |__/ | _| |_\\   |_  _| |_  _| |_.' /\\  `-'  / ");
  Serial.println("|______/|_____||________||_____|\\____|     \\_/     |________||_____|\\____||_____||______.'  `.___.'  \n");

  //###########################################################################################################################################################


  DDRA = B11111111; // Definimos el PORTA de salida (Bus de salida conectado al 7S)

  DDRC = B00000001; // Definimos el PORTC de entrada (pulsadores) salvo PC0 (salida frecuencia del altavoz)
  PORTC = B11111000; // Activamos el pull-up interno de las líneas entrada

  DDRL = B00001111; // Definimos el PORTL de entrada (teclado) menos los que son de salida (7S)
  PORTL = B11111111; // Activamos el pull-up interno de las líneas entrada PC7-PC3

//##########################################################################################################################################################

  tone(3, 100); // tone(pin, frequency) permite generar una señal por un pin de la frecuencia que se desee
  attachInterrupt(1, interrupciones, CHANGE); // Activamos interrupciones

  showMenu();  // Mostramos el menú
}

/**
 * Bucle único y principal, todo lo demás son métodos adicionales
 */

void loop() {

  if(!teclaMejora){
    if (digitalRead(penter) == LOW){  // Reset
      decena = 0;
      unidad = 0;
      beep();
    }else if (digitalRead(pup) == LOW){
      incrementarUnidad();
      beep();
    }else if (digitalRead(pdown) == LOW){
      decrementarUnidad();
      beep();
    }
  }else{
    if (digitalRead(pup) == LOW && digitalRead(pdown) == LOW){  // Vuelve a método principal
      teclaMejora = false;
      beep();
    }
  }

  delay(100);

  if(teclaMejora){
    noTone(3);
    interrupcionesMejora();
  }
}

//################################################################################################
// Funciones adicionales
//################################################################################################

/**
 * Función que muestra el menú
 */

void showMenu() {

  Serial.println("*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n");
  for (int i = 0; i <= 4; i++) {
    Serial.println(menu[i]);
  }
  Serial.println("\n*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n");
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

//################################################################################################
// Funciones del turnomatic
//################################################################################################

/**
  * Manejador de interrupciones
 */

void interrupciones(){

  // Manejador 7 Segmentos

  if(puntero == 0){
    encenderSS(unidad, puntero);
  }else if(puntero == 1){
    encenderSS(decena, puntero);
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
      asterisco = true;
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
      if(asterisco){
        teclaMejora = true;
      }
      return '#';
    }
  }
    return 'n';
}

/**
  * Funcion para cambiar la frecuencia con la que se emite el sonido del turnomatic al gusto siempre y cuando se haya pulsado '*' antes
 */

void cambiarFrecuencia (char c){
  if (asterisco){
    switch(c){
      case '0':
        frecuencia = 200;
        asterisco = false;
        break;
      case '1':
        frecuencia = 400;
        asterisco = false;
        break;
      case '2':
        frecuencia = 600;
        asterisco = false;
        break;
      case '3':
        frecuencia = 800;
        asterisco = false;
        break;
      case '4':
        frecuencia = 1000;
        asterisco = false;
        break;
      case '5':
        frecuencia = 1200;
        asterisco = false;
        break;
      case '6':
        frecuencia = 1400;
        asterisco = false;
        break;
      case '7':
        frecuencia = 1600;
        asterisco = false;
        break;
      case '8':
        frecuencia = 1800;
        asterisco = false;
        break;
      case '9':
        frecuencia = 2000;
        asterisco = false;
        break;
      default:
        break;
    }
  }
}

/**
  * Funcion para manejar las decenas y unidades con el turnomatic
  */

void encenderSS(int n, int p){
  if (p == 0){
    PORTL = B11111110;  // Encender unidades
    PORTA = numeros[n];
  }else if(p == 1){
    PORTL = B11111101;  // Encender decenas
    PORTA = numeros[n];
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

//################################################################################################
// Implementación de mejoras
//################################################################################################

/**
 * Manejador de interrupciones para la mejora
 */

void interrupcionesMejora(){

  // Manejador 7 Segmentos

  if(puntero == 0){
    PORTA = 0;          // Evitar efecto fantasma
    PORTL = B11111110;  // Encender unidades
  }else if(puntero == 1){
    PORTA = 0;          // Evitar efecto fantasma
    PORTL = B11111101;  // Encender decenas
  }else if(puntero == 2){
    PORTA = 0;          // Evitar efecto fantasma
    PORTL = B11111011;  // Encender centenas
  }

  // Manejador teclado

  char tecla = lecturaTeclado();
  if (tecla != 'n'){ // n = no
    teclaPulsada(tecla);
  }

  puntero++;

  // Resetear

  if(puntero == 3){
    puntero = 0;
  }
}

/**
  * Funcion para encender el segmento que se desee, quedando reservados el 0, el 8, y el 9 para cambio
  * de frecuencias y el * y el # reservados para reproducir una canción
 */

void teclaPulsada(char tecla){
  boolean beepMejora = false;
  switch(tecla){
      case '0':
        frecuenciaMejora = 1600;
        beepMejora = true;
        break;
      case '1':
        encenderSegmento(0);
        break;
      case '2':
        encenderSegmento(1);
        break;
      case '3':
        encenderSegmento(2);
        break;
      case '4':
        encenderSegmento(3);
        break;
      case '5':
        encenderSegmento(4);
        break;
      case '6':
        encenderSegmento(5);
        break;
      case '7':
        encenderSegmento(6);
        break;
      case '8':
        frecuenciaMejora = 1800;
        beepMejora = true;
        break;
      case '9':
        frecuenciaMejora = 2000;
        beepMejora = true;
        break;
      case '*':
        cancion();
        tone(3, 100);
        break;
      case '#':
        cancion();
        tone(3, 100);
        break;
    }

    if(beepMejora){
      tone(speaker, frecuenciaMejora, 200);
      delay(100);
      noTone(speaker);
    }
}

/**
 * Función para encender un segmento del 7 Segmentos
 */

void encenderSegmento(int tecla){
  PORTL = B11111110;  // Encender unidades
  PORTA = segmentos[tecla];
  delay(500);
}

 /**
  * Manejador de frecuencia para la canción
  */

void nota(int frecuenciaSong, int retardo){
    tone(speaker, frecuenciaSong); // suena la nota frec recibida
    delay(retardo);                // para despues de un tiempo t
}

/**
 * Canción
 */

void cancion(){
  nota(a[1],800);
  noTone(speaker);
  delay(400);

  nota(e[1],800);
  noTone(speaker);
  delay(400);

  nota(a[1],800);
  noTone(speaker);
  delay(200);

  nota(e[1],400);
  noTone(speaker);
  delay(200);

  nota(a[1],400);
  noTone(speaker);
  delay(200);

  nota(as[1],200);
  noTone(speaker);
  delay(100);

  nota(b[1],800);
  noTone(speaker);
  delay(400);

  nota(fs[1],800);
  noTone(speaker);
  delay(400);

  nota(b[1],800);
  noTone(speaker);
  delay(200);

  nota(fs[1],400);
  noTone(speaker);
  delay(200);

  nota(b[1],400);
  noTone(speaker);
  delay(200);

  nota(as[1],200);
  noTone(speaker);
  delay(100);

  nota(a[1],800);
  noTone(speaker);
  delay(400);

  nota(e[1],800);
  noTone(speaker);
  delay(400);

  nota(a[1],800);
  noTone(speaker);
  delay(400);
}
