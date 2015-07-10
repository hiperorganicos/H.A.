/* ---------------------------------------------------------------------------------------------
 * Ecologias Hiperorgânicas
 * ---------------------------------------------------------------------------------------------
 * prog:  Barbara Castro / Multimedia artist and designer / EBA/UFRJ / IMPA
 * www.barbaracastro.com.br    !      www.ctrlbarbara.wordpress.com
 * date:  24/02/2012 (m/d/y)   Evento: Vivo ARTE MOV - Parque das ruinas
 * ---------------------------------------------------------------------------------------------
 * Visualização de partículas desenvolvida para projeção interna na barriga do HA.
 * Mais informações em: http://www.nano.eba.ufrj.br 
 */

//update: retirei em 2015 a library fullscreen que não teve mais atualizações pro Processing, favor usar "Present"


import oscP5.*;
import netP5.*;

boolean slider = true; //<----- Mude para 'false' para utilizar dados com o robô 


OscP5 myOsc;
int myPort = 8000;

float sensor_01 = 0;
float sensor_02 = 0;
float campo = 0;

int maxCnt;
particle p[];
slider s[]; 

color[]      pColors = {
  color(0, 255, 0)
};// color(7,247,245), color(7,247,189), color(203,247,7), color(7,137,247), color(7,247,121), color(255, 255, 255)}; uncomment to get the original set of colors

void setup() {
  size(1280, 720);
  background(0);
  smooth();
  textSize(11);
  colorMode(RGB, 255, 255, 255, 100);
  frameRate(24);

  myOsc = new OscP5(this, myPort);

  //setup particles
  maxCnt = 4000;
  p = new particle[maxCnt];
  for (int i=0; i<maxCnt; i++)
    p[i] = new particle();
  
  if (slider) {
    s = new slider[5];
    s[0] = new slider(10, 30, 150, 10, "Aproximação", .5);
  }
}

void draw() {
  noStroke();
  fill(0, 0, 0, 20);
  rect(0, 0, width, height);

  float prox_desloc_x, prox_desloc_y;
  float prox_campo, prox_tam;

  pushMatrix(); 
  translate(width/2, height/2);

  if (slider == false)
  {
    prox_campo = map(sensor_01, 0, 0.8, height, height/6);  
    prox_desloc_x = map(sensor_01, 0, 1, .5, 6);
    prox_desloc_y = map(sensor_01, 0, 1, 4, 0.5); 
    prox_tam = map(sensor_01, 0, 1, 4, 10); 

    for (int i=0; i<200+(sensor_02*800); i++) //(sensor_02*800)
      p[i].check(prox_campo, prox_desloc_x, prox_desloc_y, prox_tam);
  }

  if (slider)
  {
    prox_campo = map(s[0].val, 0, 0.8, height, height/6);  
    prox_desloc_x = map(s[0].val, 0, 1, .5, 6);
    prox_desloc_y = map(s[0].val, 0, 1, 4, 0.5); 
    prox_tam = map(s[0].val, 0, 1, 4, 10); 

    for (int i=0; i<200+(s[0].val*800); i++) //(sensor_02*800)
      p[i].check(prox_campo, prox_desloc_x, prox_desloc_y, prox_tam);
  }

  popMatrix();

  if (slider)
  {
    s[0].check(s[0].val);
  }
}


