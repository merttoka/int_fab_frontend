
float max_stroke_height = 0;

//
//
class Stroke {

  // 
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  
  //
  PShape shape;
  BBox bb;
  
  // rendering
  color c = color(0, 255, 255);
  float stroke_weight = 3;
  
  //
  public Stroke() {
    shape = createShape();
  }
  
  // writes vertices into PShape in world coordinates 
  public void UpdateShape() {
    shape = createShape();
    shape.beginShape();
    shape.noFill();
    for(int i=0; i<vertices.size();i++) {
      PVector _p = vertices.get(i);
      shape.vertex(b2w(_p.x),b2w(_p.y),b2w(_p.z));  
    } 
    shape.endShape();
  }
  
  // stores point in bed coordinates
  public void AddVertex(float x, float y, float z) {
    if(z>max_stroke_height) max_stroke_height=z;
    vertices.add(new PVector(x,y,z));
  }
  
  //
  public void Draw() {
    UpdateShape();
    
    //shape.scale(b2w(1)); // scale to world coordinates for rendering
    shape.setStroke(c);
    shape.setStrokeWeight(stroke_weight);
    shape(this.shape, 0, 0);
  }
  
  //
  public float GetHeight() {
    if(vertices.size() > 0)
      return vertices.get(0).z; 
    return 0;
  }
}
