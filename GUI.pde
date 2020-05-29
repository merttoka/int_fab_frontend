import controlP5.*;

//
ControlP5 cp5;

// layer label
Textlabel layerlabel;

//
void InitGUI() {
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  // initializes individual GUI view
  AddViews();
}

// draw
void DrawGUI() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  fill(0, 150);
  rect(0, 0, 70,160);
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

// the control event
void controlEvent(ControlEvent theEvent) {
  //println(theEvent.getController().getId());
}

// 
void AddViews() {
  cp5.addButton("move_up")
   .setPosition(10,10)
   .setSize(50,50);
  cp5.addButton("move_down")
   .setPosition(10,100)
   .setSize(50,50);
  layerlabel = cp5.addTextlabel("layer_height")
   .setText(GetLayerLabelText())
   .setPosition(7,75);
}

//
// Listeners
//////////////////  
// button controllers
public void move_up(int _) {
  p.MoveZ(1);
  layerlabel.setText(GetLayerLabelText());
}
public void move_down(int _) {
  p.MoveZ(-1);
  layerlabel.setText(GetLayerLabelText());
}


//  GUI Utils
////////////////// 
String GetLayerLabelText() {
  return "["+ int(p.current_height/p.layer_height) +"]  " + nfc(p.current_height,2) + " mm";  
}
