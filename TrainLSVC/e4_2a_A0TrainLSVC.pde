//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import Weka4P.*;
Weka4P wp;

import papaya.*;
import processing.serial.*;
Serial port; 

int sensorNum = 3; 
int sensorIndex;
int streamSize = 500;
int[] rawData = new int[sensorNum];
float[][] sensorHist = new float[sensorNum][streamSize]; //history data to show

float[][] diffArray = new float[sensorNum][streamSize]; //diff calculation: substract

float[][] modeArray = new float[sensorNum][streamSize]; //To show activated or not
float[][] thldArray = new float[sensorNum][streamSize]; //diff calculation: substract
int activationThld = 20; //The diff threshold of activiation

int windowSize = 20; //The size of data window
float[][] windowArray = new float[sensorNum][windowSize]; //data window collection
boolean b_sampling = false; //flag to keep data collection non-preemptive
int sampleCnt = 0; //counter of samples

//Save
Table csvData;
boolean b_saveCSV = false;
String dataSetName = "VBTrain"; 
String[] attrNames = new String[]{"m_x", "sd_x","m_y", "sd_y","m_z", "sd_z", "label"};
boolean[] attrIsNominal = new boolean[]{false, false, false, false,false, false,true};
int labelIndex = 0;

float m_x = -1;
float sd_x = -1;
float m_y = -1;
float sd_y = -1;
float m_z = -1;
float sd_z = -1;
boolean bShowInfo = true;

void setup() {
  size(500, 500, P2D);
  frameRate(60);
  wp = new Weka4P(this);
  
  initSerial();
  wp.loadTrainARFF("VBTrain.arff"); //load a ARFF dataset
  wp.trainLinearSVC(16);             //train a SV classifier
  wp.setModelDrawing(2);         //set the model visualization (for 2D features) with unit 2
  wp.evaluateTrainSet(5, false, true);  //5-fold cross validation (fold=5, isRegression=false, showEvalDetails=true)
  wp.saveModel("LinearSVC.model"); //save the model
}

void draw() {
//  wp.drawModel(0, 0); //draw the model visualization (for 2D features)
  //wp.drawDataPoints(wp.train); //draw the datapoints
 // float[] X = {m_x, sd_x}; 
 // String Y = wp.getPrediction(X);
 // wp.drawPrediction(X, Y); //draw the prediction
  if (bShowInfo) {
    showInfo("Thld: "+activationThld, 20, height-40);
    showInfo("([A]:+/[Z]:-)", 20, height-20);
    
  }
}

void keyPressed() {
  if (key == 'A' || key == 'a') {
    activationThld = min(activationThld+5, 100);
  }
  if (key == 'Z' || key == 'z') {
    activationThld = max(activationThld-5, 10);
  }
  if (key == 'I' || key == 'i') {
    bShowInfo = (bShowInfo? false:true);
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
      appendArray(modeArray[0], 2);
      appendArray(modeArray[1], 2);
      appendArray(modeArray[2], 2);//activate when the absolute diff is beyond the activationThld
      if (b_sampling == false) { //if not sampling
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
                m_x = Descriptive.mean(windowArray[0]); //mean
        sd_x = Descriptive.std(windowArray[0], true); //standard deviation
                m_y = Descriptive.mean(windowArray[1]); //mean
        sd_y = Descriptive.std(windowArray[1], true); //standard deviation
                m_z = Descriptive.mean(windowArray[2]); //mean
        sd_z = Descriptive.std(windowArray[2], true); //standard deviation
        TableRow newRow = csvData.addRow();
        newRow.setFloat("m_x", m_x);
        newRow.setFloat("sd_x", sd_x);
        newRow.setFloat("m_y", m_y);
        newRow.setFloat("sd_y", sd_y);
        newRow.setFloat("m_z", m_z);
        newRow.setFloat("sd_z", sd_z);
        newRow.setString("label", getMeaningfulLabel(labelIndex)); //newRow.setString("label", getCharFromInteger(labelIndex));
        println(csvData.getRowCount());
        b_sampling = false; //stop sampling if the counter is equal to the window size
      }
    }
}

//Append a value to a float[] array.
float[] appendArray (float[] _array, float _val) {
  float[] array = _array;
  float[] tempArray = new float[_array.length-1];
  arrayCopy(array, tempArray, tempArray.length);
  array[0] = _val;
  arrayCopy(tempArray, 0, array, 1, tempArray.length);
  return array;
}

void initSerial() {
  //Initiate the serial port
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];//MAC: check the printed list
  //String portName = Serial.list()[9];//WINDOWS: check the printed list
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear();           // flush the Serial buffer
}
