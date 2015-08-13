
/*  CONFIG
 ------------------------------------------------*/

// bibliotecas

#include <Servo.h>
 #include <SoftwareSerial.h>  
#include <SerialCommand.h>

// classes

Servo servo_base;
Servo servo_spine;
SerialCommand controller;

// pinos do arduino

int pinFO = 13;          // FIBRA OTICA
int pinFAN = 12;         // VENTILANDOR-FAN
int pinServoBase = 10;   // SERVO BASE
int pinServoSpine = 11;  // SERVO ESPINHA
int pinUSeLE = 3;          // ULTRASOUND ECHO~CINZA
int pinUStLE = 4;          // ULTRASOUND TRIGGER~AZUL
int pinUSeRI = 5;          // ULTRASOUND ECHO~CINZA
int pinUStRI = 6;          // ULTRASOUND TRIGGER~AZUL

int min_servo_s = 70;
int max_servo_s = 100;

int min_servo_b = 40;
int max_servo_b = 130;

// variaveis para stepper do servo

int base_next = 90;
int spine_next = 90;

int base_current = 0;
int spine_current = 0;

// variaveis da respiracao

unsigned long breath_in_millis = 0;
unsigned long breath_out_millis = 0;
unsigned int breath_in_cycle = 7000;
unsigned int breath_out_cycle = 7000;
boolean breath_state = true;

// fibra otica

unsigned long fiber_millis = 0;
unsigned int fiber_cycle = 50;
boolean fiberhigh = false;

// ciclo us

unsigned long us_millis = 0;
unsigned int us_cycle = 50;

unsigned long zoom_millis = 0;
unsigned int zoom_cycle = 4000;

unsigned long servo_millis = 0;
unsigned int servo_cycle = 1000;
boolean cancel_servo = false;

boolean AUTO = false;

boolean up = false;
boolean side = false;

const int numReadings = 2;
int usindex = 0;
int readingsLE[numReadings];
int readingsRI[numReadings];

int ustotalLE = 0;
int ussmoothLE = 0;
int ustotalRI = 0;
int ussmoothRI = 0;

int flash_next = 255;
int flash_current = 0;

/*  SETUP
 ------------------------------------------------*/


void setup()
{

  // definir pinos

  pinMode(pinFO, OUTPUT);
  pinMode(pinFAN, OUTPUT);

  pinMode(pinUStLE, OUTPUT);
  pinMode(pinUSeLE, INPUT);
  pinMode(pinUStRI, OUTPUT);
  pinMode(pinUSeRI, INPUT);

  servo_base.attach(pinServoBase);
  servo_spine.attach(pinServoSpine);

  // pegar valores iniciais dos servos (n sei se faz diferenca)

  base_current = servo_base.read();
  spine_current = servo_spine.read();

  // ligar Serial

  Serial.begin(9600);

  // criar comandos seriais

  controller.addCommand("auto", com_auto);
  controller.addCommand("manual", com_manual);
  controller.addCommand("in", com_cycle_in);
  controller.addCommand("out", com_cycle_out);
  controller.addCommand("s", com_servo);
  controller.addCommand("ss", com_servoss);
  controller.addDefaultHandler(com_unrecognized);  // Handler for command that isn't matched  (says "What?") 

  // Arduino pronto

  Serial.println("Ready");

}


/*  LOOP
 ------------------------------------------------*/


