//Append a value to a float[] array.
float[] appendArray (float[] _array, float _val) {
  float[] array = _array;
  float[] tempArray = new float[_array.length-1];
  arrayCopy(array, tempArray, tempArray.length);
  array[0] = _val;
  arrayCopy(tempArray, 0, array, 1, tempArray.length);
  return array;
}

void initSoloCSV(){
  //Initiate the dataList and set the header of table
  csvData = new Table();
  for (int i = 0; i < attrNamesSolo.length; i++) {
    csvData.addColumn(attrNamesSolo[i]);
    //if (attrIsNominal[i]) 
    csvData.setColumnType(i, Table.STRING);
    //else csvData.setColumnType(i, Table.FLOAT);
  }
}

void initTeamCSV(){
  //Initiate the dataList and set the header of table
  csvData = new Table();
  for (int i = 0; i < attrNamesTeam.length; i++) {
    csvData.addColumn(attrNamesTeam[i]);
    //if (attrIsNominal[i]) 
    csvData.setColumnType(i, Table.STRING);
    //else csvData.setColumnType(i, Table.FLOAT);
  }
  
   ArrayList<Player> players=new ArrayList<Player>();
     players.add(new Player("Lily","t","1",false));
     players.add(new Player("Tiffany","t","3",false));
     players.add(new Player("Christine","t","8",false));
     players.add(new Player("Chell","t","9",false));
     players.add(new Player("Amanda","t","11",false));
     
     for(Player p : players){
       p.addRowTeam();
     }     
}

void saveSoloCSV(String dataSetName, Table csvData){
  soloPlayer.addRowSolo();
  saveTable(csvData, dataPath(dataSetName+".csv")); //save table as CSV file
  println("Saved as: ", dataSetName+".csv");
}

void saveTeamCSV(String dataSetName, Table csvData){
  soloPlayer.addRowTeam();
  saveTable(csvData, dataPath(dataSetName+".csv")); //save table as CSV file
  println("Saved as: ", dataSetName+".csv");
}

void saveARFF(String dataSetName, Table csvData) {
  String[] attrNames = csvData.getColumnTitles();
  int[] attrTypes = csvData.getColumnTypes();
  int lineCount = 1 + attrNames.length + 1 + (csvData.getRowCount()); //@relation + @attribute + @data + CSV
  String[] text = new String[lineCount];
  text[0] = "@relation "+dataSetName;
  for (int i = 0; i < attrNames.length; i++) {
    String s = "";
    ArrayList<String> dict = new ArrayList<String>();
    s += "@attribute "+attrNames[i];
    if (attrTypes[i]==0) {
      for (int j = 0; j < csvData.getRowCount(); j++) {
        TableRow row = csvData.getRow(j);
        String l = row.getString(attrNames[i]);
        boolean found = false;
        for (String d : dict) {
          if (d.equals(l)) found = true;
        }
        if (!found) dict.add(l);
      }
      s += " {";
      for (int n=0; n<dict.size(); n++) {
        s += dict.get(n);
        if (n != dict.size()-1) s += ",";
      }
      s += "}";
    } else s+=" numeric";
    text[1+i] = s;
  }
  text[1+attrNames.length] = "@data";
  for (int i = 0; i < csvData.getRowCount(); i++) {
    String s = "";
    TableRow row = csvData.getRow(i);
    for (int j = 0; j < attrNames.length; j++) {
      if (attrTypes[j]==0) s += row.getString(attrNames[j]);
      else s += row.getFloat(attrNames[j]);
      if (j!=attrNames.length-1) s +=",";
    }
    text[2+attrNames.length+i] = s;
  }
  saveStrings(dataPath(dataSetName+".arff"), text);
  println("Saved as: ", dataSetName+".arff");
}
