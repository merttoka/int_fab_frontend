// IPAD CONTROLS ??


// MOUSE CONTROLS
// 
void mousePressed() {
  shape = drawingManager.addShape(); 
  //SendMessage(mouseX, mouseY, 0.2);
}
void mouseDragged() {
  shape.addVertex(mouseX,mouseY); 
  
  float x = constrain(map(mouseX, 0, width, 0, 150), 0, 150);
  float y = constrain(map(mouseY, 0, height, 0, 150), 0, 150);
  SendMessage(x,y,5);
}

// KEYBOARD CONTROLS
//
void keyPressed() {
   if(key == 'c'){
    drawingManager.clear();
    background(30);
  }
}
