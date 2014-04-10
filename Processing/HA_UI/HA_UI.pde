import controlP5.*;
import processing.serial.*;
Serial arduinoSerial;

ControlP5 controlP5;
Slider2D s;
Slider in;
Slider out;
Toggle tmove;
Toggle tslide;

int b;
int n;

int x = 100;
int y = 100;

boolean l = false;
boolean t = false;

boolean autoslide = false;

int c = 0;
int r = 10;

void setup() {
  size(800,600);
  println(Serial.list());
  arduinoSerial = new Serial(this, Serial.list()[0], 9600);
  controlP5 = new ControlP5(this);
  s = controlP5.addSlider2D("wave",30,100,200,200);
  tmove = controlP5.addToggle("automove",false,30,30,20,20);
  tslide = controlP5.addToggle("autoslide",false,120,30,20,20);
  in = controlP5.addSlider("cyclein",500,10000,30,350,100,30);
  out = controlP5.addSlider("cycleout",500,10000,30,400,100,30);
  
  in.setValue(1000);
  in.setNumberOfTickMarks(10);
  
  out.setValue(2000);
  out.setNumberOfTickMarks(10);
  
  s.setArrayValue(new float[] {100, 100});  
  smooth();
  frameRate(5);
}

void automove(boolean value)
{
  if(value){
    arduinoSerial.write("auto");
    arduinoSerial.write(13);  
  }else{
    arduinoSerial.write("manual");
    arduinoSerial.write(13);
  }
  //println("motor 0 : "+value);
}

void cyclein(float value)
{
    arduinoSerial.write("in "+int(value));
    arduinoSerial.write(13);
}

void cycleout(float value)
{
    arduinoSerial.write("out "+int(value));
    arduinoSerial.write(13);
}

float cnt;

void draw() {
  
  background(0);
  pushMatrix();
  translate(260,200);
  strokeWeight(1);
  stroke(255,100);
  rect(0,-100, 200,200);
  line(0,0,200, 0);
  stroke(255);
  
  strokeWeight(2);
  
  for(int i=1;i<200;i++) {
    float y0 = cos(map(i-1,0,s.arrayValue()[0],-PI,PI)) * s.arrayValue()[1]; 
    float y1 = cos(map(i,0,s.arrayValue()[0],-PI,PI)) * s.arrayValue()[1];
    line((i-1),y0,i,y1);
  }
  
  popMatrix();
  
  int rand = int(random(100));
  
  if(c<r){
    c++;
  }else{
    
    if(rand < 25){
      println("invert l ");
      if(l){
        l = false;
      }else{
        l = true;
      }
    }else if(rand > 75){
      println("invert t");
      if(t){
        t = false;
      }else{
        t = true;
      }
    }
    
    c = 0;
    r = int(random(50));
    
    println(rand);
    
  }
  
  
  if(autoslide){
    if(l)
    {
      x-=3;
      if(x<0)
      {
        l = false;
      }
    }
    else {
      x+=4;
      if(x>200)
      {
        l = true;
      }
    }
    if(t)
    {
      y-=5;
      if(y<0)
      {
        t = false;
      }
    }
    else {
      y+=7;
      if(y>200)
      {
        t = true;
      }
    }
    s.setArrayValue(new float[] { x , y});
  }else{
    x = int(s.arrayValue()[0]);
    y = int(s.arrayValue()[1]);
  }
  
  //println(s.arrayValue());
  
  int base = int(map( s.arrayValue()[0], 0, 200, 150, 30));
  int neck = int(map( s.arrayValue()[1], 0, 200, 50, 130));
  
  if( b != base )
  {
    arduinoSerial.clear();
    arduinoSerial.write("s b "+Integer.toString(base));
    arduinoSerial.write(13);
    //arduinoSerial.write('A');
    delay(100);
    
    b = base;
    
    print("base ");
    println(b);
    
  }
  
  if( n != neck )
  {
    
    arduinoSerial.write("s s "+Integer.toString(neck));
    arduinoSerial.write(13);
    
    n = neck;
    
    print("neck ");
    println(n);
  
  }
}
