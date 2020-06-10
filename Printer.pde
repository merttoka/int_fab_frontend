//
float b2w_ratio = 2;
// translate real coordinates (bed) to processing coordinates (world) 
float b2w(float b) { return b2w_ratio*b; }
// translate processing coordinates (world) to real coordinates (bed) 
float w2b(float w) { return w/b2w_ratio; }

// 
// dimensions for real objects on the machine (in mm)
float bed_thickness = 5;
float bed_size = 240;      // bed width/height
float safe_bed_size = 215; //
float nozzle_width = 58;   // width of the nozzle case
float nozzle_depth = 40;   // depth of the nozzle case
float nozzle_radius = 0.4;
float bar_depth = 20;      // bar that holds the nozzle

//
// Printer class that handles all paths
class Printer {
  
  // Printer limits xy
  float max_xy = safe_bed_size, min_xy = 0;
  float max_z = 240,  min_z  = 0.4;
  
  //
  float layer_height = 0.3;
  
  //
  BBox bb_current;
  float current_height = layer_height;
  PVector nozzle_pos = new PVector(0,0,0);
  
  // 
  float bed_temp = 0;
  float bed_temp_target = 0;
  float nozzle_temp = 0;
  float nozzle_temp_target = 0;
  
  // 
  float rate_first_layer = 600;
  float rate_normal = 800;
  float rate_high = 3000; 
  
  //
  StrokeManager sm = new StrokeManager();

  //  
  public Printer() {
    // bounding box for current layer
    this.bb_current = new BBox(new PVector(0,0,0), 
                               new PVector(b2w(bed_size),b2w(bed_size),b2w(current_height)));
  }

  //
  void Update() {
    UpdateWheelHandler();
    
    bb_current.UpdateToDrawingHeight(b2w(bed_size), b2w(bed_size), b2w(current_height));
  }
  
  //
  void Draw() {
    lights();
    pushMatrix();
    DrawGizmo(b2w(bed_size), 150, false);//110*4.35
    
    // draw bed
    pushMatrix();
    translate(b2w(bed_size)*0.5, b2w(bed_size)*0.5, -b2w(bed_thickness)*0.5);
    stroke(230);
    fill(30);
    box(b2w(bed_size),b2w(bed_size),b2w(bed_thickness));
    popMatrix();
    
    // draw current drawing plane    
    pushMatrix();
    pushStyle();
    hint(DISABLE_DEPTH_TEST);
    translate(0,0,b2w(current_height));
    stroke(30, 240, 240);
    if(__isDraw) fill(40, 240, 240, 50);
    else         fill(30, 0, 240, 20);
    rect(-10,-10,20+b2w(bed_size), 20+b2w(bed_size));
    hint(ENABLE_DEPTH_TEST);
    popStyle();
    popMatrix();
    
    //
    // draw a box for mouse cursor
    DrawMouseCursor();
    
    //
    // draw strokes
    sm.DrawAll();
    
    //
    // draw nozzle
    stroke(0, 200, 200, 150);
    line(b2w(nozzle_pos.x), b2w(nozzle_pos.y), b2w(nozzle_pos.z), 
         b2w(nozzle_pos.x), b2w(nozzle_pos.y), b2w(nozzle_pos.z+40));
    
    popMatrix();
  }
  
  // -1 decrease, 1 increase Z
  public void MoveZ(int sign) {
    // TODO: dont lower if printed structures collide with nozzle
    if(sign == -1 || sign == 1) {
      current_height += sign * layer_height; 
      current_height = constrain(current_height, min_z, max_z);
      
      // change the z of lookat
      float[] lookat = cam.getLookAt();
      cam.lookAt(lookat[0], lookat[1], lookat[2]+b2w(sign*layer_height));
    }
  }
  
  // shift mouse wheel 
  public void UpdateWheelHandler() {
    if(__isShiftDown) {
      cam.setWheelHandler(new PeasyWheelHandler(){
         public void handleWheel(final int wheel){
           MoveZ(-wheel);
           layerlabel.setText(GetLayerLabelText());  // update label
         }
      });    
    }
    else   cam.setWheelHandler(wheelHandler);
  }
  
  //
  public PVector MousePointInWorldCoordinates() {
    if (select.calculatePickPoints(mouseX, (int)map(mouseY, 0, height, height, 0))) {
      PVector hit = new PVector();
      if (bb_current.CheckLineBox(select.ptStartPos, select.ptEndPos, hit)) {
        // in world coordinates
        return hit; 
      }
    }
    return null;
  }
}
