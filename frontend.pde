
void setup() {
  size(400, 400, P3D);
  //fullScreen(P3D, 3);
  
  frameRate(25);
  
  InitCamera();
  InitOSC(12000, "127.0.0.1", 5876);
}


void draw() {
  background(30);  
  
  
  fill(255, 200);
  box(50);
}
