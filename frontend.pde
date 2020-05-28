import drawing.library.*;

DrawingManager drawingManager;
DShape shape;

void setup() {
  size(400, 400, P3D);
  //fullScreen(P3D, 3);
  
  frameRate(15);
  
  //InitCamera();
  InitOSC(12000, "127.0.0.1", 5876);
  
  background(30);
  drawingManager = new DrawingManager(this);
  drawingManager.stroke(50,249,150);
}


void draw() {
  //fill(255, 200);
  //box(50);
}
