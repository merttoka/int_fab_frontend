import controlP5.*;

//
ControlP5 cp5;

// labels
Textlabel layerlabel;
Textlabel printmodelabel;

// colorpicker
ColorPicker cp;

// 
Textfield tweencount;

String current_stroke_len = "";

//
int tx,ty; 

//
void InitGUI() {
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  tx = width-150;
  ty = height-450;
  
  // initializes individual GUI view
  AddViews();
}

// draw
void DrawGUI() {
  hint(DISABLE_DEPTH_TEST);
  pushStyle();
  cam.beginHUD();
  noStroke();
  pushMatrix();
  translate(tx, ty);
  fill(0, 150);
  rect(0, 0, 125, 440);
  rect(-155, 360, 155, 80);
  popMatrix();
  cp5.draw();
  translate(25,height-25);
  fill(30,150);
  if(current_stroke_len!="") rect(-10, -15, textWidth(current_stroke_len)+10, 20);
  fill(235);
  textSize(15);
  text(current_stroke_len, 0,0);
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
   .setPosition(tx+10,ty+10)
   .setSize(50,50);
  layerlabel = cp5.addTextlabel("layer_height")
   .setText(GetLayerLabelText())
   .setPosition(tx+7,ty+75);
  cp5.addButton("move_down")
   .setPosition(tx+63,ty+10)
   .setSize(50,50);
  
  //
  tweencount = cp5.addTextfield("tween_count")
    .setPosition(tx+10, ty+100)
    .setSize(30,20);
  cp5.addButton("interpolate")
    .setPosition(tx+50, ty+100)
    .setSize(60,20);
  
  cp5.addButton("_selected")
   .setPosition(tx+10,ty+160)
   .setSize(50,50);
  cp5.addButton("_stroke")
   .setPosition(tx+63,ty+160) 
   .setSize(50,50);
  
  printmodelabel = cp5.addTextlabel("print_mode_label")
   .setPosition(tx+5, ty+220)
   .setSize(100,50)
   .setText(GetPrintingModeText());
   
  cp5.addButton("PRINT")
   .setPosition(tx+10,ty+310)
   .setSize(100,50); 
  
  //
  cp = cp5.addColorPicker("picker")
          .setPosition(tx-145, ty+370)
          .setColorValue(color(material_color, 255))
          ;
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
  // sort by selection, selected items are in the beginnning
  Collections.sort(p.sm.strokes, new SortBySelection());
  List<Stroke> sublist = p.sm.strokes.subList(0, p.sm.selected_count);
  
  ArrayList<Stroke> _selected = new ArrayList<Stroke>(sublist);
  // send it to print thread
  sender = new PrintSender(_selected); 
  sender.start();
}

//  GUI Utils
////////////////// 
String GetLayerLabelText() {
  return "["+ int(p.current_height/p.layer_height) +"]  " + nfc(p.current_height,2) + " mm";  
}
String GetPrintingModeText() {
  return (__drawMode ? "Print stroke upon finishing it" : "Print selected strokes \nusing PRINT button.\n\nTo select strokes,\n disable drawing mode,\n hold SHIFT and\n select the stroke.");
}
