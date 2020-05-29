// IPAD CONTROLS ??


// MOUSE CONTROLS
// 

void mousePressed() { 
  if(mouseButton != CENTER) p.StartStroke();
}
void mouseDragged() {
  if(mouseButton != CENTER) p.CollectStroke();
}
void mouseReleased() {
  if(mouseButton != CENTER) p.EndStroke();
}

//void mousePressed() {
  //if(mouseButton == RIGHT)
    //drawingManager.stroke(50,249,150);
  //else if (mouseButton == LEFT) {
    //drawingManager.stroke(249,55,150);
    //SendMessage("/extrude");
  //}
  //shape = drawingManager.addShape();
//}
//void mouseReleased() {
  //if (mouseButton == LEFT) {
    //SendMessage("/retract");
  //}
  //last_pos = pos.copy();
//}
//void mouseDragged() {
  //shape.addVertex(mouseX,mouseY); 
  
  //String name = "/move";
  ////last_pos = pos = ScreenToBedCoordinates();
  //if(mouseButton == LEFT) 
  //  name = "/move/extrude";
  //else if(mouseButton == RIGHT)
  //  name = "/move";
  
  //SendMessage(name, pos.x, pos.y, pos.z);
//}

// KEYBOARD CONTROLS
//
boolean __isDrawMode = false;
// 
void keyPressed(KeyEvent e) {
  if(key == ' ') {
    __isDrawMode = !__isDrawMode;
    if(__isDrawMode) {
      cam.setLeftDragHandler(null);
      cam.setRightDragHandler(null);
    }
    else {
      cam.setLeftDragHandler(rotateHandler);
      cam.setRightDragHandler(zoomHandler);
    }
  }
  if(key == 't' || key == 'T') {
    TopView();
  }
  
}
////////////////////////////////
