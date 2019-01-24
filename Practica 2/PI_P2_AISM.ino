/**
 * Autora: Ana Isabel Santana Medina
 * Fecha: 15/04/18
*/

/**
 * Variables y constantes
*/

const int LEE_SDA = 3;  // Lectura de la linea SDA
const int ESC_SDA = 5;  // Escritura de la linea SDA

const int LEE_SCL = 2;  // Lectura de la linea SCL
const int ESC_SCL = 4;  // Escritura de la linea SCL

const String text[] = {
    "\n\tNumero introducido no valido, fuera de rango.\n",                /** [0] */
    "\n\tIntroduzca una opcion (0 - 11): ",                               /** [1] */
    "\n\tIntroduzca el valor del dato (0 - 255): ",                       /** [2] */
    "\n\tIntroduzca la posicion (0 - 127): ",                             /** [3] */
    "\n\tMemoria[",                                                       /** [4] */
    "] = ",                                                               /** [5] */
    "\n\tIntroduzca un valor para inicializar la diagonal (0 - 255): ",   /** [6] */
    "\n\tSuma de la diagonal: ",                                          /** [7] */
    "\n\tResta de la diagonal: "                                          /** [8] */
};

const String menu[] = {
    "Funciones principales: \n\n",                                                   /** 0[1] */
    "  1.- Guardar un valor (de 0 a 255) en una posicion del M24C01\n",              /** 1[2] */
    "  2.- Leer una posicion (de 0 a 127) del M24C01\n",                             /** 2[3] */
    "  3.- Inicializar toda la memoria del M24C01 a un valor\n",                     /** 3[4] */
    "  4.- Mostrar el contenido de los 128 bytes del M24C01\n\n",                    /** 4[5] */
    "Funciones adicionales de la diagonal: \n",                                      /** 5[6] */
    "\n  5.- Inicializar, sumar y mostrar la diagonal\n",                            /** 6[7] */
    "  6.- Inicializar, restar y mostrar la diagonal\n\n",                           /** 7[8] */
    "Funciones adicionales (sucesiones): \n",                                        /** 8[9] */
    "\n  7.- Sucesion de Fibonacci\n",                                               /** 9[10] */
    "  8.- Inicializar toda la memoria a cero\n",                                   /** 10[11] */
    "  9.- Inicializar la memoria de forma ascendente\n",                           /** 11[12] */
    "  10.- Inicializar la memoria de forma descendente",                           /** 12[13] */
};

/**
 * Configuración
*/

void setup() {

  // Monitor Serie
  Serial.begin(9600);
  
  // Terminales de entrada
  pinMode(LEE_SDA, INPUT);
  pinMode(LEE_SCL, INPUT);
  
  // Terminales de salida
  pinMode(ESC_SDA, OUTPUT);
  pinMode(ESC_SCL, OUTPUT);
  
  // Prevención de intervencón en SDA y SCL a '1'
  digitalWrite(ESC_SDA, HIGH);
  digitalWrite(ESC_SCL, HIGH);

  //Mensaje bienvenida
  Serial.println("______   _____  ________  ____  _____  ____   ____  ________  ____  _____  _____  ______      ___    ");
  Serial.println("|_   _ \\ |_   _||_   __  ||_   \\|_   _||_  _| |_  _||_   __  ||_   \\|_   _||_   _||_   _ `.  .'   `.  ");
  Serial.println(" | |_) |  | |    | |_ \\_|  |   \\ | |    \\ \\   / /    | |_ \\_|  |   \\ | |    | |    | | `. \\/  .-.  \\ ");
  Serial.println(" |  __'.  | |    |  _| _   | |\\ \\| |     \\ \\ / /     |  _| _   | |\\ \\| |    | |    | |  | || |   | | ");
  Serial.println("_| |__) |_| |_  _| |__/ | _| |_\\   |_     \\ ' /     _| |__/ | _| |_\\   |_  _| |_  _| |_.' /\\  `-'  / ");
  Serial.println("|______/|_____||________||_____|\\____|     \\_/     |________||_____|\\____||_____||______.'  `.___.'  \n");
}

/**
 * Interfaz
*/

void loop() {
  
  Serial.println();
  showMenu();
  int option = askForValue(1);
  realizarTarea(option);
}

