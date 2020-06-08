import controlP5.*;

//
ControlP5 cp5;

// labels
Textlabel layerlabel;
Textlabel printmodelabel;


// 
Textfield tweencount;

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
  pushStyle();
  cam.beginHUD();
  noStroke();
  fill(0, 150);
  rect(0, 0, 70,160);
  cp5.draw();
  cam.endHUD();
  popStyle();
  hint(ENABLE_DEPTH_TEST);
}

// the control event
void controlEvent(ControlEvent theEvent) {
  //println(theEvent.getController().getId());
}

// 
void AddViews() {
  //
  cp5.addButton("move_up")
   .setPosition(10,10)
   .setSize(50,50);
  layerlabel = cp5.addTextlabel("layer_height")
   .setText(GetLayerLabelText())
   .setPosition(7,75);
  cp5.addButton("move_down")
   .setPosition(10,100)
   .setSize(50,50);
  
  //
  tweencount = cp5.addTextfield("tween_count")
    .setPosition(10, 180)
    .setSize(50,20);
  
  cp5.addButton("_selected")
   .setPosition(10,250)
   .setSize(50,50);
  cp5.addButton("_stroke")
   .setPosition(63,250) 
   .setSize(50,50);
  
  printmodelabel = cp5.addTextlabel("print_mode_label")
   .setPosition(5, 310)
   .setSize(100,50)
   .setText(GetPrintingModeText());
   
  cp5.addButton("PRINT")
   .setPosition(10,380)
   .setSize(100,50); 
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
public void tween_count(String theText) { 
  // automatically receives results from controller input
  tween_c = int(theText);
}
public void _stroke(int _) { 
  __drawMode = true;
  printmodelabel.setText(GetPrintingModeText());
}
public void _selected(int _) { 
  __drawMode = false;
  printmodelabel.setText(GetPrintingModeText());
}
public void PRINT(int _) { 
  // print selected curves
}

//  GUI Utils
////////////////// 
String GetLayerLabelText() {
  return "["+ int(p.current_height/p.layer_height) +"]  " + nfc(p.current_height,2) + " mm";  
}
String GetPrintingModeText() {
  return (__drawMode ? "Print stroke upon finishing it" : "Print selected strokes \nusing PRINT button.\n\nTo select strokes,\n disable drawing mode,\n hold SHIFT and\n select the stroke.");
}
