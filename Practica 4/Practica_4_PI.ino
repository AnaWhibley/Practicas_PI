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

const int P_ctn = 47;        // Pin del tercer display
const int P_dcn = 48;        // Pin del segundo display
const int P_udd = 49;        // Pin del primer display
const int zumbador = 37;     // Pin del zumbador

const int listanum[12] = {63,6,91,79,102,109,125,7,127,103,1,8}; // Lista con los numeros que muestran los numero decimales en el display

const int B_der = 30, B_bajo = 31, B_izq = 32, B_cntr = 33, B_alto = 34;

int pause = 1;
int contador = 0;
int numaleat = 0;
int numero[3] = {0,0};
int pos = 1;
int pulsado = 0;
char teclapld = 'x';
int segundo = 0;
int dificultad = 1;

int N_dcn = 0;                // Variable que guarda el numero el número del primer display
int N_udd = 0;                // Variable que guarda el numero el número del segundo display
int cmbdisp = 0;              // Cambia entre en las unidades, decenas y centenas continuamente 


void setup() {
  Serial.begin(9600);
  Serial3.begin(9600);

  // Puerto A
  DDRA = B11111111; // BUS para enviar datos al display

  // Puerto C
  DDRC = B00000001; // Puerto para los pulsadores
  PORTC= B11111000;

  // Puerto L
  DDRL = B00001111; // Puerto para el teclado
  PORTL = B11111111;

  attachInterrupt(1, isr, CHANGE); // cuando se produce salta al método ISR
  N_dcn = 6;
  N_udd = 0;

  limpieza();
}


void loop() {
  while(pause == 1){
    pause = digitalRead(B_alto);
    if (pause == 0){
      limpieza();
      tone(3, 100);                    // genera interrupción cada 10 ms
      if (dificultad == 1){
        N_dcn = 6;
        N_udd = 0;
      }
      if (dificultad == 3){
        N_dcn = 4;
        N_udd = 0;
      }
      if (dificultad == 8){
        N_dcn = 2;
        N_udd = 0;
      }
      numaleat = random(100);
    }
    if (digitalRead(B_bajo) == LOW && pause == 1){
      char t = tclpld();
      int i = 0;
      while (i == 0){
        if (t == '0'){
          dificultad = 1;
          i = 1;
        }
        if (t == '1'){
          dificultad = 3;
          i = 1;
        }
        if (t == '2'){
          dificultad = 8;
          i = 1;
        }
        t = tclpld();
        cmbDisplay();
      }
      Serial.print(dificultad);
    }
  }
  
  if (digitalRead(B_alto) == LOW && digitalRead(B_bajo) == LOW){
    segundo = 0;
    pulsado = 0;
    apagado();
  }
  if (segundo == 1){
    disminuir_udd();
    segundo = 0;
  }
  
  if (pulsado == 1){
    int result = comprobarNumero(teclapld);
    delay(200);
    pulsado = 0;
    if (result == 1){
      comprobarResult();
    }
  } 
}

void cmbDisplay(){
  cmbdisp++;
  if (cmbdisp == 3){
    PORTL = B11111111;
    cmbdisp = 0;
  }
  if (cmbdisp == 0){
    PORTA = 0;
    PORTL = B11111110;
  }
  if (cmbdisp == 1){
    PORTA = 0;
    PORTL = B11111101;
  }
  if (cmbdisp == 2){
    PORTA = 0;
    PORTL = B11111011;
  }
}

void isr(){             // Rutina que se ejecuta cuando se produce la interrupción
  if (pulsado == 0){
    contador++;
    if (contador == 100){
      segundo = 1;
      contador = 0;
    }
    if(cmbdisp == 0){
      vis_disp(N_udd, cmbdisp);
    }else if(cmbdisp == 1){
      vis_disp(N_dcn, cmbdisp);
    }else if(cmbdisp == 2){
      PORTA = 0;          // Enciende el tercer display sin mostrar nada para evitar el efecto fantasma.
      PORTL = B11111011;
    }
    
    char tecla = tclpld();
    if (tecla != 'x'){ // x significar que no hay tecla pulsada.
      pulsado = 1;
      teclapld = tecla;
    }

    if(cmbdisp == 2){
      PORTL = B11111111;  // Apagar el tercer display
    }
  
    cmbdisp++; // Cambia de display
    
    if(cmbdisp == 3){ // Vuelve a las unidades
      cmbdisp = 0;
    }
  }
}