void loop()
{

  // verificar comandos seriais

  controller.readSerial();

  // stepper servo base

  if(cycleCheck(&servo_millis, servo_cycle))
  {
    cancel_servo = false;
  }


  // LIMITES

  if(base_next > max_servo_b){
    base_next = max_servo_b;
  }
  if(base_next < min_servo_b){
    base_next = min_servo_b;
  }
  if(spine_next > max_servo_s){
    spine_next = max_servo_s;
  }
  if(spine_next < min_servo_s){
    spine_next = min_servo_s;
  }

  // MOVIMENTO

  if(base_next != base_current )
  {
    if( base_next > base_current )
    {
      base_current+=2;
    }
    else if(base_next < base_current)
    {
      base_current-=2; 
    }
    servo_base.write(base_current);
  }

  // stepper servo spine

  if(spine_next != spine_current && ! cancel_servo)
  {
    if( spine_next > spine_current )
    {
      spine_current++;
    }
    else if(spine_next < spine_current)
    {
      spine_current--; 
    }
    servo_spine.write(spine_current);
  }

  // FIBER

  if(cycleCheck(&fiber_millis, fiber_cycle))
  {
    fiberhigh = !fiberhigh;

    if(fiberhigh){
      digitalWrite(pinFO, LOW);
    }
    else{
      digitalWrite(pinFO, HIGH);
    }
  }

  // BREATH IN

  if(cycleCheck(&breath_out_millis, breath_out_cycle) && !breath_state)
  {
    breath_state = true;
    digitalWrite(pinFAN, HIGH);
    breath_in_millis = millis();
  }

  // BREATH OUT

  if(cycleCheck(&breath_in_millis, breath_in_cycle) && breath_state)
  {
    breath_state = false;
    digitalWrite(pinFAN, LOW);
    breath_out_millis = millis();
  }
  
  //Abaixo seguem as instrucoes referentes aos sonares HC-SR04
  //Se desejar habilitar as funcionalidades dos mesmos,
  //DESCOMENTE o código abaixo, apenas adicionando "/"
  //no comeco do paragrafo seguinte:
  
  /* <-- comente aqui com /* no inicio da linha e descomente com //*
  
  // ULTRASOUND IF AUTOMODE

  int usLE;
  int usRI;

  // US

  usLE = ultrasoundOld(pinUSeLE,pinUStLE);
  usRI = ultrasoundOld(pinUSeRI,pinUStRI);

  readingsLE[usindex] = usLE;
  readingsRI[usindex] = usRI;

  ustotalLE = 0;
  ustotalRI = 0;

  for(int i = 0 ; i < numReadings ; i++) {
    ustotalLE = ustotalLE + readingsLE[i];
    ustotalRI = ustotalRI + readingsRI[i];
  }

  if(usindex >= numReadings)
  {
    usindex = 0;
  }
  else {
    usindex = usindex + 1;
  }

  ussmoothLE = ustotalLE / numReadings;
  ussmoothRI = ustotalRI / numReadings;

  Serial.print("#L:");
  Serial.print(ussmoothLE);
  Serial.print("\t");
  Serial.print("R:");
  Serial.println(ussmoothRI);

  // quando diminui left (nosso left em relacao ao HA) diminui a base ate 30; invertido

  // Behavior Logic
  if(usLE < 20 && usRI < 20 && ! cancel_servo){
    cancel_servo = true;
    int r;
    if(spine_next > min_servo_s){
      r = spine_next-10;
    }
    else{
      r = random(min_servo_s,max_servo_s);
    }
    spine_next = spine_current = r;
    servo_spine.write(r);

  }
  else if( ussmoothLE >= 20 && ussmoothLE <= 40 && ussmoothRI >= 20 && ussmoothRI <= 40  )
  {
    breath_in_cycle = 200000;
    breath_out_cycle = 500;
    fiber_cycle = 50;
  }
  else if( ussmoothLE > 40 && ussmoothLE < 150 && ussmoothRI > 40 && ussmoothRI < 150  )
  {

    fiber_cycle = 100;

    breath_in_cycle = 5000;
    breath_out_cycle = 2000;

    if(cycleCheck(&zoom_millis, zoom_cycle))
    {
      spine_next = random(30,50);
      //base_next = base_next+3-random(6);
    }

    if(ussmoothLE-ussmoothRI > 20 ||ussmoothLE-ussmoothRI < -20){ 

      if(ussmoothLE > ussmoothRI && base_next < 130){
        base_next = base_next+=4;
        side = true;
      }
      else if(ussmoothLE < ussmoothRI && base_next > 50){
        base_next = base_next-=4;
        side = false;
      }

    }

  }
  else{

    fiber_cycle = 400;

    breath_in_cycle = 3000;
    breath_out_cycle = 4000;
  }

  //*/

  if(AUTO){

    if( up )
    {
      if( spine_next > min_servo_s )
      {
        spine_next-=1;
      }
      else{
        up = false;
      }
    }
    else
    {
      if( spine_next < max_servo_s )
      {
        spine_next+=1;
      }
      else{
        up = true;
      }
    }

    if( side )
    {
      if( base_next > min_servo_b )
      {
        base_next-=1;
      }
      else{
        side = false;
      }
    }
    else
    {
      if( base_next < max_servo_b )
      {
        base_next+=1;
      }
      else{
        side = true;
      }
    }

    int r = random(95);
    if( r > 90 ){
      up = !up;
    }

    r = random(95);
    if( r > 90 ){
      side = !side;
    }


  }

  // bom delay pro arduino e pros servos

  delay(30);

}


