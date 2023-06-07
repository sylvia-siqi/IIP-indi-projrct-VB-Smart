void drawUI(){
  //indiTrack.hide(); teamTrack.hide();addPlayer.hide();savePlayer.hide(); confirm.hide();end.hide();save.hide();clear.hide();plus.hide();minus.hide();
  image(screens.get(screenState),0,0);
  if(screenState==HOME){
    indiTrack.show();teamTrack.show(); addPlayer.show();
    savePlayer.hide(); confirm.hide();end.hide();save.hide();clear.hide();plus.hide();minus.hide();
  }
  if(screenState==1||screenState==2){
    plus.show();minus.show(); end.show();save.show();clear.show();
    indiTrack.hide(); teamTrack.hide();addPlayer.hide();savePlayer.hide(); confirm.hide();
    
    showInfo("Action Sensitivity: "+activationThld, 50, 60);
    
    if(screenState==1){
      showInfoLarge(soloPlayer.name,64, width/2,100);
      showInfoLarge(str(soloPlayer.recCount),128, 270,300);
      showInfoLarge(str(soloPlayer.setCount),128, 710,300);
      showInfoLarge(str(soloPlayer.spikeCount),128, 1150,300);
      showInfoLarge(soloPlayer.myPredict,64,710, 700);
    }
    if(screenState==2){
      soloPlayer.drawDataTeam();
    }
    
  }
  if(screenState==3){
    end.show();savePlayer.show();
    indiTrack.hide(); teamTrack.hide();addPlayer.hide();confirm.hide();save.hide();clear.hide();plus.hide();minus.hide();
    playerName_temp.DRAW();
    playerNum_temp.DRAW();
    playerPos_temp.DRAW();
  }
  if(screenState==4){
    end.show();confirm.show();
    dataSetName.DRAW();
    indiTrack.hide(); teamTrack.hide();addPlayer.hide();savePlayer.hide();save.hide();clear.hide();plus.hide();minus.hide();
  }
  
}


void drawCount(String num, int fontSize, float x, float y){
   pushStyle();
  textAlign(CENTER,CENTER);
  fill(color(0, 75, 158));
  textSize(fontSize);
  text(num, x, y);
  popStyle();
}


//Draw text info
//showInfo(String s, int v, float x, float y)
void showInfo(String s, float x, float y) { 
  pushStyle();
  textAlign(LEFT,BOTTOM);
  fill(0);
  textSize(20);
  text(s, x, y);
  popStyle();
}
void showInfoLarge(String s, int size, float x, float y) { 
  pushStyle();
  fill(color(0, 75, 158));
  textFont(largeFont);
  textAlign(CENTER,CENTER);
  textSize(size);
  text(s, x, y);
  popStyle();
}

//Draw a bar graph to visualize the modeArray
//barGraph(float[] data, float x, float y, float width, float height)
void barGraph(float[] data, float _x, float _y, float _w, float _h) {
  color colors[] = {
    color(255, 0, 0), color(0), color(0, 0, 255), color(255, 0, 255), 
    color(255, 0, 255)
  };
  pushStyle();
  noStroke();
  float delta = _w / data.length;
  for (int p = 0; p < data.length; p++) {
    float i = data[p];
    int cIndex = min((int) i, colors.length-1);
    if (i<0) fill(255, 100);
    else fill(colors[cIndex], 100);
    float h = map(0, -1, 0, 0, _h);
    rect(_x, _y-h, delta, h);
    _x = _x + delta;
  }
  popStyle();
}


//Draw a line graph to visualize the sensor stream
//lineGraph(float[] data, float lowerbound, float upperbound, float x, float y, float width, float height, int _index)  
void lineGraph(float[] data, float _l, float _u, float _x, float _y, float _w, float _h, int _index) {
  color colors[] = {
    color(255, 0, 0), color(0), color(0, 0, 255), color(255, 0, 255), 
    color(255, 0, 255)
  };
  int index = min(max(_index, 0), colors.length);
  pushStyle();
  float delta = _w/(data.length-1);
  beginShape();
  noFill();
  stroke(colors[index]);
  for (float i : data) {
    float h = map(i, _l, _u, 0, _h);
    vertex(_x, _y+h);
    _x = _x + delta;
  }
  endShape();
  popStyle();
}
