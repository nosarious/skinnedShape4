HE_Mesh createARock( float[][] points){
  print("starting rock formation. ");
  HE_Mesh thisMesh;
  HEC_ConvexHull creator=new HEC_ConvexHull();
  
  creator.setPoints(points);
  //alternatively points can be WB_Coord[], HE_Vertex[], any Collection<? extends WB_Coord>, any Collection<HE_Vertex>,
  //double[][] or int[][]
  //creator.setN(10); // set number of points, can be lower than the number of passed points, only the first N points will be used

  thisMesh = new HE_Mesh(creator); 
  firstShape = new HE_Mesh(creator);
  println(" rock is formed.");
  return thisMesh;
}

HE_Mesh createDualRock(HE_Mesh thisMesh){
  //this should return a HEC_Dual mesh
  HE_Mesh thisNewMesh = new HE_Mesh();
  thisNewMesh = thisMesh;
  thisNewMesh.copy();
  
  //find centers and build a new polygon shape
  HEC_Dual creator2=new HEC_Dual();
  creator2.setSource(thisNewMesh);
  thisNewMesh=new HE_Mesh(creator2);
  return thisNewMesh;
}

HE_MeshCollection createVoro(HE_Mesh outerShape, boolean bSimple){
  HE_Mesh thisNewMesh = new HE_Mesh();
  thisNewMesh = outerShape.get();
  
  HE_MeshCollection cells;
  HE_MeshCollection validCells;
  validCells = new HE_MeshCollection();
  
  // generate voronoi cells
  HEMC_VoronoiCells multiCreator=new HEMC_VoronoiCells();
  multiCreator.setPoints(thesePoints);
  // alternatively points can be WB_Point[], any Collection<WB_Point> and double[][];
  //multiCreator.setN(thesePoints.size()/2);//number of points, can be smaller than number of points in input. 
  multiCreator.setContainer(thisNewMesh);// cutoff mesh for the voronoi cells, complex meshes increase the generation time
  //multiCreator.setOffset(5);// offset of the bisector cutting planes, sides of the voronoi cells will be separated by twice this distance
  multiCreator.setSurface(false);// is container mesh a volume (false) or a surface (true)
  multiCreator.setCreateSkin(false);// create the combined outer skin of the cells as an additional mesh? This mesh is the last in the returned array.
  multiCreator.setSimpleCap(false);
  multiCreator.setBruteForce(true);
  // can help speed up things for complex container and give more stable results. Creates the voronoi cells for a simple box and
  // uses this to reduce the number of slicing operations on the actual container. Not fully tested yet.
  cells=multiCreator.create();
  /*
  for (int i=0; i<cells.size(); i++){
    cells.getMesh(i).simplify(new HES_TriDec().setGoal(1.1)); 
    //cells.getMesh(i).fuseCoplanarFaces(0.2); 
  }
  */
  return cells;
}