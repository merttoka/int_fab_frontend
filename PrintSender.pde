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
        float len = 0;
        if(i < strokes.size()-1) {
          PVector p0 = strokes.get(i).vertices.get(strokes.get(i).vertices.size()-1); // last vertex 
          PVector p1 = strokes.get(i+1).vertices.get(0);                              // first vertex of next
          
          len = p0.dist(p1);
        }
        else   len = 0;
        
        println(i, strokes.get(i).GetHeight(), strokes.get(i).isFlat, strokes.get(i).length, len);
        PrintStroke(strokes.get(i).vertices, 
                    strokes.get(i).length, len);
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
                  strokes.get(strokes.size()-1).length, 0); 
    } catch(InterruptedException e) {
      PrintManager("ERROR: thread interrupted", 4);
    } catch(Exception e) {
      PrintManager("ERROR: when sending print commands", 4);
    }
  }
  
  // - in realtime
  private void PrintStroke(ArrayList<PVector> vertices, float length, float nextlen) throws InterruptedException {
    PVector point, prev;
    float rate = (int(p.current_height/p.layer_height)==1?p.rate_first_layer:p.rate_normal);
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
        SendMessage("/move", point.x, point.y, point.z, p.rate_high);
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
      if(sum > int(rate/60))  {
        sum -= int(rate/60);
        Thread.sleep(1000);
      }
      else Thread.sleep(50);
    }
    println(length + " mm // " + rate + " mm/min // "+ nfc((length/rate)*60.,2)+" seconds");
    
    Thread.sleep((long)((nextlen/rate)*60.*1000.));
  } 
 }
