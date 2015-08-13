class slider {
  int posX, posY, w, sz;
  String lbl;
  float val;
   
  slider(int _posX, int _posY, int _w, int _sz, String _lbl, float _val) {
    posX = _posX; posY = _posY;
    w = _w; sz = _sz;
    lbl = _lbl;
    val = _val;
  }
  void check(float dispVal) {
    color f = 0; color s = 128;
    int x = posX + int(w * val);
    if (mouseY > posY - sz && mouseY < posY + sz*2 && mouseX > posX && mouseX < posX + w + sz) {
      f = 64; s = 255;
      if (mousePressed) x = constrain(mouseX, posX, posX+w);
    }
    val = (x - posX) / float(w);
    stroke(s); fill(f);
    line(posX, posY + sz*0.5, posX + w + sz, posY + sz*0.5);
    rect(posX + w*val, posY, sz, sz);
    fill(s);
    textAlign(LEFT, CENTER);
    text(lbl, posX, posY-sz);
    textAlign(RIGHT, CENTER);
    text(nfc(dispVal,2), posX+w+sz, posY-sz);
  } 
}
 
class checkbox {
  int posX, posY, sz;
  String lbl;
  boolean val, hot;
  checkbox(int _posX, int _posY, int _sz, String _lbl, boolean _val) {
    posX = _posX; posY = _posY; sz = _sz;
    lbl = _lbl;
    val = _val;
  }
  void check() {
    color f = 0; color s = 128;
    if (mouseY > posY - sz && mouseY < posY + sz*2 && mouseX > posX - sz && mouseX < posX + sz*2) {
      f = 64; s = 255;
      if(mousePressed) hot = true;
      else if(hot) {
        val = !val;
        hot = false;
      }
    } else hot = false;
    stroke(s); fill(f);
    rect(posX, posY, sz, sz);
    if (val) {
      strokeWeight(2);
      line(posX,posY, posX+sz,posY+sz);
      line(posX+sz,posY, posX,posY+sz);
      strokeWeight(1);
    }
    fill(s);
    textAlign(LEFT, CENTER);
    text(lbl, posX, posY-sz);
  }
}