/**
 * Función para mostrar el menú
*/
void showMenu() {
  
  Serial.println("*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n");
  for (int i = 0; i <= 12; i++) {
    Serial.println(menu[i]);
  }
  Serial.println("\n*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n");
}

/**
 * Selector de opción
*/

void realizarTarea(int option) {
  switch (option) {
    case 0:
      iniciarMemCero();
      break;
    case 1:
      writeMemPos();
      break;
    case 2:
      byte info[2];
      readMemPos(info);
      Serial.print(text[4]);
      Serial.print(info[0]);
      Serial.print(text[5]);
      Serial.println(info[1]);
      break;
    case 3:
      writeMem();
      break;
    case 4:
      Serial.println();
      readMem();
      break;
    case 5:
      sumDiagonal();
      break;
    case 6:
      subtractionDiagonal();
      break;
    case 7:
      fibonacci();
      break;
    case 8:
      iniciarMemCero();
      break;
    case 9:
      ascending();
      break;
    case 10:
      descending();
      break;
    default:
      Serial.println(text[0]);
      break;
  }
}

/**
 * 1.- Guardar un dato (de 0 a 255) en cualquier dirección de memoria del dispositivo M24C01
*/

void writeMemPos() {
  int dato = askForValue(2);
  while (dato < 0 || dato > 255) {
     Serial.println(text[0]);
     dato = askForValue(2);
  }
  int dir = askForValue(3);
  while (dir < 0 || dir > 127) {
     Serial.println(text[0]);
     dir = askForValue(3);
  }
  byteWrite(dir, dato);
}

/**
 * 2.- Leer una posición (de 0 a 127) del M24C01
*/

void readMemPos(byte info[]) {
  info[0] = askForValue(3);
  while (info[0] < 0 || info[0] > 127) {
     Serial.println(text[0]);
     info[0] = askForValue(3);
  }
  byteRead(info);
}

/**
 * 3.- Inicializar toda la memoria del M24C01 a un valor
*/

void writeMem() {
  int dato = askForValue(2);
  while (dato < 0 || dato > 255) {
     Serial.println(text[0]);
     dato = askForValue(2);
  }
  for (int i = 0; i <= 127; i++) {
    byteWrite(i, dato);
  }
}

/**
 * 4.- Mostrar el contenido de los 128 bytes del M24C01
*/

void readMem () {
  byte info[2];
  int count = 0;
  int fila = 0;
  int aux = 0;

  for(int col = 0; col <= 8; col++){
    if(col == 0){
      Serial.print("\t");
    }else{
      Serial.print(col-1);
      Serial.print("\t");
    }
    if(col == 8){
      Serial.println("");
    }
  }

  for (info[0] = 0; info[0] <= 127; info[0]++) {
    byteRead(info);
    if(count == 7){
      count = 0;
      Serial.println(info[1]);
      aux++;
    }else{
      // IMPRIMIR NÚMERO FILA
      if(aux == fila){
        Serial.print(fila);
        Serial.print("\t");
        fila += 8;
      }
      aux++;
      Serial.print(info[1]);
      Serial.print("\t");
      count++;
    }
  }
}

/**
 * 5.- Escribir diagonal a un valor y hacer la suma
*/

void sumDiagonal(){
  // Pedimos dato para inicializar
  int dato = askForValue(6);
  while (dato < 0 || dato > 255) {
     Serial.println(text[0]);
     dato = askForValue(6);
  }
  // Rellenamos la diagonal
  Serial.println();
  int num = 0;
  for (int i = 0; i <= 127; i++) {
    if(i == num){
      byteWrite(i, dato);
      num += 9;   
    }
  }
  
  // Imprimir la diagonal
  byte info[2];
  int count = 0;
  int fila = 0;
  int aux = 0;
  int num2 = 0;
  int suma = 0;

  for(int col = 0; col <= 8; col++){
    if(col == 0){
      Serial.print("\t");
    }else{
      Serial.print(col-1);
      Serial.print("\t");
    }
    if(col == 8){
      Serial.println("");
    }
  }

  for (info[0] = 0; info[0] <= 63; info[0]++) {
    byteRead(info);
    if(count == 7){
      count = 0;
      Serial.println(info[1]);
      aux++;
    }else{
      
      if(aux == fila){
        Serial.print(fila);
        Serial.print("\t");
        fila += 8;
      }
      aux++;
      Serial.print(info[1]);
      Serial.print("\t");
      count++;
    }
    if(info[0] == num2){
      suma += info[1];
      num2 += 9;   
    }
  }
  // Imprimimos la suma
  Serial.print("\t");
  Serial.print(text[7]);
  Serial.print(suma);
}

