// IPAD CONTROLS ??


// MOUSE CONTROLS
// 
void mousePressed() {
  if(mouseButton == RIGHT)
    drawingManager.stroke(50,249,150);
  else if (mouseButton == LEFT) {
    drawingManager.stroke(249,55,150);
    SendMessage("/extract");
  }
  shape = drawingManager.addShape();
}
void mouseReleased() {
  if (mouseButton == LEFT) {
    SendMessage("/retract");
  }
}
void mouseDragged() {
  shape.addVertex(mouseX,mouseY); 
  
  String name = "/move";
  int max = 220, min = 0;
  float x = constrain(map(mouseX, 0, width, min, max), min, max);
  float y = constrain(map(mouseY, 0, height, max, min), min, max);
  if(mouseButton == LEFT) 
    name = "/extrude_move";
  else if(mouseButton == RIGHT)
    name = "/just_move";
  
  SendMessage(name, x, y, 0.4);
}

// KEYBOARD CONTROLS
//
void keyPressed() {
   if(key == 'c'){
    drawingManager.clear();
    background(30);
  }
}
