import java.util.*;

PrintSender sender = null;

// 
// class to send messages on a separete thread by slowing down the rate
public class PrintSender extends Thread {
  Printer printer = p; // global
  
  
  //
  ArrayList<Stroke> strokes;
  public PrintSender(ArrayList<Stroke> s) {
    this.strokes = (ArrayList<Stroke>)s.clone();
  }
  public PrintSender(Stroke s) {
    strokes = new ArrayList<Stroke>();
    this.strokes.add(s);
  }
  
  // 
  public void run() {
      if(__drawMode)  PrintLastStroke();
      else            PrintAllStrokes();
      //PrintOnline();
  }
  
  // - after its finalized // speed is in mm/min
  private void PrintAllStrokes()  {
    try {
      Collections.sort(strokes, new SortbyLayerHeight());
      
      for(int i = 0; i<strokes.size(); i++) {
        ArrayList<PVector> _s = (ArrayList<PVector>)strokes.get(i).vertices.clone();
        if(i%2==1) Collections.reverse(_s); 
        PrintStroke(_s, 
                    strokes.get(i).length);
      }
    } 
    catch(InterruptedException e) {
      PrintManager("ERROR: thread interrupted", 4);
    } 
    catch(Exception e) {
      PrintManager("ERROR: when sending print commands", 4);
    }
  }
  
  // - after its finalized // speed is in mm/min
  private void PrintLastStroke()  {
    try {
      PrintStroke(strokes.get(strokes.size()-1).vertices, 
                  strokes.get(strokes.size()-1).length); 
    } catch(InterruptedException e) {
      PrintManager("ERROR: thread interrupted", 4);
    } catch(Exception e) {
      PrintManager("ERROR: when sending print commands", 4);
    }
  }
  
  // - in realtime
  private void PrintStroke(ArrayList<PVector> vertices, float length) throws InterruptedException {
    PVector point, prev;
    float rate = (int(p.current_height/p.layer_height)==1?p.rate_first_layer:p.rate_normal);
    
    // send the first point first, wait for the nozzle to come there
    point = vertices.get(0);
    SendMessage("/move", point.x, point.y, point.z, p.rate_high);
    SendMessage("/req/nozzle_pos");
    float diff = PVector.dist(p.nozzle_pos, point);
    do{
      diff = PVector.dist(p.nozzle_pos, point);
      Thread.sleep(40); // respond realtime
    }while(diff > p.layer_height); // wait while the nozzle is traveling
    
    ///// we can start the print
    // then send one vertex and wait for slightly less than the "len / (rate/60) * 1000" miliseconds
    if(length > 0 && vertices.size() > 1) {
      SendMessage("/extrude");
      
      // runnning sum of the stroke
      for(int i=1; i<vertices.size(); i++) {
        prev = point;
        point = vertices.get(i);
        float _len = prev.dist(point); 
        
        // update nozzle_pos (kept in processing, not actual nozzle_pos)
        p.nozzle_pos_0 = point;
        
        // move to next point, material extrusion is calculated in Python side
        SendMessage("/move/extrude", point.x, point.y, point.z, rate);
        
        // last vertex -> retract
        if(i==vertices.size()-1) {
          SendMessage("/retract");
          SendMessage("/req/nozzle_pos");
        }
        
        println("sent="+i+"/"+vertices.size(), point);
        
        // 1 second = rate/60 mm/sec 
        // sleep for one second in each "int(rate/60)" mm
        long sleep = (long)(_len/(rate/60) * 1000);
        Thread.sleep(sleep-1);  
    }
    println("Stroke: len= "+ length + " mm, speed= " + rate + " mm/min, time= "+ nfc((length/rate)*60.,2)+" seconds");
  } 
 }
}
