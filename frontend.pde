import drawing.library.*;

DrawingManager drawingManager;
DShape shape;

//void normalizeShape(){
// ArrayList<DPoint> points = shape.getNormalizedVertices();
// DShape s2 = drawingManager.addShape();
// for(int i=0;i<points.size();i++){
//   s2.addVertex(points.get(i).x,points.get(i).y);
// }
//}

void setup() {
  size(400, 400, P3D);
  //fullScreen(P3D, 3);
  
  frameRate(25);
  
  //InitCamera();
  InitOSC(12000, "127.0.0.1", 5876);
  
  drawingManager = new DrawingManager(this);
  background(30);  
  drawingManager.stroke(200,249,223);
}


void draw() {

  
  
  //fill(255, 200);
  //box(50);
}