/**
 * 6.- Escribir diagonal a un valor y hacer la resta
*/

void subtractionDiagonal(){
  // Pedimos dato para inicializar
  int dato = askForValue(6);
  while (dato < 0 || dato > 255) {
     Serial.println(text[0]);
     dato = askForValue(6);
  }
  // Rellenamos la diagonal
  Serial.println();
  int num = 0;
  for (int i = 0; i <= 127; i++) {
    if(i == num){
      byteWrite(i, dato);
      num += 9;
    }
  }

  // Imprimir la diagonal
  byte info[2];
  int count = 0;
  int fila = 0;
  int aux = 0;
  int num2 = 0;
  int resta = 0;

  for(int col = 0; col <= 8; col++){
    if(col == 0){
      Serial.print("\t");
    }else{
      Serial.print(col-1);
      Serial.print("\t");
    }
    if(col == 8){
      Serial.println("");
    }
  }

  for (info[0] = 0; info[0] <= 63; info[0]++) {
    byteRead(info);
    if(count == 7){
      count = 0;
      Serial.println(info[1]);
      aux++;
    }else{
      // IMPRIMIR NÚMERO FILA
      if(aux == fila){
        Serial.print(fila);
        Serial.print("\t");
        fila += 8;
      }
      aux++;
      Serial.print(info[1]);
      Serial.print("\t");
      count++;
    }
    if(info[0] == num2){
      resta -= info[1];
      num2 += 9;
    }
  }

  if(resta <= -255){
    Serial.println("\n\tLa resta no podra efectuarse porque se sale de rango");
  }else{
    // Imprimimos la resta
    Serial.print("\t");
    Serial.print(text[8]);
    Serial.print(resta);
  }
}


/**
 * 7.- Sucesión de Fibonacci
*/

void fibonacci(){
  int num1 = 0;
  int suma = 1;
  int temp;

  for (int i = 0; i <= 13; i++) {
    switch (i) {
    case 0:
      byteWrite(i, num1);
      break;
    case 1:
      byteWrite(i, suma);
      break;
    }
    if(i != 0 && i != 1){
      temp = num1;
      num1 = suma;
      suma = temp + num1;
      byteWrite(i, suma);
    }
  }

  // Imprimir la sucesión
  Serial.println();
  byte info[2];
  int count = 0;
  int fila = 0;
  int aux = 0;
  int num2 = 0;

  for(int col = 0; col <= 8; col++){
    if(col == 0){
      Serial.print("\t");
    }else{
      Serial.print(col-1);
      Serial.print("\t");
    }
    if(col == 8){
      Serial.println("");
    }
  }

  for (info[0] = 0; info[0] <= 13; info[0]++) {
    byteRead(info);
    if(count == 7){
      count = 0;
      Serial.println(info[1]);
      aux++;
    }else{
      if(aux == fila){
        Serial.print(fila);
        Serial.print("\t");
        fila += 8;
      }
      aux++;
      Serial.print(info[1]);
      Serial.print("\t");
      count++;
    }
  }
}

/**
 * 8.- Iniciar toda la memoria a 0
 */

 void iniciarMemCero() {
  int dato = 0;
  for (int i = 0; i <= 127; i++) {
    byteWrite(i, dato);
  }
  Serial.println();
  readMem();
}

/**
 * 9.- Ordenar memoria de forma ascendente
 */
 
void ascending(){
  int dato = 0;
  for (int i = 0; i <= 127; i++){
    byteWrite(i, dato);
    dato++;
  }
  Serial.println();
  readMem();
}

/**
 * 10.- Ordenar memoria de forma descendente
 */

void descending(){
  int dato = 128;
  for (int i = 0; i <= 127; i++){
    dato--;
    byteWrite(i, dato);
  }
  Serial.println();
  readMem();
}


/**
 *
 * Funciones auxiliares
 * 
*/

/**
 * Función para leer desde memoria
*/

