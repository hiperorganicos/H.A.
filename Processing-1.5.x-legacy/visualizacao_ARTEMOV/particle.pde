class particle {
  PVector loc = new PVector(random(-width/2,width/2), random(-height/2, height/2)); // campo de origem
  PVector vel = new PVector(0, 0);
  PVector target = new PVector(0, 0); 
  PVector acc;
  
   float easing = 0.05;
  void check(float campo, float desloc_x, float desloc_y, float tam) 
  { 
    //void inside (se loc.x estiver fora do campo, buscar x proximo ease do campo)
                  //(se loc.y estiver fora do campo, buscar y proximo ease do campo)  
    //target.limit(campo);
    //if(loc.x != target){
    
    acc = new PVector(random(-desloc_x, desloc_x), random(-desloc_y,desloc_y), 0); //
    
    loc.add(vel);
    loc.limit(campo);
    vel.add(acc);
    vel.limit(4);
     
    int colorIndex = int(random(pColors.length));

    //glow
//      noStroke();
//    fill(pColors[colorIndex],2);
//      ellipse(loc.x, loc.y, 12,12);
    
    // particles    
    fill(pColors[colorIndex]);   
    ellipse(loc.x, loc.y, tam, tam);
  }
}

