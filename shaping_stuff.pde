
HE_Mesh modifyObject(HE_MeshCollection theseCells, color thatColor){
  
  // start with container mesh
  // divide container into voronoi cells
  // randomly discard cells
  HE_Mesh fusedcells;
  int numcells=theseCells.size();
  boolean[] isCellOn=new boolean[numcells];
  for (int i=0; i<numcells; i++) {
    isCellOn[i]=(random(100)<70);
  }
  
  //glue resulting cells together
  HEC_FromVoronoiCells creator=new HEC_FromVoronoiCells().setCells(theseCells).setActive(isCellOn);
  fusedcells=new HE_Mesh(creator);
  
  //fusedcells.triangulate(HE_Selection.selectFacesWithOtherInternalLabel(fusedcells, -1));
  
  //finish gluing?
  //fusedcells.fuse(fusedcells); //cannot do here as cannot remove outer faces (selected by color)
  //fix non-manifold edges and vertices
  HET_Fixer.fixNonManifoldVertices(fusedcells);
  //unsure how to fix non-manifold edges so do a bunch of stuff
  HET_Fixer.collapseDegenerateEdges(fusedcells);
  HET_Fixer.deleteTwoEdgeVertices(fusedcells);
  HET_Fixer.deleteDegenerateTriangles(fusedcells);
  
  //feep largest coonnected submesh
  
  fusedcells.modify(new HEM_KeepLargestParts(1));
  
  //remove boundary (outer) faces (chosen by provided color)
  int counter = 0;
  println();
  print("# faces: "+fusedcells.getNumberOfFaces());
  HE_FaceIterator fItr=fusedcells.fItr();
  HE_Face f;
  while (fItr.hasNext ()) {
    f=fItr.next();
    //println(f);
    color thisColor;
    thisColor = f.getColor();
    if (thisColor == thatColor){
      fusedcells.cutFace(f);
      counter++;
    }
  }
  println (" with "+counter+" faces deleted");
  
  //fusedcells.fuse(fusedcells);
  HET_Fixer.clean(fusedcells);
  
  //you can smooth BEFORE creating a shell if you want harsher edges.
  
  //create a shell to add some thickness
  try{
    fusedcells.modify(new HEM_Shell().setThickness(20));   
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
  try{
    fusedcells.subdivide(subdividor,3);//4 will make it slower to rotate
  } catch (final Exception ex) {
    //oops HE_Mesh messed up, retreat!
    ex.printStackTrace();
    println("unable to smooth surfaces");
  }
  
  //color because white can be boring sometimes
  HET_Texture.setFaceColorFromFaceNormal(fusedcells);
  
  return fusedcells;
}