byte byteRead(byte info[]) {
  while (true) {
    STOP();
    while (START());
    // Selecciono dispositivo
    for(int i = 6; i >= 0; i--) {
      E_BIT(bitRead(80, i));
    }
    E_BIT(0); // Escritura
    if (R_BIT() == 1) { // ACK
      continue;
    }
    // Selecciono dirección
    for (int i = 7; i >= 0; i--) {
      E_BIT(bitRead(info[0], i));
    }
    if (R_BIT() == 1) { // ACK
      continue;
    }
    while (START());
    // Selecciono dispositivo
    for(int i = 6; i >= 0; i--){
      E_BIT(bitRead(80, i));
    }
    E_BIT(1); // Lectura
    if (R_BIT() == 1) { // ACK
      continue;
    }
    // Leo el dato recibido
    for (int i = 7; i >= 0; i--){
      bitWrite(info[1], i, R_BIT());
    }
    STOP();
    break;
  }
  return info[1];
}

/**
 * Función para escribir en memoria
*/

void byteWrite(int dir, int dato) {
  while (true) {
    STOP();
    while (START());
    // Selecciono dispositivo
    for(int i = 6; i >= 0; i--){
      E_BIT(bitRead(80, i));
    }
    E_BIT(0); // Escritura
    if (R_BIT() == 1) { // ACK
      continue;
    }
    // Selecciono dirección
    for (int i = 7; i >= 0; i--) {
      E_BIT(bitRead(dir, i));
    }
    if (R_BIT() == 1) { // ACK
      continue;
    }
    // Envío dato
    for (int i = 7; i >= 0; i--) {
      E_BIT(bitRead(dato, i));
    }
    if (R_BIT() == 1) { // ACK
      continue;
    }
    STOP();
    break;
  }
}

/**
 * Función para pedir un valor por teclado
*/

int askForValue(int option) {
  Serial.print(text[option]);
  int valor = -1;
  while (Serial.available() == 0);
  valor = Serial.parseInt();
  Serial.println(valor);
  return valor;
}

/**
 *
 * Funciones de protocolo del bus
 *
*/

boolean START () {
  // Pulso 1
  digitalWrite(ESC_SDA, HIGH);
  digitalWrite(ESC_SCL, HIGH);
  // Pulso 2
  if (digitalRead(LEE_SDA) == LOW) {
    return true; // Bus no disponible
  }
  if (digitalRead(LEE_SCL) == LOW) {
    return true; // Bus no disponible
  }
  // Pulso 3
  digitalWrite(ESC_SDA, LOW);
  digitalWrite(ESC_SCL, HIGH);
  // Pulso 4
  digitalWrite(ESC_SDA, LOW);
  digitalWrite(ESC_SCL, LOW);
  return false; // Bus disponible
}

void STOP () {
  // Pulso 1
  digitalWrite(ESC_SDA, LOW);
  digitalWrite(ESC_SCL, LOW);
  // Pulso 2
  digitalWrite(ESC_SDA, LOW);
  digitalWrite(ESC_SCL, HIGH);
  // Pulso 3
  digitalWrite(ESC_SDA, HIGH);
  digitalWrite(ESC_SCL, HIGH);
  // Pulso 4
  digitalWrite(ESC_SDA, HIGH);
  digitalWrite(ESC_SCL, HIGH);
}

void E_BIT(boolean bitData) {
  // Pulso 1
  digitalWrite(ESC_SDA, bitData);
  digitalWrite(ESC_SCL, LOW);
  // Pulso 2
  digitalWrite(ESC_SDA, bitData);
  digitalWrite(ESC_SCL, HIGH);
  // Pulso 3
  digitalWrite(ESC_SDA, bitData);
  digitalWrite(ESC_SCL, HIGH);
  // Pulso 4
  digitalWrite(ESC_SDA, bitData);
  digitalWrite(ESC_SCL, LOW);
}

boolean R_BIT () {
  // Pulso 1
  digitalWrite(ESC_SDA, HIGH);
  digitalWrite(ESC_SCL, LOW);
  // Pulso 2
  digitalWrite(ESC_SDA, HIGH);
  digitalWrite(ESC_SCL, HIGH);
  // Pulso 3
  while (digitalRead(LEE_SCL) == LOW) {
    digitalWrite(ESC_SCL, HIGH);
  }
  boolean sda = digitalRead(LEE_SDA);
  // Pulso 4
  digitalWrite(ESC_SDA, HIGH);
  digitalWrite(ESC_SCL, LOW);
  return sda; //Bit leído
}
