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
  float layer_height = 0.4;
  
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
  float rate_first_layer = 750;
  float rate_normal = 1400;
  float rate_high = 2000; 
  
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
    UpdateWheelHandler();
    bb_current.UpdateMax(b2w(bed_size), b2w(bed_size), b2w(current_height));
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
    pushStyle();
    hint(DISABLE_DEPTH_TEST);
    translate(0,0,b2w(current_height));
    stroke(255);
    if(__isDrawMode) fill(140, 240, 240, 50);
    else             noFill();
    rect(-10,-10,20+b2w(bed_size), 20+b2w(bed_size));
    hint(ENABLE_DEPTH_TEST);
    popStyle();
    popMatrix();
    
    //
    // draw a box for mouse cursor
    DrawMouseCursor();
    
    //
    // draw strokes
    pushStyle();
    hint(ENABLE_STROKE_PERSPECTIVE);
    for(int i=0; i < strokes.size(); i++) {
      Stroke s = strokes.get(i);  
      float h = s.GetHeight();
      s.c = color(160, 255, 255, (h == current_height ? 255 : 50));
      s.Draw();
    }
    hint(DISABLE_STROKE_PERSPECTIVE);
    popStyle();
    
    //
    // draw nozzle
    stroke(0, 200, 200, 150);
    line(b2w(nozzle_pos.x), b2w(nozzle_pos.y), b2w(nozzle_pos.z), 
         b2w(nozzle_pos.x), b2w(nozzle_pos.y), b2w(nozzle_pos.z+40));
    
    popMatrix();
  }
  
  // BRUSH STROKE FUNCTIONS
  /////////////////////
  //
  // onpress
  Stroke temp=null;
  public void StartStroke() {
    temp = new Stroke();
    strokes.add(temp);
  }
  // ondrag
  public void CollectStroke() {
    if(temp != null && strokes.size() >= 1) {
      PVector wc = MousePointInWorldCoordinates();
      if (wc!=null)   strokes.get(strokes.size()-1).AddVertex(w2b(wc.x), w2b(wc.y), current_height);
    }
  }
  // onrelease
  public void EndStroke() {
    // actual printing
    (new PrintSender(temp.vertices, temp.length)).start();
    
    temp = null;
  }
  //////////////////////////////////////////////  
  
  //
  //public void MoveXY(float x, float y) {
  //  pos.x = x;
  //  pos.y = y;
  //  pos.x = constrain(pos.x, min_xy, max_xy);
  //  pos.y = constrain(pos.y, min_xy, max_xy);
  //}
  
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
  
  //
  void UpdateWheelHandler() {
    if(__isAltDown) {
      cam.setWheelHandler(new PeasyWheelHandler(){
         public void handleWheel(final int wheel){
           MoveZ(-wheel);
           // update label
           layerlabel.setText(GetLayerLabelText());
         }
      });    
    }
    else {
      cam.setWheelHandler(wheelHandler);
    }
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
  
  
  // 
  // class to send messages on a separete thread by slowing down the rate
  class PrintSender extends Thread {
    float length;
    // vertices of shape
    ArrayList<PVector> vertices = new ArrayList<PVector>();
    public PrintSender(ArrayList<PVector> list, float len) {
      this.vertices = (ArrayList<PVector>)list.clone();
      this.length = len;
    }
    
    public void run() {
      try {
        PrintOffline();
        //PrintOnline();
      } catch(InterruptedException e) {
        PrintManager("ERROR: thread interrupted", 4);
      } catch(Exception e) {
        PrintManager("ERROR: when sending print commands", 4);
      }
    }
    
    // - after its finalized // speed is in mm/min
    private void PrintOffline() throws InterruptedException {
      PVector point, prev;
      float rate = (int(current_height/layer_height)==1?rate_first_layer:rate_normal);
      // runnning sum of the stroke
      float sum = 0;
      for(int i=0; i<vertices.size(); i++) {
        point = vertices.get(i);
        if(i > 0) {
          prev = vertices.get(i-1);
          sum += prev.dist(point); 
        }
        
        // last vertex -> move and extrude
        if(i==0) {
          SendMessage("/move", point.x, point.y, point.z, rate_high);
          SendMessage("/req/nozzle_pos");
          SendMessage("/extrude");
          continue;
        }
        // move to next point, material extrusion is calculated in Python side
        SendMessage("/move/extrude", point.x, point.y, point.z, rate); 
        
        // last vertex -> retract
        if(i==vertices.size()-1) {
          SendMessage("/retract");
          SendMessage("/req/nozzle_pos");
          continue;
        }
        
        // 1 second = rate/60 mm/sec 
        // sleep for one second in each "int(rate/60*1.2)" mm
        if(sum > int(rate/60*1.2))  {
          sum -= int(rate/60*1.2);
          Thread.sleep(1000);
        }
        else Thread.sleep(50);
      }
      println(length + " mm // " + rate + " mm/min // "+ nfc((length/rate)*60.,2)+" seconds");
    }
    
    // - in realtime
    private void PrintOnline() {
      int len = vertices.size();
      if (len == 1) {
        // extrude
      }
      else if(len > 1) {
        PVector pos = vertices.get(len-1);
        PVector ppos = vertices.get(len-2); // prevpos
        // calculate extrusion amount based on speed
      }
      // len == 0   . donothing
      // len == 1   . extrude material on the pos
      // len == ..  . // extrude amount and speed to next point
      // how to retract?
    } 
  }
}


// on current_height
void DrawMouseCursor() {
  if (select.calculatePickPoints(mouseX, (int)map(mouseY, 0, height, height, 0))) {
    PVector hit = new PVector();
    if (p.bb_current.CheckLineBox(select.ptStartPos, select.ptEndPos, hit)) {
      // hit is in world coordinates
      pushMatrix();
      pushStyle();
      translate(hit.x, hit.y, hit.z);
      noStroke();
      fill(0, 150);
      float r = CameraDistanceScaleDown()*3*b2w(nozzle_radius); 
      ellipse(0,0,r,r);
      popStyle();
      popMatrix();
    }
  }
}
