//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************
import Weka4P.*;
Weka4P wp;

import papaya.*;
import processing.serial.*;
Serial port;

// font object to display text
PFont font; 
PFont largeFont;

int sensorNum = 3; 
int sensorIndex;
int streamSize = 500;
int[] rawData = new int[sensorNum];
float[][] sensorHist = new float[sensorNum][streamSize]; //history data to show

float[][] diffArray = new float[sensorNum][streamSize]; //diff calculation: substract

float[][] modeArray = new float[sensorNum][streamSize]; //To show activated or not
float[][] thldArray = new float[sensorNum][streamSize]; //diff calculation: substract
int activationThld = 180; //The diff threshold of activiation

int windowSize = 180; //The size of data window
float[][] windowArray = new float[sensorNum][windowSize]; //data window collection
boolean b_sampling = false; //flag to keep data collection non-preemptive
int sampleCnt = 0; //counter of samples

//Statistical Features
float[] windowM = new float[sensorNum]; //mean
float[] windowSD = new float[sensorNum]; //standard deviation
boolean bShowInfo = true;

//=============================================

//my stuff
//data
Table csvData;
boolean b_saveCSV = false;
String[] attrNamesTeam={"num", "name", "pos",
                        "tot_spk", "kill_spk", "erorr_spk", "attempt_spk", 
                        "tot_j","sb_j", "blcok_j","touch_j","be_j",
                        "tot_rec","3_rec","2_rec","1_rec",
                        "tot_set","3_set","2_set","1_set"} ;                       
String[] attrNamesSolo={"num", "name", "pos",
                        "tot_spk","tot_rec","tot_set"};
TEXTBOX dataSetName =  new TEXTBOX(90,440,1260,138,48); 
TEXTBOX playerName_temp= new TEXTBOX(90,186,1260,138,48);
TEXTBOX playerNum_temp=new TEXTBOX(556,418,324,138,48);
TEXTBOX playerPos_temp=new TEXTBOX(556,648,324,138,48);
ArrayList<TEXTBOX> textboxes = new ArrayList<TEXTBOX>();


String prediction="setting";
Player soloPlayer;
boolean predUpdate=false;

//import sound library
import ddf.minim.ugens.*;
import ddf.minim.*;
Minim minim=new Minim(this);
//objects to manipulate sounds
AudioPlayer num17, passing, setting, spiking, jumping;

//import GUI library;
import controlP5.*;
import controlP5.Button;
ControlP5 controlP5;
Button indiTrack, teamTrack, addPlayer, savePlayer, end, save, clear, confirm, plus, minus, confirmAdd;
ArrayList<Button> buttons= new ArrayList<Button>(); 

int screenState=0;
int HOME=0;
int INDIVIDUAL=1;
int TEAM=2;
int TYPE_PLAYER_INFO=3;
int TYPE_FILE_NAME=4;




 
void setup() {
  size(1440, 1040, P2D);
  
  frameRate(60);
  wp = new Weka4P(this);
  initSerial();
  wp.loadTrainARFF("VBTrain_5.arff");//load a ARFF dataset
  wp.loadModel("LinearSVC.model"); //load a pretrained model.
  
  //my stuff
  soloPlayer=new Player("Siqi","S", "17",true);
  setupFont();
  setupScreens();
  setupButton();
  setupSound();
  textboxes.add(playerName_temp);
  textboxes.add(playerNum_temp);
  textboxes.add(playerPos_temp);

}

void draw() {
  background(225);
  

  float[] X = {windowM[0], windowSD[0],windowM[1], windowSD[1],windowM[2], windowSD[2]}; 
  String Y = wp.getPrediction(X);
  prediction=Y;
  drawUI();
  
  
    if (screenState==1)soloPlayer.updateStatsSolo(prediction);
    if (screenState==2)soloPlayer.updateStatsTeam(prediction);
   
    
  if (b_saveCSV) {
    if(screenState==1) saveSoloCSV(dataSetName.Text, csvData);
    else if(screenState==2)saveTeamCSV(dataSetName.Text, csvData);

    //saveARFF(dataSetName, csvData);
    b_saveCSV = false;
  }
   //showInfo(Y, 750, 500);
}

