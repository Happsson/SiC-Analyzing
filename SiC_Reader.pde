/*
Auth. Hannes Paulsson
*/


import processing.serial.*;
import java.awt.event.KeyEvent;
import java.io.IOException;
import java.util.Arrays;

int[] testArray = {
      //Testet skickar samma värden som DACen är inställd pa. 
     0x880F070A,     //  b1 = 0x88 (136, längden), b2+b3 = 0x0F07, b4 = 0x02 (första delen av byte nästa värde)
     0x2E055500,     //  b1 = 2E (forts pa förra), b2+b3 = 0x0555, b4 = 0x00 ( ----||----)
     0xF807FF04,      //  b1 = F8, b2 = EE (hittepa, chekcsum). Resten nollor.
     0x550FFF0a,
     0x220bbbee
};
Serial mPort;

PFont din;

float temp1 = 0, temp2 = 0, temp3 = 0, temp4 = 0;

ArrayList<Integer> message; //Lista där inkommande byte sparas. Sparas i form av int, fast endast en en en byte används. 
ArrayList<Integer> sensorValues; //Konverterade värden fran avläsningar.

int checksum;

boolean connected;

String[] names = {
 "T1",
 "Ube 3.1V",
 "Vrb 3.1V",
 "Vrc 3.1V",
  "T2",
 "Ube 2.1V",
 "Vrb 2.1V",
 "Vrc 2.1V",
  "T3",
 "Ube 1.1V",
 "Vrb 1.1V",
 "Vrc 1.1V",
  "T4",
 "Ube 0.5V",
 "Vrb 0.5V",
 "Vrc 0.5V"
};

String serialArray = "";
 
 
void setup()  { 
  size(1000, 600);
  smooth();
  fill(0);
  colorMode(RGB, 1);
  
  for(int i = 0; i < Serial.list().length; i++){
    serialArray += "["+i+"]: " + Serial.list()[i] + "\n";
  }
  
  message = new ArrayList<Integer>();
  sensorValues = new ArrayList<Integer>();
  
  din = createFont("din.ttf", 128); //Ladda font.
  textFont(din); //sätt font.
} 


 void serialEvent(Serial mPort){

   if(message.size() > 0){
    if(message.size() > 33){
      message.clear();
    }
   }
   
   message.add(mPort.read());

   byte[] vals = new byte[message.size()];
   for(int i = 0; i < message.size();i++){
     byte b = (byte) (message.get(i) & 0xFF);
    vals[i] = b; 
   }
   println(byteArrayToHex(vals));
   println("len: " + vals.length);
}


 
public static String byteArrayToHex(byte[] a) {
   StringBuilder sb = new StringBuilder(a.length * 2);
   for(byte b: a)
      sb.append(String.format("%02x", b & 0xff));
   return sb.toString();
}
 
 void convertReads(){
   
   sensorValues.clear();
   
  //first, find the checksum (last few ints mights be zero)
  int end = message.size();
  if(end < 2){
   println("Size < 2");
   return;
  }
  if(message.get(end-1) == 0){
    while(message.get(--end) != 0){}
      
    //Get checksum
    checksum = message.get(end--);
  
  }else{
   checksum = message.get(--end); 
  }
  
  

  
  //Start adding bytes together
  for(int i = 1; i < end-1; i+=2){ //Skip first byte, only contains size info
    sensorValues.add((message.get(i)|((message.get(i+1) << 8) & 0xFF00))); //Bit bang it
  }
  //printArray(sensorValues);
  
 }
 
void draw()  { 

  background(0.388,0.502,0.616);
  if(!connected){
   textSize(48);
   fill(1,1,1,1);
   text("Please select port (enter on keyboard)", 200,100);
   textSize(18);
   
   
   text(serialArray, 200,200);
  }else{
  //System.out.println("size: " + message.size());
  if(message.size() > 0){

      convertReads(); 
       if( sensorValues.size() > 13){

       }
    
    //printArray(message);
  }
  //drawTexts();
  
  drawBarGraph();
  }
} 

