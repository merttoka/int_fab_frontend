//
color background = color(30);

//
Printer p;

void setup() {
  size(800, 800, P3D); //fullScreen(P3D, 3);
  colorMode(HSB);
  smooth();
  
  p = new Printer();
  
  InitCamera();
  InitOSC(12000, "127.0.0.1", 5876);
  InitGUI();
}

void draw() {
  background(background); 
  scale(1,-1,1);                             // flip-y
  select.captureViewMatrix((PGraphics3D)g);  // feed selection obj
  
  // update printer environment variables
  p.Update();
  
  
  // draws printer environment
  p.Draw();
 
  // draws the UI
  DrawGUI();
}
