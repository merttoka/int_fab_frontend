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
  
  
  public void run() {
    try {
      PrintStroke();
      //PrintOnline();
    } catch(InterruptedException e) {
      PrintManager("ERROR: thread interrupted", 4);
    } catch(Exception e) {
      PrintManager("ERROR: when sending print commands", 4);
    }
  }
  
  // - after its finalized // speed is in mm/min
  private void PrintStroke() throws InterruptedException {
    
    ArrayList<PVector> vertices = strokes.get(strokes.size()-1).vertices;
    float length = strokes.get(strokes.size()-1).length;
    
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
    //int len = vertices.size();
    //if (len == 1) {
      // extrude
    //}
    //else if(len > 1) {
    //  PVector pos = vertices.get(len-1);
    //  PVector ppos = vertices.get(len-2); // prevpos
      // calculate extrusion amount based on speed
    //}
    // len == 0   . donothing
    // len == 1   . extrude material on the pos
    // len == ..  . // extrude amount and speed to next point
    // how to retract?
  } 
 }
