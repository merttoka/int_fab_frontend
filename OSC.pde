/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

//
// Initializes the OscP5
void InitOSC(int listen_port, 
             String send_address, int send_port) {
  oscP5 = new OscP5(this, listen_port);
  
  myRemoteLocation = new NetAddress(send_address, send_port);
}  

// 
// Send message to remote location
void SendMessage(String name, float x, float y, float z) {
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage(name);
  myMessage.add(x);
  myMessage.add(y);
  myMessage.add(z);

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
  
  PrintManager("Message sent=["+x+", "+y+", "+z+"]", 2);
}
void SendMessage(String name) {
  OscMessage myMessage = new OscMessage(name);
  oscP5.send(myMessage, myRemoteLocation); 
  
  PrintManager(name+" sent", 2);
}

//
// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage _m) {
  if(_m.checkAddrPattern("/test_py")){
    PrintManager("Received osc message: " + _m.typetag(), 2);
    
    if(_m.checkTypetag("fff")) {
      float x = _m.get(0).floatValue(),
            y = _m.get(1).floatValue(),
            z = _m.get(2).floatValue();
      
      PrintManager("Received osc message = ["+x+", "+y+", "+z+"]", 0);
      return;
    }  
  }
}
