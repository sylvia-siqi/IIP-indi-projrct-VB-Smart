void initSerial() {
  //Initiate the serial port
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];//MAC: check the printed list
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear();           // flush the Serial buffer
}

ArrayList<PImage> screens=new ArrayList<PImage>(); 

void setupScreens() {
  screens.add(loadImage("Screen_0.jpg"));
  screens.add(loadImage("Screen_1.jpg"));
  screens.add(loadImage("Screen_2.jpg"));
  screens.add(loadImage("Screen_3.jpg"));
  screens.add(loadImage("Screen_4.jpg"));
}

 void setupSound() {  
  num17=minim.loadFile("num17.mp3");
  jumping=minim.loadFile("jumping.mp3");
  spiking=minim.loadFile("spiking.mp3");
  passing=minim.loadFile("passing.mp3");
  setting=minim.loadFile("setting.mp3");
  jumping.setGain(40);
  spiking.setGain(40);
  passing.setGain(40);
  setting.setGain(40);
  num17.setGain(40);
 }

void setupFont(){
  font = createFont("Inter-Regular.ttf",32); 
  largeFont=createFont("Inter-Regular.ttf",128);
  //font = loadFont("Arial-BoldMT-48.vlw"); 
  textFont(font);
  textSize(20);
}

//setup GUIs
void setupButton() {
  controlP5 = new ControlP5(this); 
  println("setting buttons");
  
  //Button indiTrack, teamTrack, addPlayer, end, save, clear, plus, minus;
  // create new buttons and set buttons' attributes
  indiTrack = controlP5.addButton("SoloTracking", 0, width/2-180, 350, 360, 76);
  indiTrack.setColorBackground(color(0, 75, 158));
  indiTrack.getCaptionLabel().setFont(font); 
  indiTrack.getCaptionLabel().setSize(34); 
  
  teamTrack = controlP5.addButton("Team Tracking", 0, width/2-180, 490, 360,76);
  teamTrack.setColorBackground(color(0, 75, 158));
  teamTrack.getCaptionLabel().setFont(font); 
  teamTrack.getCaptionLabel().setSize(34); 
  
  addPlayer = controlP5.addButton("Add Player", 0, width/2-180, 630, 360,76);
  addPlayer.setColorBackground(color(0, 75, 158));
  addPlayer.getCaptionLabel().setFont(font); 
  addPlayer.getCaptionLabel().setSize(34); 
  
  end = controlP5.addButton("Back to Home", 0,70,890, 320, 76); 
  end.getCaptionLabel().setSize(20);  
  end.setColorBackground(color(0, 168, 197));
  end.getCaptionLabel().setFont(font); 
 
  save = controlP5.addButton("Save Data", 0,560,890, 320, 70);
  save.getCaptionLabel().setSize(20);  
  save.setColorBackground(color(0, 75, 158));
  save.getCaptionLabel().setFont(font); 
  
  clear = controlP5.addButton("Clear Data", 0, 1024,890, 320, 70); 
  clear.getCaptionLabel().setSize(20);  
  clear.setColorBackground(color(0, 168, 197));
  clear.getCaptionLabel().setFont(font); 
  
  plus = controlP5.addButton("+", 0, 280,28, 36, 36); 
  plus.getCaptionLabel().setSize(20);  
  plus.setColorBackground(color(169, 144, 54));
  
  minus = controlP5.addButton("-", 0, 330,28, 36, 36); 
  minus.getCaptionLabel().setSize(20);  
  minus.setColorBackground(color(169, 144, 54));
  
  confirm = controlP5.addButton("Confirm",0, 560,890, 320, 70);
  confirm.getCaptionLabel().setFont(font); 
  confirm.getCaptionLabel().setSize(34);  
  confirm.setColorBackground(color(0, 75, 158));
  
  savePlayer = controlP5.addButton("Save Player", 0,560,890, 320, 70);
  savePlayer.getCaptionLabel().setFont(font); 
  savePlayer.getCaptionLabel().setSize(34); 
  savePlayer.setColorBackground(color(0, 75, 158));
  
}

//teamTrack, addPlayer, end, save, clear, plus, minus;
//write button function
void controlEvent(ControlEvent event) {
  println("event");
  if (event.getController().getName()=="SoloTracking") {
    screenState=1;
    soloPlayer=new Player("Siqi","S", "17",true);
    initSoloCSV();
    println("indi Pressed");
  }
  if (event.getController().getName()=="Team Tracking"){
    screenState=2;
    soloPlayer=new Player("Siqi","S", "17",false);
    initTeamCSV();
  }
    if (event.getController().getName()=="Add Player"){
    screenState=3;
  }
    
    if (event.getController().getName()=="Back to Home"){
      soloPlayer.clearStats();
      screenState=0;
  }
  
  if (event.getController().getName()=="Save Data"){
      screenState=4;
    }
      if (event.getController().getName()=="Clear Data"){
      
        soloPlayer.clearStats();
    }
      if (event.getController().getName()=="-"){
      activationThld = max(activationThld-10, 10);
      println("event");
    }
    
      if (event.getController().getName()=="+"){
      activationThld = min(activationThld+10, 300);
      println("event");
    }
      if (event.getController().getName()=="Confirm"){
        if(soloPlayer.isSolo)saveSoloCSV(dataSetName.Text, csvData);
        else saveTeamCSV(dataSetName.Text, csvData);
        dataSetName.Text="-";
        println("DATA SAVED");
        screenState=0;
        
    }
      if (event.getController().getName()=="Save Player"){
      screenState=0;
      println("player saved");
    }
}
