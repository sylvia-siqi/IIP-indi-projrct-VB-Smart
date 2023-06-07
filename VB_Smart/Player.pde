class Player {
  String name;
  String position;
  String playerNum;
  int spikeCount;
  int setCount;
  int recCount;
  int breakTimer;
  int audioBuffer;
 ArrayList<TEXTBOX> trackerTeam= new ArrayList<TEXTBOX>();
  String myPredict;
  String oldPredict;
  boolean isSolo;
  
  Player(String n, String p, String num, boolean state) {
     name=n;
     position=p;
     playerNum=num;
     spikeCount=0;
     setCount=0;
     recCount=0;
     isSolo=state;
     myPredict="";
     oldPredict="old";
     breakTimer=0;
     
     for(int i=0;i<17;i++ ){
       trackerTeam. add(new TEXTBOX(i*72+176, 433, 72,48,15));
     }
   }
   
   void clearStats(){
     spikeCount=0;
     setCount=0;
     recCount=0;
   }
   
   void readPrediction(){
     if(oldPredict!=myPredict){
       oldPredict=myPredict;
       num17.rewind();
       if(!isSolo)num17.play();
       if(myPredict.equals("spiking")){
         spiking.rewind();
         spiking.play();
      }
       if(myPredict.equals("setting")){
         
         setting.play();
         setting.rewind();
         
       }
       if(myPredict.equals("recieving")){
         passing.rewind();
         passing.play();
         
       }
       if(myPredict.equals("jumping")){
         jumping.rewind();
         jumping.play();
         
       }
       
       
     }
   }
   
   void updateStatsSolo(String pred){
     
     if(predUpdate){
     
     myPredict=pred;
     readPrediction();

     //else{
       //pred="spiking";
       if(pred.equals("spiking"))spikeCount++;
       if(pred.equals("setting"))setCount+=1;
       if(pred.equals("recieving"))recCount+=1;
       println(pred + "hi");
       //breakTimer=60;
     //}
      predUpdate=false;
     }
   }
   
    void updateStatsTeam(String prediction){
      if(predUpdate){
        myPredict=prediction;
      readPrediction();
      
     //if (breakTimer>0){
     //  breakTimer--;
     //  return;
     //}
     //else{
       if(prediction.equals("spiking")){
         if (trackerTeam.get(0).Text=="-") trackerTeam.get(0).Text=str(1);
         else trackerTeam.get(0).Text=str(int(trackerTeam.get(0).Text)+1);
       }
       if(prediction.equals("jumping")){
         if (trackerTeam.get(4).Text=="-") trackerTeam.get(4).Text=str(1);
         else trackerTeam.get(4).Text=str(int(trackerTeam.get(4).Text)+1);
       }
       if(prediction.equals("recieving")){
         if (trackerTeam.get(9).Text=="-") trackerTeam.get(9).Text=str(1);
         else trackerTeam.get(9).Text=str(int(trackerTeam.get(9).Text)+1);
       }
       if(prediction.equals("setting")){
         if (trackerTeam.get(13).Text=="-") trackerTeam.get(13).Text=str(1);
         else trackerTeam.get(13).Text=str(int(trackerTeam.get(13).Text)+1);
       }     
       //breakTimer=60;
     //}
     predUpdate=false;
     }
   }
   
   void drawDataSolo(){
     showInfo(name, 60,100);
     showInfo(name, 60,700);
     showInfo(str(recCount), 60,400);
     showInfo(str(setCount), 160,400);
     showInfo(str(spikeCount), 240,400);
    
   }
   
   
   void drawDataTeam(){
     if(myPredict.equals("spiking")){
       pushStyle();
       fill(255,20,20,50);
       rect(176,433,72*4,48);
     }
     if(myPredict.equals("jumping")){
       pushStyle();
       fill(50,50,255,50);
       rect(176+72*4,433,72*5,48);
     }
     if(myPredict.equals("recieving")){
       pushStyle();
       fill(50,255,50,50);
       rect(176+72*9,433,72*4,48);
     }
     if(myPredict.equals("setting")){
       pushStyle();
       fill(255,50,255,50);
       rect(176+72*13,433,72*4,48);
     }
     
     showInfoLarge(name, 15, 120,456);
     showInfoLarge(playerNum,15,54,456);

     for(TEXTBOX tb: trackerTeam){
       tb.DRAW();
     }
   }
   
   void addRowSolo(){
     TableRow newRow = csvData.addRow();
     newRow.setString("num", playerNum);
     newRow.setString("name", name);
     newRow.setString("pos", position);
     newRow.setString("tot_rec", str(recCount));
     newRow.setString("tot_set", str(setCount));
     newRow.setString("tot_spk", str(spikeCount));
   }
   
   void addRowTeam(){
     TableRow newRow = csvData.addRow();
     newRow.setString("num", playerNum);
     newRow.setString("name", name);
     newRow.setString("pos", position);
     
     for(int i=0; i<trackerTeam.size(); i++){
       newRow.setString(attrNamesTeam[i+3], trackerTeam.get(i).Text);
     }
     
   }
}
     
