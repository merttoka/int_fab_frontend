
//
class StrokeManager {
  
  //
  ArrayList<Stroke> strokes = new ArrayList<Stroke>();
  
  //
  int selected_count = 0;
  
  //
  public StrokeManager() {}
  
  //
  public void DrawAll() {
    pushStyle();
    hint(ENABLE_STROKE_PERSPECTIVE);
    for(int i=0; i < strokes.size(); i++) {
      Stroke s = strokes.get(i);  
      float h = s.GetHeight(); // returns 0 when !isFlat
      if(!s.isSelected) s.c = color(s.col_fil, (IsCloseToCurrentLayer(h) ? 255 : 50));
      else              s.c = color(selected_color, (IsCloseToCurrentLayer(h) ? 255 : 100));
      s.stroke_weight = CameraDistanceScaleDown();
      s.Draw();
      if(__isDebug) for(int j=0; j<s.bb.size(); j++) s.bb.get(j).Draw();
    }
    hint(DISABLE_STROKE_PERSPECTIVE);
    popStyle();
  } 
  
  ////////////////
  //
  public void ClearSelectedStrokes() {
    // sort by selection, selected items are in the beginnning
    Collections.sort(strokes, new SortBySelection());
    println(strokes.get(0).isSelected, strokes.get(strokes.size()-1).isSelected);
    println(strokes.size());
    
    //List removed = new ArrayList(sublist); 
    while(selected_count>0) {
      strokes.remove(0);
      selected_count--;
    }

    println(strokes.size());
  }
  
  // BRUSH STROKE FUNCTIONS
  /////////////////////
  //
  // onpress
  Stroke temp=null;
  public void StartStroke() {
    temp = new Stroke();
    temp.isFlat = true; // its bound to the plane in this mode
    strokes.add(temp);
  }
  // ondrag
  public void CollectStroke() {
    if(temp != null && strokes.size() >= 1) {
      Stroke s = strokes.get(strokes.size()-1);
      PVector wc = p.MousePointInWorldCoordinates();
      if (wc!=null && !s.isClosed)   s.AddVertex(w2b(wc.x), w2b(wc.y), p.current_height);
    }
  }
  // onrelease
  public void EndStroke() {
    // actual printing if draw mode is immediate
    if(temp != null && __drawMode) (new PrintSender(temp)).start();
    
    if (temp.vertices.size() == 0) // if its just a click, delete the last stroke
      strokes.remove(strokes.size()-1);  
    temp = null; // release temp
  }
  ////////////////////////////////////////////// 
  
  //
  // generates count many interpolated strokes in between two strokes, -1 fluds the middle of two curves
  public void Interpolate(Stroke s0, Stroke s1, int count) {
    float h1 = s0.GetHeight();
    float h2 = s1.GetHeight();
    
    // if count is -1, assign count to maximum layers in between (ideally solid)
    if(count == -1) {
      float[] min = new float[] {1000, 0, 0}; // min_dist, idx_i, idx_j
      for(int i = 0; i<s0.vertices.size();i++) {
        for(int j = 0; j<s1.vertices.size(); j++) {
          float d = s0.vertices.get(i).dist(s1.vertices.get(j));
          if(d < min[0]) {
            min[0] = d;   min[1] = i;   min[2] = j;
          }
        }  
      }
      count = int(min[0]/p.layer_height);
    }
    
    // check for maximum amounth of layers
    int maxcount = int(abs(h1-h2)/p.layer_height);
    if( maxcount>1 &&  count>maxcount ) count = maxcount;
    
    int l1 = s0.vertices.size();
    int l2 = s1.vertices.size();
    int diff = abs(l1-l2); // difference in vertex count
    for(int i=1; i<=count; i++){
      // rows normalized [0,1]
      float __i = i/float(count+1);
      
      Stroke new_stroke = new Stroke();  
      new_stroke.isFlat = false;                // mark it as !flat, check after creating the vertices
      
      for(int j = 0; j < min(l1, l2)+int(diff*__i); j++) {
        // cols normalized [0,1] -- to select which coordinate to use
        float __j = j/float(min(l1, l2)+int(diff*__i)); 
        
        PVector p1 = s0.vertices.get(int(__j*l1));
        PVector p2 = s1.vertices.get(int(__j*l2));
        
        PVector v = PVector.add(PVector.mult(p1,__i), PVector.mult(p2,(1-__i)));
        
        // snap z coordinate to closes layer
        v.z = round(v.z/p.layer_height) * p.layer_height;
        
        new_stroke.AddVertex(v.x,v.y,v.z);
      }
      new_stroke.UpdateIsFlat();                // update flatness
      selected_count = new_stroke.Select(true, selected_count);  // mark it selected after interpolation
      strokes.add(new_stroke);
    }
  }
  
  
  // SELECT STROKE FUNCTIONS
  /////////////////////
  //
  // Updates the selected strokes on click
  private int fail_count = 0;
  private int fail_count_max = 2;
  public void UpdateStrokeSelection() {
    for(int i=0; i<strokes.size();i++) {
      Stroke s = strokes.get(i);
      PVector wc = s.IsMouseHit();
      // hit
      if (wc!=null) {
        fail_count=0;
        
        //if(IsCloseToCurrentLayer(wc.z))
        if(s.isSelected) selected_count = s.Select(false, selected_count);
        else             selected_count = s.Select(true, selected_count);
      }  
    }
    // clear all strokes
    if(fail_count < fail_count_max) fail_count++;
    else                            {ClearSelection(); fail_count=0;}
  }
  public void ClearSelection() {
    for(int i=0; i<strokes.size();i++)   selected_count = strokes.get(i).Select(false, selected_count);
  }
  public void SelectAll() {
    for(int i=0; i<strokes.size();i++)   selected_count = strokes.get(i).Select(true, selected_count);
  }
  ////////////////////////////////
  
  
  ////////////////////////////////////////////////////////////
  //
  private boolean IsCloseToCurrentLayer(float h) {
    return (h>(p.current_height-p.layer_height/2) && h<(p.current_height+p.layer_height/2));
  }
}
