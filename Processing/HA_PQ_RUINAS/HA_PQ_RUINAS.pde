import processing.video.*;  
import hypermedia.video.*; 
import java.awt.Rectangle;
import processing.serial.*;
import oscP5.*;
import netP5.*;

NetAddress oscVIZ;
NetAddress oscPD;
OscP5 myOsc;
Serial ha;

OpenCV ocv1; 
OpenCV ocv2; 
Capture myCapture;  
Capture myCapture2;

boolean isauto = false;

int myPort = 8500;
int otherPort = 8000;
String ipVIZ = "192.168.1.10";
String ipPD = "127.0.0.1";

String[] captureDevices;  
int threshold = 80; 
int midX;

int k = 0;

float sensorA = 0.0;
float sensorB = 0.0;

PImage nano;

void setup()  
{  
  size(1280, 800);  
  midX = width/2;  // place to start drawing image from second cam
  println (Capture.list());  
  captureDevices = Capture.list();  

  nano = loadImage("nano.png");

  myCapture = new Capture(this, width, height, "Sony HD Eye for PS3 (SLEH 00201)", 1000);  
  //myCapture2 = new Capture(this, 320, height, "Sony HD Eye for PS3 (SLEH 00201)", 1000);  
  ocv1 = new OpenCV(this);
  ocv1.allocate(width/4, height/4);
  ocv1.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );
  
  myOsc = new OscP5(this, myPort);
  oscVIZ = new NetAddress(ipVIZ, otherPort);
  oscPD = new NetAddress(ipPD, otherPort);
  
  ha = new Serial(this, Serial.list()[0], 9600);
  ha.bufferUntil('\n');
}  

void serialEvent(Serial ha) {

  String inString = ha.readStringUntil('\n');
  println(inString);
  //////////////////////

  if (inString != null) {

    if ('#' == inString.charAt(0)) {
      
      String[] allvalues = split(inString, '\t');
      
      if (allvalues.length == 2) {
        
        String[] aa = split(allvalues[0], ":");
        String[] bb = split(allvalues[1], ":");
        
        println(aa[1]+"\t"+bb[1]);
        
        int va = int(trim(aa[1]));
        int vb = int(trim(bb[1]));
        int vc = int(trim(aa[1]));
        int vd = int(trim(bb[1]));
        int ve = int(trim(aa[1]));
        int vf = int(trim(bb[1]));
        
        println(va + "\t" + vb + "\t" + vc + "\t" + vd + "\t" + ve + "\t" + vf);
        
        float val1 = constrain(va,40, 160);
        float val2 = constrain(vb,50, 150);
        
        float val3 = constrain(vc,30, 300);
        float val4 = constrain(vd,30, 200);
        
        float val5 = constrain(ve,40, 160);
        float val6 = constrain(vf,50, 150);
        
        val1 = map(val1, 160, 40, 0.0, 1.0);
        val2 = map(val2, 150, 50, 0.0, 1.0);
        
        val3 = map(val3, 300, 30, 40.0, 100.0);
        val4 = map(val4, 200, 30, 40.0, 100.0);
        
        val5 = map(val5, 160, 40, 40.0, 100.0); 
        val6 = map(val6, 150, 50, 40.0, 100.0);
        
        sensorA += (val1-sensorA) * .25;
        sensorB += (val2-sensorB) * .25;
        
       // println(val1 + "\t" + val2 + "\t" + val3 + "\t" + val4 + "\t" + val5 + "\t" + val6);
        
        OscMessage aaa = new OscMessage("/a");
        OscMessage bbb = new OscMessage("/b");
        
        OscMessage ccc = new OscMessage("/c");
        OscMessage ddd = new OscMessage("/d");
        OscMessage eee = new OscMessage("/e");
        OscMessage fff = new OscMessage("/f");
        
        aaa.add(sensorA);
        bbb.add(sensorB);
        
        ccc.add(val3);
        ddd.add(val4);
        eee.add(val5);
        fff.add(val6);
        
        myOsc.send(aaa, oscVIZ);
        myOsc.send(bbb, oscVIZ);
        
        myOsc.send(ccc, oscPD);
        myOsc.send(ddd, oscPD);
        myOsc.send(eee, oscPD);
        myOsc.send(fff, oscPD);
      }
    }
  }
}


void draw() {

  int x = 0;
  int y = 0;
  int w = 0;
  int h = 0;
  int bigface = 0;

  if (myCapture.available()) { 

    image(myCapture, 0, 0); 

    myCapture.read();  

    ocv1.copy(myCapture, 0, 0, width, height, 0, 0, width/4, height/4);  // copy to OpenCV buffer

    //image(ocv1.image(), 0, 0); // display to screen

    Rectangle[] faces1 = ocv1.detect();// detect anything ressembling a FRONTALFACE

    noFill();

    stroke(255, 255, 255, 50);

    strokeWeight(4);

    for ( int i = 0; i < faces1.length; i++ ) {  // draw rect around detected face area(s)

      rect( faces1[i].x * 4, faces1[i].y * 4, faces1[i].width * 4, faces1[i].height * 4);

      if ( w * h < faces1[i].width * faces1[i].height ) {
        w = faces1[i].width;
        h = faces1[i].height;
        bigface = i;
      }
    }
    if (faces1.length > 0) {

      float fx = faces1[bigface].x * 4;
      float fy = faces1[bigface].y * 4;
      float fw = faces1[bigface].width * 4;
      float fh = faces1[bigface].height * 4;

      rect( fx, fy, fw, fh);

      ha.write("manual");
      ha.write(13);

      int fradius = 100;

      if ( abs((width / 2) - (fx + fw / 2)) > fradius ) {

        if ( fx + fw / 2 < width / 2) {
          ha.write("ss r");
        }
        else {
          ha.write("ss l");
        }
        ha.write(13);
      }

      if ( abs((height / 2) - (fy + fh / 2)) > fradius ) {

        if ( fy + fh / 2 > height / 2) {
          ha.write("ss t");
        }
        else {
          ha.write("ss b");
        }
        ha.write(13);
      }

      k = 0;
    }
    else {
      
      if (k > 5) {
        if( !isauto ){
          ha.write("auto");
          ha.write(13);
          isauto = true;
        }
      }else{
        k++;
        isauto = false;
      }
    }
  }

  //image(nano, 400, 0);
}  



public void stop() { 
  ocv1.stop(); 
  ocv2.stop(); 
  super.stop();
} 

