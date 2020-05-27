// 
// Console print manager
// 'level' is importance of the message: [0, 4]
void PrintManager(String message, int level) {
  level = constrain(level, 0, 4);
  String prefix = ""; 
  switch(level) {
    case 4:
      prefix = "#####\t";
      break;
    case 3:
      prefix = " ####\t";
      break;
    case 2:
      prefix = "  ###\t";
      break;
    case 1:
      prefix = "   ##\t";
      break;
    case 0:
      prefix = "    #\t";
      break;
    default:
      break;
  }
  
  String ts = hour()+":"+minute()+":"+second()+" "+month()+"/"+day();
  
  println(prefix+" "+message+" ("+ts+")");
}
