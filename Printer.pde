//
float b2w_ratio = 2;
// translate real coordinates (bed) to processing coordinates (world) 
float b2w(float b) { return b2w_ratio*b; }
// translate processing coordinates (world) to real coordinates (bed) 
float w2b(float w) { return (1/b2w_ratio)*w; }

// 
// dimensions for real objects on the machine (in mm)
float bed_thickness = 5;
float bed_size = 240;      // bed width/height
float safe_bed_size = 220; //
float nozzle_width = 58;   // width of the nozzle case
float nozzle_depth = 40;   // depth of the nozzle case
float nozzle_radius = 0.4;
float bar_depth = 20;      // bar that holds the nozzle


//
// Printer class that handles all paths
class Printer {
  //
  BBox bb;
  
  // Printer limits xy
  float max_xy = safe_bed_size, min_xy = 0;
  float max_z = 240,  min_z  = 0.3;
  
  //
  float layer_height = 0.3;
  
  //
  BBox bb_current;
  float current_height = layer_height;
  PVector pos = new PVector(0,0,0), 
          last_pos = new PVector(0,0,0);
  
  //
  ArrayList<Stroke> strokes = new ArrayList<Stroke>();

  // 
  public Printer() {
    this.bb_current = new BBox(new PVector(0,0,0), 
                               new PVector(b2w(bed_size),b2w(bed_size),b2w(current_height)));
  }

  //
  // fixed?
  void Update() {
    bb_current.UpdateMax(b2w(bed_size), b2w(bed_size), b2w(current_height));
    
    CaptureDraw();
  }
  
  //
  void Draw() {
    pushMatrix();
    DrawGizmo(100, 150, false);
    
    // draw bed
    pushMatrix();
    translate(b2w(bed_size)*0.5, b2w(bed_size)*0.5, -b2w(bed_thickness)*0.5);
    stroke(30);
    fill(255);
    box(b2w(bed_size),b2w(bed_size),b2w(bed_thickness));
    popMatrix();
    
    // draw current drawing plane
    pushMatrix();
    hint(DISABLE_DEPTH_TEST);
    translate(0,0,b2w(current_height));
    stroke(30);
    fill(140, 240, 240, 50);
    rect(-10,-10,20+b2w(bed_size), 20+b2w(bed_size));
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
    
    // draw a box for mouse cursor
    DrawMouseCursor();
    
    // draw strokes
    //hint(ENABLE_STROKE_PERSPECTIVE);
    for(int i=0; i < strokes.size(); i++) {
      Stroke s = strokes.get(i);  
      float h = s.GetHeight();
      if(h>0 && h <= current_height)
        s.c = color(30, (int)map(h, 0, current_height, 30, 255));
      else if(h>0 && h > current_height)
        s.c = color(30, (int)map(h, current_height, max_stroke_height, 255, 30));
      s.Draw();
    }
    //hint(DISABLE_STROKE_PERSPECTIVE);
    
    // draw nozzle
    //
    
    popMatrix();
  }
  
  // onpress
  Stroke temp=null;
  public void StartStroke() {
    if(__isDrawMode) {
      temp = new Stroke();
      strokes.add(temp);
    }
  }
  // ondrag
  public void CollectStroke() {
    if(__isDrawMode) {
      if(temp != null && strokes.size() >= 1) {
        PVector wc = MousePointInWorldCoordinates();
        if (wc!=null)   strokes.get(strokes.size()-1).AddVertex(w2b(wc.x), w2b(wc.y), w2b(wc.z));
      }
    }
  }
  // onrelease
  public void EndStroke() {
    if(__isDrawMode) temp = null;
  }
    
  
  //
  public void MoveXY(float x, float y) {
    pos.x = x;
    pos.y = y;
    pos.x = constrain(pos.x, min_xy, max_xy);
    pos.y = constrain(pos.y, min_xy, max_xy);
  }
  
  // -1 decrease, 1 increase Z
  public void MoveZ(int sign) {
    // TODO: dont lower if printed structures collide with nozzle
    if(sign == -1 || sign == 1) {
      current_height += sign * layer_height; 
      current_height = constrain(current_height, min_z, max_z);
      pos.z = current_height;
    }
  }
  
  public PVector MousePointInWorldCoordinates() {
    if (select.calculatePickPoints(mouseX, (int)map(mouseY, 0, height, height, 0))) {
      PVector hit = new PVector();
      if (bb_current.CheckLineBox(select.ptStartPos, select.ptEndPos, hit)) {
        // in world coordinates
        //println(hit.x, hit.y, hit.z);
        return hit; 
      }
    }
    return null;
  }
  
  void CaptureDraw() {
    if(__isDrawMode) {
      // x,y,z
      // z is height
    }
  }
}


// on current_height
void DrawMouseCursor() {
  if (select.calculatePickPoints(mouseX, (int)map(mouseY, 0, height, height, 0))) {
    PVector hit = new PVector();
    if (p.bb_current.CheckLineBox(select.ptStartPos, select.ptEndPos, hit)) {
      // in world coordinates
      //println(hit.x, hit.y, hit.z);
      pushMatrix();
      translate(hit.x, hit.y, hit.z);
      fill(255);
      box(10);
      popMatrix();
    }
  }
}
