//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************
import Weka4P.*;
Weka4P wp;

double[] CArray = {1, 2, 4, 8, 16, 32, 64, 128, 256};
boolean showModelOnly = false;

void setup() {
  size(500, 500, P2D);
  frameRate(60);
  wp = new Weka4P(this);
  wp.loadTrainARFF("VBTrain.arff");//load a ARFF dataset
  myCSearchLSVC(CArray);
}

void draw() {
  //wp.drawCSearchModels(0, 0, width, height);
  if (!showModelOnly) wp.drawCSearchResults(0, 0, width, height);
}

void keyPressed() {
  if (key == ENTER || key == ENTER) {
    showModelOnly = (showModelOnly? false : true);
  }
}

  /**
   * Searches for C of a Linear Support Vector Classifier
   * @param _CList array of C's
   */
  public void myCSearchLSVC(double[] _CList) {
    wp.CList = _CList;
    wp.accuracyGrid = new double[_CList.length][1];
    wp.modelImageGrid = new PImage[_CList.length][1];
    for (int c = 0; c < _CList.length; c++) {
      wp.trainLinearSVC(wp.C = _CList[c]);
      wp.evaluateTrainSet(wp.fold = 5, wp.isRegression = false, wp.showEvalDetails = false); // 5-fold cross validation
      wp.setModelDrawing(wp.unit = PApplet.ceil(PApplet.sqrt(_CList.length)) * 2); // set the model visualization (for
                                          // 2D features)
      //wp.modelImageGrid[c][0] = wp.pg.get();
      wp.accuracyGrid[c][0] = wp.accuracyTrain;
      PApplet.println(wp.fold + "-fold CV Accuracy:", PApplet.nf((float) wp.accuracyTrain, 0, 2), "%\n");
    }
  }
