
//
Printer p;

public void settings() {
  fullScreen(P3D, 2); // 2388 x 1668
  //size(int(2388*0.5), int(1668*0.5), P3D);  // /
}
void setup() {    
  colorMode(HSB);
  smooth();
  PFont myFont = createFont("Arial", 32);
  textFont(myFont);
  
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
  
  // update printer environment variables
  p.Update();
  // draws printer environment
  p.Draw();
  // draws the UI
  DrawGUI();
}