int comprobarNumero(char tecla){
  if(pos == -1){
    if (tecla == '#'){
      return 1;
    } else if (tecla == '*'){
      asterisco(5000);
    } else {
      fallo();
    }
  }
  switch(tecla){
      case '0':
        numero[pos] = 0;
        pos--;
        break;
      case '1':
        numero[pos] = 1;
        pos--;
        break;
      case '2':
        numero[pos] = 2;
        pos--;
        break;
      case '3':
        numero[pos] = 3;
        pos--;
        break;
      case '4':
        numero[pos] = 4;
        pos--;
        break;
      case '5':
        numero[pos] = 5;
        pos--;
        break;
      case '6':
        numero[pos] = 6;
        pos--;
        break;
      case '7':
        numero[pos] = 7;
        pos--;
        break;
      case '8':
        numero[pos] = 8;
        pos--;
        break;
      case '9':
        numero[pos] = 9;
        pos--;
        break;
      case '#':
        return 1;
      case '*':
        asterisco(5000);
        limpieza();
        return 0;
      default:
        break;
  }
  if (pos != 1){
    escrituraNumero(numero[pos+1]);
  }
  return 0;
}

void escrituraNumero(int n){
  if (pos == 0){
    limpieza();
    Serial3.write("Tu numero: ");
  }
  Serial3.print(n);
}

void comprobarResult(){
  int result = 100;
  if (pos == -1){
    result = numero[1]* 10 + numero[0];
  } else {
    result = numero[1];
  }
  if (result == numaleat){
    escrituraGanadora();
    asterisco(200);
    delay(100);
    asterisco(1000);
    delay(100);
    asterisco(4000);
    parpadear();
    apagado();
  } else {
    if (result > numaleat){
      escrituraFallo(1);
      fallo();
      //mayorOMenor(1);
    } else {
      escrituraFallo(-1);
      fallo();
    }
    pos = 1;
  }
}

void escrituraFallo(int i){
  Serial3.write(0xFE); Serial3.write(0x45); Serial3.write(0x14);
  Serial3.write("Has fallado!!");
  Serial3.write(0xFE); Serial3.write(0x45); Serial3.write(0x54);
  if (i == 1){
    Serial3.write("Oh.. Es menor");
  } else{
    Serial3.write("Mmm.. Es mayor");
  }
  Serial3.write(0xFE); Serial3.write(0x45); Serial3.write(0x00);
}

void escrituraGanadora(){
  Serial3.write(0xFE); Serial3.write(0x45); Serial3.write(0x14);
  Serial3.write("Genial! You win");
  Serial3.write(0xFE); Serial3.write(0x45); Serial3.write(0x54);
  Serial3.write("Puntuacion: ");
  int result = (N_dcn*10 + N_udd)* dificultad;
  Serial3.print(result);
}

void asterisco(int frec){
  noTone(3);
  tone(zumbador, frec, 100);
  delay(100);
  noTone(zumbador);
  tone(3, 100);
  pos = 1;
  numero[1] = 0;
  numero[0] = 0;
}

void fallo(){
  asterisco(4000);
  delay(100);
  asterisco(1000);
  delay(100);
  asterisco(100);
}

void parpadear(){
  for(int i = 0; i < 40; i++){
    detachInterrupt(1);
    delay(50);
    attachInterrupt(1, isr, CHANGE);
  }
  tone(3,100);
}

void apagado(){
  pause = 1;
  noTone(3);
  delay(100);
  PORTL = B11111111;
}
/**
  * Funcion detecta que tecla hemos apretado
 */
char tclpld(){
  if(cmbdisp == 0){
    if (digitalRead(42) == LOW){
      return '1';
    }else if (digitalRead(43) == LOW){
      return '4';
    }else if (digitalRead(44) == LOW){
      return '7';
    }else if (digitalRead(45) == LOW){
      return '*';
    }
  }else if(cmbdisp == 1){
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
  return 'x';
}



void vis_disp(int numberToShow, int disp){
  if (disp == 0){
    PORTL = B11111110;  // Enciende el primer display (unidades)
    PORTA = listanum[numberToShow];
  }else if(disp == 1){
    PORTL = B11111101;  // Enceiende el segundo display (decenas)
    PORTA = listanum[numberToShow];
  }  
}



void disminuir_udd(){ // Disminuye unidad
  N_udd--;
  if (N_udd < 0 && N_dcn > 0){
    N_dcn--;
    N_udd = 9;
  }else if (N_udd < 0){
    N_udd = 0;
    N_dcn = 0;
    fallo();
    parpadear();
    apagado();
  }
}

void limpieza(){
  Serial3.write(0xFE); Serial3.write(0x51);
  Serial3.write(0xFE); Serial3.write(0x46);
}