void drawBarGraph(){
 pushMatrix();
 translate(-20,height-120);
 drawGrid();
 
 
 noStroke();
 for(int i = 0; i < sensorValues.size(); i++){
   fill(0.202,0.188,0.216);
   rect((i*45)+130, 0, 30, -((sensorValues.get(i)/4096f)*330f));
   fill(1,1,1,1);
   String val = String.format("%.02f", ((sensorValues.get(i)/4096f)*3.3f));
   String t = "";
       

   if(sensorValues.size() > 12) {
         temp1 = (float) ((8.194f - Math.sqrt(((-8.194f) * (-8.194f)) + 4f * 0.00262f * (1324 - ((sensorValues.get(0)/4095f)*3.3f*1000))))/(float) (2f*-0.00262)) + 30f; 
         temp2 = (float) ((8.194f - Math.sqrt(((-8.194f) * (-8.194f)) + 4f * 0.00262f * (1324 - ((sensorValues.get(4)/4095f)*3.3f*1000))))/(float) (2f*-0.00262)) + 30f;
         temp3 = (float) ((8.194f - Math.sqrt(((-8.194f) * (-8.194f)) + 4f * 0.00262f * (1324 - ((sensorValues.get(8)/4095f)*3.3f*1000))))/(float) (2f*-0.00262)) + 30f;
         temp4 = (float) ((8.194f - Math.sqrt(((-8.194f) * (-8.194f)) + 4f * 0.00262f * (1324 - ((sensorValues.get(12)/4095f)*3.3f*1000))))/(float) (2f*-0.00262)) + 30f;
        
       }
   if(i == 0){
     
     text((temp1 + " C"), (i*45)+135, -((sensorValues.get(i)/4096f)*330f)-5);
   }else if(i == 4){
     text((temp2 + " C"), (i*45)+135, -((sensorValues.get(i)/4096f)*330f)-5);
   }else if(i == 8){
     text((temp3 + " C"), (i*45)+135, -((sensorValues.get(i)/4096f)*330f)-5);
   }else if(i == 12){
    text((temp4 + " C"), (i*45)+135, -((sensorValues.get(i)/4096f)*330f)-5); 
   }else{
     
     text((val  + " V"), (i*45)+135, -((sensorValues.get(i)/4096f)*330f)-5);
   }
   text(names[i], (i*45)+135, 20 + (i%2)*20);
   if(i%2 == 1) text("|", (i*45)+140, 20);
 }
 
 popMatrix();
 
}

void drawGrid(){
 
 strokeWeight(4);
 stroke(1,1,1, 1);
 line(100,0,100,-330); //Y-axis
 line(100,0,900,0);    //X-axis
 strokeWeight(1);
 
 for(int i = 0; i <= 33; i++){
   if(i%10==0){
    stroke(1,1,1,1);
   }else{
     stroke(1,1,1,0.5);
   }
  line(100,-(i*10), 900, -(i*10)); 
 }
 
 fill(1,1,1);
 textSize(24);
 text("Volt read", 60, -340);
 text("ADC input", 870, 25);
 text("Test program for SiC in space experiments", 400, -450);
 textSize(18);
 text("Generated: " + day() + " / " + month() + " / " + year(), 800, 70);
 text("Press 'S' to save image file", 500, 70);
 text("3.0", 70, -295);
 text("2.0", 70, -195);
 text("1.0", 70, -95);
 text("0.0", 70, 5);
  
}


//Not used
void drawTexts(){
  pushMatrix();
  translate(0, 0, 0);
  fill(1,1,1);
  String s = "";
  textSize(18);
  for(Integer i : sensorValues){
    s += "Raw Val: " + i + " volt: " + ((i/4096f)*3.3f) + "\n";
  }
  text(s, 105,98);

  popMatrix();
}

void keyPressed(){
  
  if(((int) key >= 48 && (int) key <= 57)){
    int val = key - 48;
    if(val < Serial.list().length){
      serialArray = "Connecting..";
     tryConnect(val); 
    }else{
     println("invalid choice"); 
    }
  }
  switch(key){
   case  's':
    saveFrame("SiC_Experiment_####.png"); 
    break;
  }
 
  
}
void tryConnect(int port){
  
  
  if(mPort != null){
      mPort.stop(); //Om redan connectad, avsluta innan vi connectar igen 
  }
  try{
    mPort = new Serial(this, Serial.list()[port], 9600); //Baud 9600
    connected = true;
  }catch(Exception e){
    connected = false;
  }
  
}