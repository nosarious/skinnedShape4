void prepSettings(){
  
  bFirstShape = false;
  bDualShape = false;
  bFirstCells = false;
  bDualCells = false;
  
  bModifyCells = false;
  bModifyObject = false;
  
  bDCStarted = false;
  bFCStarted = false;
  
  nFirstCells = 0;
  nDualCells = 0;
  
  makeFirstShape();
}


void testBooleans(){
  
  if (!bFirstShape) {
    makeFirstShape();
    return;
  }
  if (bFirstShape && !bDualShape) {
    makeDualShape();
    return;
  }
  
  if (!bFirstCells) {
    if (!bFCStarted){
      bFCStarted = true;
      thread("makeFirstCells");
      return;
    }
  }
  
  if (!bDualCells) {
    if (!bDCStarted){
      bDCStarted = true;
      thread("makeDualCells");
      return;
    }
  }
  
  if (!bModifyObject && bModifyCells){
    modifyShape = new HE_Mesh();
    modifyShape = modifyObject(modifyCells, outerColor);
    bModifyObject = true;
  }
  
}

void makeFirstShape(){// make the first shape
  aValue = int(random(360));
  thesePoints = pointsFromSphere();
  
  float objectRadius = 700;
  points =new float[12][3];
  for (int i=0;i<12;i++) {
    float r = objectRadius;// + random(0.01f)-100;
    float phi = radians(random(-90, 90));
    float theta = radians(random(360));
    points[i][0] = r*cos(phi)*cos(theta);
    points[i][1] = r*sin(phi);
    points[i][2] = r*cos(phi)*sin(theta);
  }
  
  bShape = new HE_Mesh();
  bShape = createARock(points);
  
  bShape.moveToSelf(centerPoint);
  firstShape = bShape.get();
  bFirstShape = true;
  print(" the first shape is done");
}

void makeDualShape(){ //make the dual shape
  bShape = createDualRock(bShape);
  bShape.moveToSelf(centerPoint);
  dualShape = bShape.get();
  bDualShape = true;
  print(" the dual shape is done");
} 

  //create the voros 

void makeFirstCells(){
  HE_Mesh innerShape = firstShape.get();
  innerShape.scaleSelf(0.4);
  HE_FaceIterator fitr=innerShape.fItr();
  while (fitr.hasNext()) {
    fitr.next().setColor(innerColor);
  }
  HET_MeshOp.flipFaces(innerShape);
  
  fitr=firstShape.fItr();
  while (fitr.hasNext()) {
    fitr.next().setColor(outerColor);
  }
  firstShape.add(innerShape);
  println(" the first shape is started. ");
  firstCells = createVoro(firstShape, false);
  modifyCells = createVoro(firstShape, false);
  println("first shape has "+firstCells.size()+" cells.");
  bFirstCells = true;
  
  bModifyCells = true;
}

void makeDualCells(){
  HE_Mesh innerShape = dualShape.get();
  innerShape.scaleSelf(0.75);
  HE_FaceIterator fitr=innerShape.fItr();
  while (fitr.hasNext()) {
    fitr.next().setColor(innerColor);
  }
  HET_MeshOp.flipFaces(innerShape);
  
  fitr=dualShape.fItr();
  while (fitr.hasNext()) {
    fitr.next().setColor(outerColor);
  }
  
  dualShape.add(innerShape);
  println(" the dual shape is started. ");
  
  dualCells = createVoro(dualShape, false);
  println("dual has "+dualCells.size()+" cells.");
  bDualCells = true;
} 

  
  
class XGradient implements WB_ScalarParameter {
  public double evaluate(double... x) {
    return constrain((float)WB_Ease.quint.easeInOut(map((float)x[0], -250, 250, 0, 1)), 0, 1);
  }
}

class RevXGradient implements WB_ScalarParameter {
  public double evaluate(double... x) {
    return constrain((float)WB_Ease.quint.easeInOut(map((float)x[0], -250, 250, 1, 0)), 0, 1);
  }
}