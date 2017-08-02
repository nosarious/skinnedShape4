
HE_Mesh modifyObject(HE_MeshCollection theseCells, color thatColor){
  
  // start with container mesh
  // divide container into voronoi cells
  // randomly discard cells
  HE_Mesh fusedcells;
  int numcells=theseCells.size();
  boolean[] isCellOn=new boolean[numcells];
  for (int i=0; i<numcells; i++) {
    isCellOn[i]=(random(100)<50);
  }
  /*
  isCellOn[0] = false;
  isCellOn[5] = false;
  */
  //glue resulting cells together
  HEC_FromVoronoiCells creator=new HEC_FromVoronoiCells().setCells(theseCells).setActive(isCellOn);
  fusedcells=new HE_Mesh(creator);
  
  //fusedcells.triangulate(HE_Selection.selectFacesWithOtherInternalLabel(fusedcells, -1));
  
  //finish gluing?
  //fusedcells.fuse(fusedcells);
  //fix non-manifold edges and vertices
  
  HET_Fixer.fixNonManifoldVertices(fusedcells);
  HET_Fixer.collapseDegenerateEdges(fusedcells);
  HET_Fixer.deleteTwoEdgeVertices(fusedcells);
  HET_Fixer.deleteDegenerateTriangles(fusedcells);
  
  //feep largest coonnected submesh
  
  fusedcells.modify(new HEM_KeepLargestParts(1));
  
  //remove boundary (outer) faces (chosen by provided color)
  int counter = 0;
  print("# faces: "+fusedcells.getNumberOfFaces());
  HE_FaceIterator fItr=fusedcells.fItr();
  HE_Face f;
  while (fItr.hasNext ()) {
    f=fItr.next();
    //println(f);
    color thisColor;
    thisColor = f.getColor();
    if (thisColor == thatColor){
      fusedcells.deleteFace(f);
      counter++;
    }
  }
  println (" with "+counter+" faces deleted");
  
  //fusedcells.fuse(fusedcells);
  HET_Fixer.clean(fusedcells);
  
  
  try{
    fusedcells.modify(new HEM_Shell().setThickness(10));   
  } catch (final Exception ex) {
    //oops HE_Mesh messed up, retreat!
    ex.printStackTrace();
    println("unable to create shell");
  }
  
  
  
  //smooth resulting surface
  HES_Smooth subdividor=new HES_Smooth();
  subdividor.setWeight(5,1);// weight of original and neighboring vertices, default (1.0,1.0)
  subdividor.setKeepBoundary(true);// preserve position of vertices on a surface boundary
  subdividor.setKeepEdges(true);// preserve position of vertices on edge of selection (only useful if using subdivideSelected)
  fusedcells.subdivide(subdividor,3);
  

  HET_Texture.setFaceColorFromFaceNormal(fusedcells);
  
  subdividor=new HES_Smooth();
  subdividor.setWeight(5,1);// weight of original and neighboring vertices, default (1.0,1.0)
  //subdividor.setKeepBoundary(true);// preserve position of vertices on a surface boundary
  //subdividor.setKeepEdges(true);// preserve position of vertices on edge of selection (only useful if using subdivideSelected)
  //fusedcells.subdivide(subdividor,2);
  
  return fusedcells;
}