
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
int pinUSL = 3;          // ULTRASOUND LEFT
int pinUSR = 7;          // ULTRASOUND RIGHT


// variaveis para stepper do servo

int base_next = 90;
int spine_next = 90;

int base_current = 0;
int spine_current = 0;

// variaveis da respiracao

unsigned long breath_in_millis = 0;
unsigned long breath_out_millis = 0;
unsigned int breath_in_cycle = 1000;
unsigned int breath_out_cycle = 2000;
boolean breath_state = true;

// ciclo us

unsigned long us_millis = 0;
unsigned int us_cycle = 50;

boolean AUTO = false;


/*  SETUP
------------------------------------------------*/


void setup()
{
  
  // definir pinos
  
  pinMode(pinFO, OUTPUT);
  pinMode(pinFAN, OUTPUT);
  
  servo_base.attach(pinServoBase);
  servo_spine.attach(pinServoSpine);
  
  // primeiro HIGH/LOW para sincronizar FO com FAN
  
  digitalWrite(pinFO,LOW);
  digitalWrite(pinFO,HIGH);
 
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
  
  // BREATH IN
  
  if(cycleCheck(&breath_out_millis, breath_out_cycle) && !breath_state)
  {
    breath_state = true;
    digitalWrite(pinFO, HIGH);
    delay(5);
    digitalWrite(pinFO, LOW);
    digitalWrite(pinFAN, HIGH);
    breath_in_millis = millis();
  }
  
  // BREATH OUT
  
  if(cycleCheck(&breath_in_millis, breath_in_cycle) && breath_state)
  {
    breath_state = false;
    digitalWrite(pinFO, HIGH);
    delay(5);
    digitalWrite(pinFO, LOW);
    digitalWrite(pinFAN, LOW);
    breath_out_millis = millis();
  }
  
  // ULTRASOUND IF AUTOMODE
  
  if(AUTO)
  {
    if(cycleCheck(&us_millis, us_cycle))
    {
      
      int usl;
      int usr;
      
      // US1
      
      usl = ultrasound(pinUSL);
      
      // US2
      
      usr = ultrasound(pinUSR);
      
      // Behavior Logic
      
      if( abs(usl-usr) > 5 )
      {
        
        if( usl > usr )
        {
           if( base_next > 30 )
           {
            base_next--;
           }
        }
        else if( usr > usl )
        {
          if( base_next < 150 )
          {
            base_next++;
          }
        }
      
      }
    
    }
  }
  
  // bom delay pro arduino e pros servos
  
  delay(15);
  
}


/*  METODOS
------------------------------------------------*/

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
