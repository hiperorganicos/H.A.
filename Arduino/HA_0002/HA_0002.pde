
/*  CONFIG
------------------------------------------------*/

// bibliotecas

#include <Servo.h>
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
int pinUSe = 3;          // ULTRASOUND ECHO~CINZA
int pinUSt = 4;          // ULTRASOUND TRIGGER~AZUL


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
unsigned int fiber_cycle = 500;
boolean fiberhigh = false;

// ciclo us

unsigned long us_millis = 0;
unsigned int us_cycle = 50;

unsigned long zoom_millis = 0;
unsigned int zoom_cycle = 4000;

boolean AUTO = true;

boolean up = false;
boolean side = false;

const int numReadings = 10;
int readings[numReadings];
int ustotal = 0;
int ussmooth = 0;
int usindex = 0;


/*  SETUP
------------------------------------------------*/


void setup()
{
  
  // definir pinos
  
  pinMode(pinFO, OUTPUT);
  pinMode(pinFAN, OUTPUT);
  
  pinMode(pinUSt, OUTPUT);
  pinMode(pinUSe, INPUT);
  
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
  
  if(base_next != base_current)
  {
    if( base_next > base_current )
    {
      base_current++;
    }
    else if(base_next < base_current)
    {
     base_current--; 
    }
    servo_base.write(base_current);
  }
  
  // stepper servo spine
  
  if(spine_next != spine_current)
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
    }else{
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
  
  // ULTRASOUND IF AUTOMODE
  
  if(AUTO)
  {
    if(cycleCheck(&us_millis, us_cycle))
    {
      
      int us;
      
      // US
      
      us = ultrasoundOld(pinUSe,pinUSt);
      readings[usindex] = us;
      
      ustotal = 0;
      
      for(int i = 0 ; i < numReadings ; i++) {
        ustotal = ustotal + readings[i];
      }
      
      if(usindex >= numReadings)
      {
        usindex = 0;
      }
      else {
        usindex = usindex + 1;
      }
      
      ussmooth = ustotal / numReadings;
      
      Serial.print("ultrasound: ");
      Serial.println(ussmooth);
      
      //Serial.print("spine: ");
      //Serial.println(spine_next);
      
      
      // Behavior Logic
      
      if( ussmooth > 60 && ussmooth < 150 )
      {
        
        if(cycleCheck(&zoom_millis, zoom_cycle))
        {
          spine_next = random(30,50);
          base_next = base_next+3-random(6);
        }
        
      }else{
         
       if( up )
        {
           if( spine_next > 30 )
           {
            spine_next-=2;
           }else{
             up = false;
           }
        }
        else
        {
          if( spine_next < 80 )
          {
            spine_next+=2;
          }else{
            up = true;
          }
        }
        
        if( side )
        {
           if( base_next > 40 )
           {
            base_next-=1;
           }else{
             side = false;
           }
        }
        else
        {
          if( base_next < 130 )
          {
            base_next+=1;
          }else{
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
    
    }
  }
  
  // bom delay pro arduino e pros servos
  
  delay(15);
  
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
