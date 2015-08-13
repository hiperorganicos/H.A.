void oscEvent(OscMessage msg) {
  
  String addr = msg.addrPattern();
  float val = msg.get(0).floatValue();
  
  if (addr.equals("/a")) {
    sensor_01 = constrain(val, 0, 0.8);
  }else if(addr.equals("/b")) {
    sensor_02 = val;
  }
  
  println("sensor_01: " + sensor_01 + " sensor_02: " + sensor_02);
  
}

