//------------- HA V.0.5 - SESC TIJUCA (AGO/2015) -----------
//-------------- Sketch para Processing 2.2.1 ---------------
//------------- Câmera utilizada: Logitech C270 -------------

import gab.opencv.*;
import processing.serial.*;
import processing.video.*;
import java.awt.*;
import oscP5.*;
import netP5.*;

//Para rodar em fullscreen, clique em  "Sketch > Present"
//Ou pressione Ctrl + Shift + R (Windows)
//ou Cmd + Shift + R (Mac)

NetAddress oscVIZ;
NetAddress oscPD;
OscP5 myOsc;
Serial ha;

OpenCV opencv; 
Capture myCapture;

boolean isauto = false;

int myPort = 8500;
int otherPort = 8000;
String ipVIZ = "192.168.0.110";
String ipPD = "127.0.0.1";

String[] captureDevices;  
int threshold = 80; 
int midX;

PFont mono14;

// RESOLUTION
int res = 1;

// mask
PImage mask1;

int k = 0;

float sensorA = 0.0;
float sensorB = 0.0;

int mapx = 453;//364;
int mapy = 303;
float mapscale = 1.28;

void setup()  
{  
  size(1280, 800);  
  midX = width/2;  

  mask1 = loadImage("mask5.png");
  mono14 = loadFont("mono14.vlw");
  textAlign(CENTER);
  textFont(mono14, 14);

  myCapture = new Capture(this, width / res, height / res, "USB Camera");  

  opencv = new OpenCV(this, width/res, height/res);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  myOsc = new OscP5(this, myPort);
  oscVIZ = new NetAddress(ipVIZ, otherPort);
  oscPD = new NetAddress(ipPD, otherPort);

  //Verifique o número do indice da camera USB que aparece
  //no console e troque o número "5" em "Serial.list()[5]"
  //abaixo pelo número correspondente. Lembrando que 
  //como se trata de um array, a contagem começa em 0.
  ha = new Serial(this, Serial.list()[5], 9600);
  ha.bufferUntil('\n');

  myCapture.start();
}  

void keyPressed() {
  println(keyCode);
  switch(keyCode) {
  case 37:
    mapx--;
    break;
  case 39:
    mapx++;
    break;
  case 38:
    mapy--;
    break;
  case 40:
    mapy++;
    break;
  case 45:
  case 109:
    mapscale-=0.01;
    break;
  case 61:
  case 107:
    mapscale+=0.01;
    break;
  case 70:
    break;
  }
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

        //println("valores:\t" + va + "\t" + vb);

        float val1 = constrain(va, 40, 300);
        float val2 = constrain(vb, 50, 300);

        float val3 = constrain(va, 30, 300);
        float val4 = constrain(vb, 30, 300);

        println("constrains:\t" + val1 + "\t" + val2 + "\t" + val3 + "\t" + val4);

        val1 = map(val1, 300, 40, 0, 1000);
        val2 = map(val2, 300, 50, 0, 1000);

        val3 = map(val3, 300, 30, 0, 1000);
        val4 = map(val4, 300, 30, 0, 1000);

        sensorA += (val1-sensorA) * .25;
        sensorB += (val2-sensorB) * .25;

        println(val1 + "\t" + val2 + "\t" + val3 + "\t" + val4 );

        OscMessage aaa = new OscMessage("/a");
        OscMessage bbb = new OscMessage("/b");

        OscMessage ccc = new OscMessage("/c");
        OscMessage ddd = new OscMessage("/d");
        OscMessage eee = new OscMessage("/e");
        OscMessage fff = new OscMessage("/f");

        aaa.add(val1);
        bbb.add(val2);

        ccc.add(val1);
        ddd.add(val2);
        eee.add(val3);
        fff.add(val4);

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

  pushMatrix();

  //scale(4);

  int x = 0;
  int y = 0;
  int w = 0;
  int h = 0;
  int bigface = 0;

  //if (myCapture.available()) {

  if (true) {

    opencv.loadImage(myCapture);
    image(myCapture, 0, 0); 

    Rectangle[] faces1 = opencv.detect();// detect anything ressembling a FRONTALFACE

    noFill();

    stroke(255, 255, 255, 50);

    strokeWeight(4);

    //print("faces");
    //println(faces1.length);

    for ( int i = 0; i < faces1.length; i++ ) {  // draw rect around detected face area(s)

      rect( faces1[i].x, faces1[i].y, faces1[i].width, faces1[i].height);

      if ( w * h < faces1[i].width * faces1[i].height ) {
        w = faces1[i].width;
        h = faces1[i].height;
        bigface = i;
      }
    }
    if (faces1.length > 0) {

      float fx = faces1[bigface].x;
      float fy = faces1[bigface].y;
      float fw = faces1[bigface].width;
      float fh = faces1[bigface].height;

      rect( fx, fy, fw, fh);

      if (isauto) {
        ha.write("manual");
        ha.write(13);
        isauto = false;
      }

      int fradius = 100;

      if ( abs((width / 2) - (fx + fw / 2)) > fradius/2 ) {

        if ( fx + fw / 2 < width / 2) {
          ha.write("ss r");
        } else {
          ha.write("ss l");
        }
        ha.write(13);
      } else {
        // text("para",width/2,125);
      }

      if ( abs((height / 2) - (fy + fh / 2)) > fradius ) {

        if ( fy + fh / 2 > height / 2) {
          ha.write("ss t");
        } else {
          ha.write("ss b");
        }
        ha.write(13);
      }

      k = 0;
    } else {

      if (k > 50) {
        if ( !isauto ) {
          ha.write("auto");
          ha.write(13);
          isauto = true;
        }
      } else {
        k++;
        isauto = false;
      }
    }
  }

  popMatrix();

  if (mousePressed) {
    background(255);
    print("scale: ");
    print(mapscale);
    print(" x: ");
    print(mapx);
    print(" y: ");
    println(mapy);

    fill(0);
    text(mapscale+" "+mapx+" "+mapy, width/2, 100);
  }

  float iw = 1600*mapscale;
  float ih = 1200*mapscale;

  if (isauto) {
    fill(255);
    text("auto " + k, 100, 100);
  } else {
    fill(255);
    text("manual " + k, 100, 100);
  }

  image(mask1, mapx - iw * .5, mapy - ih * .5, iw, ih);
}  



public void stop() { 
  super.stop();
} 

void captureEvent(Capture c) {
  c.read();
}

