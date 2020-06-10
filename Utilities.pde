
//
PVector _X = new PVector(1,0,0);
PVector _Y = new PVector(0,1,0);
PVector _Z = new PVector(0,0,1);

//
PVector _min(PVector p0, PVector p1) {
  PVector p = new PVector(0,0,0);
  if(p0.x > p1.x) p.x = p1.x;
  else            p.x = p0.x;
  if(p0.y > p1.y) p.y = p1.y;
  else            p.y = p0.y;
  if(p0.z > p1.z) p.z = p1.z;
  else            p.z = p0.z;
  return p;
}
PVector _max(PVector p0, PVector p1) {
  PVector p = new PVector(0,0,0);
  if(p0.x < p1.x) p.x = p1.x;
  else            p.x = p0.x;
  if(p0.y < p1.y) p.y = p1.y;
  else            p.y = p0.y;
  if(p0.z < p1.z) p.z = p1.z;
  else            p.z = p0.z;
  return p;
}

// 
float stepMap(float val, float min0, float max0, float min1, float max1) {
  return constrain(map(val, min0, max0, min1, max1), min(min1,max1), max(min1,max1));
}

// 
// Console print manager
// 'level' is importance of the message: [0, 4]
void PrintManager(String message, int level) {
  level = constrain(level, 0, 4);
  String prefix = ""; 
  switch(level) {
    case 4:
      prefix = "#####\t";
      break;
    case 3:
      prefix = " ####\t";
      break;
    case 2:
      prefix = "  ###\t";
      break;
    case 1:
      prefix = "   ##\t";
      break;
    case 0:
      prefix = "    #\t";
      break;
    default:
      break;
  }
  
  String ts = hour()+":"+minute()+":"+second()+" "+month()+"/"+day();
  
  println(prefix+" "+message+" ("+ts+")");
}


//
// on current_height
void DrawMouseCursor() {
  if (select.calculatePickPoints(mouseX, (int)map(mouseY, 0, height, height, 0))) {
    PVector hit = new PVector();
    if (p.bb_current.CheckLineBox(select.ptStartPos, select.ptEndPos, hit)) {
      // hit is in world coordinates
      pushMatrix();
      pushStyle();
      translate(hit.x, hit.y, hit.z);
      noStroke();
      if(!__isShiftDown) fill(235, 150);
      else               fill(selected_color, 150);
      float r = CameraDistanceScaleDown()*3*b2w(nozzle_radius); 
      if(!__isShiftDown) ellipse(0,0,r,r);
      else               rect(-0.5*r, -0.5*r, r, r);
      popStyle();
      popMatrix();
    }
    
  }
}
//
// Draws the X,Y,Z lines with R,G,B respectively
void DrawGizmo(float scale, float alpha, boolean drawPlanes) {
  pushStyle();

  colorMode(HSB);
  float planeScale = scale * 0.6;
  float planeOpacity = alpha*0.5;  
  rectMode(CORNER);
  strokeWeight(5);
  pushMatrix();
  
  // xy plane
  if(drawPlanes){
    noStroke();
    fill(0,200,200,planeOpacity);
    rect(0,0,planeScale,planeScale);
  }
  // x axis 
  stroke(0,200,200,alpha);
  line(0,0,0, scale, 0, 0);
  
  // yz plane
  if(drawPlanes){
    pushMatrix();
    rotateY(-PI/2);
    noStroke();
    fill(255/3,200,200,planeOpacity);
    rect(0,0,planeScale,planeScale);
    popMatrix();
  }
  // y axis
  stroke(255/3,200,200,alpha);
  line(0,0,0, 0, scale, 0);
  
  // xz plane
  if(drawPlanes){
    pushMatrix();
    rotateX(PI/2);
    noStroke();
    fill(255*2/3,200,200,planeOpacity);
    rect(0,0,planeScale,planeScale);
    popMatrix();
  }
  // z axis
  stroke(255*2/3,200,200,alpha);
  line(0,0,0, 0, 0, scale);
  
  popMatrix();
  popStyle();
}