/*  METODOS
 ------------------------------------------------*/

int ultrasoundOld(int echoPin, int triggerPin)
{
  digitalWrite(triggerPin, LOW);
  delayMicroseconds(2);
  digitalWrite(triggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(triggerPin, LOW);
  return pulseIn(echoPin, HIGH)/58;
}

int ultrasound(int pin)
{
  pinMode(pin, OUTPUT); //pin is output
  digitalWrite(pin, LOW);
  delayMicroseconds(2);
  digitalWrite(pin, HIGH);
  delayMicroseconds(10);
  digitalWrite(pin, LOW);
  pinMode(pin, INPUT); // pin is now input
  // wait for a high pulse
  return pulseIn(pin, HIGH)/58; //divide with 148 and you get inches
}


// serialcommand s = servo
// comandos podem ser s = spine e b = base

void com_servo()
{

  char *arg;
  String name;
  int val;

  arg = controller.next(); // pegar proximo argumento
  if (arg != NULL)
  {
    name = arg; // nome do servo
  }

  arg = controller.next(); // pegar proximo argumento
  if (arg != NULL && !AUTO)
  {
    int val = atoi(arg); // converter char em inteiro

    Serial.print("Servo "+name+" to "); 

    Serial.println(val);

    if(val < 0 || val > 179)
    {
      Serial.println("ERROR: Servo values must be 0 to 179"); 
    }
    else
    {
      if(name == "s") // s = spine
      {
        Serial.println("Move spine!");
        spine_next = val;
      }
      else if(name == "b") // b = base
      {
        Serial.println("Move base!");
        base_next = val;
      }
    }
  } 
}

void com_servoss()
{

  char *arg;
  String name;
  int val;

  Serial.println("OpenCV");

  arg = controller.next(); // pegar proximo argumento
  if (arg != NULL)
  {

    name = arg; // nome do servo

    int vel = 4;

    if(name == "t") // s = spine
    {
      Serial.println("UP");
      spine_next += vel;
    }
    else if(name == "b") // b = base
    {
      Serial.println("DOWN");
      spine_next -= vel;
    }
    else if(name == "l") // b = base
    {
      Serial.println("LEFT");
      base_next += vel;
    }
    else if(name == "r") // b = base
    {
      Serial.println("RIGHT");
      base_next -= vel;
    }
  }
}

// serialcommand in = inspiracao

void com_cycle_in()
{
  char *arg;
  arg = controller.next(); // pegar proximo argumento
  if (arg != NULL)
  {
    breath_in_cycle = atoi(arg); // novo ciclo
  }
}

// serialcommand out = expiracao

void com_cycle_out()
{
  char *arg;
  arg = controller.next(); // pegar proximo argumento
  if (arg != NULL)
  {
    breath_out_cycle = atoi(arg); // novo ciclo
  }
}

// auto mode

void com_auto()
{
  AUTO = true;
  Serial.println("auto mode"); 
}

void com_manual()
{
  AUTO = false;
  Serial.println("manual mode");
}

// serialcommand default

void com_unrecognized()
{
  Serial.println("What?"); 
}

// metodo para verificar se um ciclo terminou

boolean cycleCheck(unsigned long *lastMillis, unsigned int cycle)
{
  unsigned long currentMillis = millis();
  if(currentMillis - *lastMillis >= cycle)
  {
    //Serial.println(currentMillis - *lastMillis);
    *lastMillis = currentMillis;
    return true;
  }
  else
    return false;
}