void mousePressed() {
  if(screenState==3){
   for (TEXTBOX t : textboxes) {
      t.PRESSED(mouseX, mouseY);
   }
  }
  else if(screenState==4){
    dataSetName.PRESSED(mouseX, mouseY);
  }
  else if (screenState==2){
    for (TEXTBOX t : soloPlayer.trackerTeam) {
      t.PRESSED(mouseX, mouseY);
    }
  }
}


void keyPressed() {
  if (screenState==3){
   for (TEXTBOX t : textboxes) {
      t.KEYPRESSED(key, (int)keyCode);}
  }
  else if (screenState==4){
     dataSetName.KEYPRESSED(key, (int)keyCode);
   }
   else if (screenState==2){
   for (TEXTBOX t : soloPlayer.trackerTeam) {
      t.KEYPRESSED(key, (int)keyCode);
    }
  }
  if (key == 'A' || key == 'a') {
    activationThld = min(activationThld+5, 300);
  }
  if (key == 'Z' || key == 'z') {
    activationThld = max(activationThld-5, 10);
  }
}


void serialEvent(Serial port) {   
  String inData = port.readStringUntil('\n');  // read the serial string until seeing a carriage return
  if (inData.charAt(0) == 'A') sensorIndex=0;
  else if (inData.charAt(0) == 'B')sensorIndex=1;
  else if (inData.charAt(0) == 'C')sensorIndex=2;
  else return;

    rawData[sensorIndex] = int(trim(inData.substring(1)));
    appendArray( (sensorHist[sensorIndex]), map(rawData[sensorIndex], 0, 1023, 0, height)); //store the data to history (for visualization)
    //calculating diff
    float diff = abs( (sensorHist[sensorIndex])[0] - (sensorHist[sensorIndex])[1]); //absolute diff
    appendArray(diffArray[sensorIndex], diff);
    appendArray(thldArray[sensorIndex], activationThld);
    //test activation threshold
    if (diff>activationThld) { 
      if (b_sampling == false) { //if not sampling
         
         appendArray(modeArray[0], 2);
         appendArray(modeArray[1], 2);
         appendArray(modeArray[2], 2);//activate when the absolute diff is beyond the activationThld
         
         b_sampling = true; //do sampling
         sampleCnt = 0; //reset the counter
        for (int i = 0; i < sensorNum; i++) {
          for (int j = 0; j < windowSize; j++) {
            (windowArray[i])[j] = 0; //reset the window
          }
        }
      }
    } else { 
      if (b_sampling == true) {
        
        appendArray(modeArray[0], 3);
        appendArray(modeArray[1], 3);
        appendArray(modeArray[2], 3);
      }//otherwise, deactivate.
      else {
        appendArray(modeArray[0], -1);
        appendArray(modeArray[1], -1);
        appendArray(modeArray[2], -1);} //otherwise, deactivate.
        
        
    }

    if (b_sampling == true) {
      appendArray(windowArray[sensorIndex], rawData[sensorIndex]); //store the windowed data to history (for visualization)
      ++sampleCnt;
      if (sampleCnt == windowSize) {
        
        predUpdate=true;
        
        windowM[0]  = Descriptive.mean(windowArray[0]); //mean
        windowSD[0] = Descriptive.std(windowArray[0], true); //standard deviation
        windowM[1]  = Descriptive.mean(windowArray[1]); //mean
        windowSD[1] = Descriptive.std(windowArray[1], true); //standard deviation
        windowM[2]  = Descriptive.mean(windowArray[2]); //mean
        windowSD[2] = Descriptive.std(windowArray[2], true); //standard deviation
        b_sampling = false; //stop sampling if the counter is equal to the window size
      }
    }
}
