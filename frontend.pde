//
color background = color(30);

//
Printer p;

public void settings() {
  fullScreen(P3D, 1); // 2388 x 1668
  //size(int(2388*0.5), int(1668*0.5), P3D);  // /
}
void setup() {    
  colorMode(HSB);
  smooth();
  
  //
  p = new Printer();
  
  //
  InitCamera();
  InitGUI();
  InitOSC(12000, "127.0.0.1", 5876);
}

void draw() {
  background(background); 
  scale(1,-1,1);                             // flip-y
  select.captureViewMatrix((PGraphics3D)g);  // feed selection object with viewmatrix
  
  //for(int i = 0; i < p.strokes.size(); i++) {
  //  println(i, p.strokes.get(i).isFlat, "l="+p.strokes.get(i).length);
  //}
    
  // update printer environment variables
  p.Update();
  // draws printer environment
  p.Draw();
  // draws the UI
  DrawGUI();
}
