
float max_stroke_height = 0;
float smooth_stroke = 3.01; // offset around each vertex for blocking new vertex, changes with camera

//
//
class Stroke {

  // 
  // vertices in bed coordinates
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  
  // BBox is in world coordinates
  ArrayList<BBox> bb = new ArrayList<BBox>();
  
  float length; 
  
  // shape hold the world coordinates
  PShape shape;
  
  
  // rendering
  color c = color(140, 255, 255);
  float stroke_weight = 4;
  
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
    
    PVector pos = new PVector(x,y,z);
    if(vertices.size() > 0) {
      PVector prev = vertices.get(vertices.size()-1);
      
      // the smoothing distance for stroke, threshold is scaled by the camera distance
      // closer lines have more vertices for increased accuracy.
      float smooth_distance = CameraDistanceScaleDown();
      if(prev.dist(pos) > smooth_distance) { // if its not too close to the previous vertex
        length += prev.dist(pos); 
        vertices.add(pos); 
        
        // add selectable boundary after scaling to world coordinates
        addBBox(PVector.mult(prev,b2w(1)), PVector.mult(pos,b2w(1)));
      }
    }
    else vertices.add(pos);
    
    // update the pshape
    UpdateShape();
    
    // realtime printing
    //PrintOnline();
  }
  
  //
  public void Draw() {
    
    shape.setStroke(c);
    shape.setStrokeWeight(stroke_weight);
    shape(this.shape, 0, 0);
  }
  
  //
  public PVector IsMouseHit() {
    if (select.calculatePickPoints(mouseX, (int)map(mouseY, 0, height, height, 0))) {
      PVector hit = new PVector();
      for(int i=0; i < bb.size(); i++) {
        if (bb.get(i).CheckLineBox(select.ptStartPos, select.ptEndPos, hit)) {
          // in world coordinates
          return hit; 
        }  
      }
    }
    return null;
  }
  
  //
  // generates count many interpolated strokes in between two strokes
  public void Interpolate(Stroke s, int count) {
    int l1 = vertices.size();
    int l2 = s.vertices.size();
    int diff = abs(l1-l2);
    for(int i=1; i<=count; i++){
      // rows [0,1]
      float __i = i/float(count+1);
      Stroke new_stroke = new Stroke();      
      for(int j = 0; j < min(l1, l2)+int(diff*__i); j++) {
        // cols [0,1] -- to select which coordinate to use
        float __j = j/float(min(l1, l2)+int(diff*__i)); 
        
        PVector p1 = vertices.get(int(__j*l1));
        PVector p2 = s.vertices.get(int(__j*l2));
        
        PVector v = PVector.add(PVector.mult(p1,__i), PVector.mult(p2,(1-__i)));
        new_stroke.AddVertex(v.x,v.y,v.z);
      }
      p.strokes.add(new_stroke);
    }
  }
  
  //
  public float GetHeight() {
    if(vertices.size() > 0)
      return vertices.get(0).z; 
    return 0;
  }  
  
  //
  private void addBBox(PVector min, PVector max) {
    PVector p1 = min.copy(), p2 = max.copy();
    PVector line = PVector.sub(max,min);
    float off = 10; // px
    line.z = max(off, line.z);
    line.y = max(off, line.y);
    line.x = max(off, line.x);
    
    p2 = PVector.add(min,line);
    bb.add(new BBox(p1, p2));
  }
}
