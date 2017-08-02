import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;
import wblut.nurbs.*;
import java.util.List;

//shape variables
HE_Mesh firstShape;
HE_Mesh dualShape;
HE_Mesh aShape;
HE_Mesh bShape;

HE_Mesh modifyShape;

HE_MeshCollection firstCells;
HE_MeshCollection dualCells;

HE_MeshCollection modifyCells;

boolean bFirstShape;
boolean bDualShape;
boolean bFirstCells;
boolean bDualCells;

boolean bModifyCells;
boolean bModifyObject;

boolean bFCStarted;
boolean bDCStarted;
boolean bFirstWireFrame;

float nFirstCells;
float nDualCells;

int aValue;// used to generate asteroid colour, random every creation

List <WB_Coord> thesePoints;
WB_SimpleCoordinate4D centerPoint;
float[][] points;

color outerColor;
color innerColor;

WB_Render render;

float addFactor;

void setup(){
  size(1400,740,P3D);
  smooth(4);
  
  centerPoint = new WB_SimpleCoordinate4D(0.0,0.0,0.0,0.0);
  
  render=new WB_Render(this);
  addFactor = 0.1;
  
  innerColor = color(255,255,0);
  outerColor = color(50,50,255);
  
  prepSettings(); //comment out to quicken shader development
}

void draw(){
    if (bFirstCells){
      nFirstCells+=addFactor;
      //print(" "+nFirstCells);
      if (nFirstCells>firstCells.size()) nFirstCells = 0;//firstCells.size();
    }
    if (bDualCells){
      nDualCells+=addFactor;
      if (nDualCells>dualCells.size()) nDualCells = 0;//dualCells.size();
    }
  //shader(depthShader); //use of shader will ignore lighting
  drawSequence();
}

void drawSequence(){
  background(150);
  directionalLight(255, 255, 255, 1, 1, -1);
  //directionalLight(127, 127, 127, -1, -1, 1);
  pointLight(127, 127, 127,0,0,0);
  //scale(0.75);
  
  testBooleans();
  colorMode(RGB, 255);
  fill(255);
  //stroke(100,75);
  noStroke();
  
  
  //draw the first outlines
  pushMatrix();
    translate(width/2, -height*0.25,-800);
    if (bFirstShape){
      pushMatrix();
        translate(-width*0.75,0,0);
        rotateY(mouseX*1.0f/width*TWO_PI);
        rotateX(mouseY*1.0f/height*TWO_PI);
        scale(0.4);
        render.drawFaces(firstShape);
      popMatrix();
    }
    if (bDualShape){
      pushMatrix();
        translate(width*0.75, 0,0);
        rotateY(mouseX*1.0f/width*TWO_PI);
        rotateX(mouseY*1.0f/height*TWO_PI);
        scale(0.3);
        render.drawFaces(bShape);
      popMatrix();
    }
  popMatrix();
  
  
  //draw the voronoi shapes
  pushMatrix();
    translate(width/2, height,-800);
    if (bFirstCells){
      pushMatrix();
        translate(-width*0.75,0,0);
        rotateY(mouseX*1.0f/width*TWO_PI);
        rotateX(mouseY*1.0f/height*TWO_PI);
        scale(0.4);
        drawCells(firstCells, nFirstCells);
      popMatrix();
    }
    if (bDualCells){
      pushMatrix();
        translate(width*0.75,0,0);
        rotateY(mouseX*1.0f/width*TWO_PI);
        rotateX(mouseY*1.0f/height*TWO_PI);
        scale(0.4);
        drawCells(dualCells, nDualCells);
      popMatrix();
    }
    /*
    if (bModifyCells){
      pushMatrix();
        translate(width*0.75,0,0);
        rotateY(mouseX*1.0f/width*TWO_PI);
        rotateX(mouseY*1.0f/height*TWO_PI);
        scale(0.4);
        drawCells(dualCells, nDualCells);
      popMatrix();
    }
    */
  popMatrix();
  
  pushMatrix();
    translate(width/2, height/2,-400);
    if (bModifyObject){
      pushMatrix();
        translate(0,0,0);
        rotateY(mouseX*1.0f/width*TWO_PI);
        rotateX(mouseY*1.0f/height*TWO_PI);
        //scale(0.4);
        render.drawFacesFC(modifyShape);
        stroke(0,25);
        render.drawEdges(modifyShape);
        noStroke();
      popMatrix();
    }
  popMatrix();
  
}


void drawCells (HE_MeshCollection theseCells, float thisMany){
  for (int i=0; i<int(thisMany); i++){
    render.drawFacesFC(theseCells.getMesh(i));
    stroke(0,50);
    render.drawEdges(theseCells.getMesh(i));
    noStroke();
  }
}

List <WB_Coord> pointsFromSphere(){
  
  int B, C;
  // make a icosahedron
  B=0;
  C=1;
  HEC_Geodesic creator=new HEC_Geodesic();
  creator.setRadius(20);
  creator.setB(B+1);
  creator.setC(C);
  creator.setType(HEC_Geodesic.ICOSAHEDRON);
  HE_Mesh thisMesh = new HE_Mesh(creator); 
  
  // get points from icosohedron
  thesePoints = thisMesh.getPoints();
  
  println("there are "+thesePoints.size()+" points being used");
  
  List <WB_Coord> thePoints = thisMesh.getPoints();
  thePoints.add(centerPoint);
  
  return thePoints;
}

void mousePressed(){
  prepSettings(); //comment out to quicken shader development
}