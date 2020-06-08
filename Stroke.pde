float smooth_stroke = 3.01; // offset around each vertex for blocking new vertex, changes with camera

//
//
class Stroke {
  Printer printer = p; // global
  
  // 
  // vertices in bed coordinates
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  
  // BBox is in world coordinates
  ArrayList<BBox> bb = new ArrayList<BBox>(); // each line in stroke has its own bounding box
  
  // shape hold the world coordinates
  PShape shape;
  
  // rendering
  color c = material_color;
  float stroke_weight = 4;
  
  // stroke length in mm
  float length;
  
  // 
  boolean isClosed = false;
  boolean isFlat = true;
  
  //
  public Stroke() {
    shape = createShape();
  }
  
  // writes vertices into PShape in world coordinates 
  public void UpdateShape() {
    shape = createShape();
    shape.beginShape();
    shape.colorMode(HSB);
    shape.noFill();
    for(int i=0; i<vertices.size();i++) {
      PVector _p = vertices.get(i);
      shape.vertex(b2w(_p.x),b2w(_p.y),b2w(_p.z));  
    } 
    shape.endShape();
  }
  
  // stores point in bed coordinates
  public void AddVertex(float x, float y, float z) {
    PVector pos = new PVector(x,y,z);
    if(vertices.size() > 0) {
      PVector prev = vertices.get(vertices.size()-1);
      PVector first = vertices.get(0);
      
      // the smoothing distance for stroke, threshold is scaled by the camera distance
      // closer lines have more vertices for increased accuracy.
      float smooth_distance = CameraDistanceScaleDown();
      if(prev.dist(pos) > smooth_distance) { // if its not too close to the previous vertex
        length += prev.dist(pos); 
        vertices.add(pos); 
        
        // add selectable boundary after scaling to world coordinates
        addBBox(PVector.mult(prev,b2w(1)), PVector.mult(pos,b2w(1)));
      }
      else if(vertices.size() > 10 && first.dist(pos) <= smooth_distance) { // if its close to first vertex, close the curve
        this.isClosed = true;
        this.length += first.dist(pos);
        
        vertices.add(first); 
      }
    }
    else vertices.add(pos);
    
    // update the pshape
    UpdateShape();
    
    // realtime printing
    //if(__drawMode == 2)  PrintOnline();
  }
  
  //
  public void Draw() {
    shape.setStroke(c);
    shape.setStrokeWeight(stroke_weight);
    if(isClosed) shape.setFill(c);
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
  public float GetHeight() {
    if(isFlat && vertices.size() > 0)
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
  //
  private void UpdateIsFlat() {
    // check z coordinates of vertices to see if they are approximately the same height, 
    // otherwise mark as not flat
    float sum_z = 0;
    boolean flag = true;
    for(int i = 0; i < vertices.size(); i++) {
      float og_z = vertices.get(i).z;
      sum_z += og_z;
      
      float avg_z = sum_z/(i+1);
      //println(i, og_z, avg_z, abs(og_z-avg_z), p.layer_height);
      if(abs(og_z-avg_z) > p.layer_height) {flag = false;break;}
    }
    this.isFlat = flag;
  }
}

// sorting the strokes in ascending order based on z positions
class SortbyLayerHeight implements Comparator<Stroke> 
{ 
    public int compare(Stroke a, Stroke b) 
    { 
       if(a.GetHeight() > b.GetHeight())
         return 1;
       else if(a.GetHeight() == b.GetHeight())
         return 0;
       else
         return -1;
    } 
} 
