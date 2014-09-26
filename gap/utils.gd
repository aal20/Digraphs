#############################################################################
##
#W  utils.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareGlobalFunction("DigraphsStartTest");
DeclareGlobalFunction("DigraphsStopTest");
DeclareGlobalFunction("DigraphsMakeDoc");
DeclareGlobalFunction("DigraphsTestAll");
DeclareGlobalFunction("DigraphsTestInstall");
DeclareGlobalFunction("DigraphsTestManualExamples");
DeclareGlobalFunction("DigraphsManualExamples");

DeclareGlobalFunction("WriteDirectedGraph");
DeclareGlobalFunction("DirectedGraphWriteFile");

DeclareOperation("ReadGraph6Line", [IsString]);
DeclareOperation("ReadDigraph6Line", [IsString]);
DeclareGlobalFunction("DigraphReadFile");
DeclareGlobalFunction("ReadDirectedGraphs");
DeclareOperation("WriteGraph6", [IsDirectedGraph]);
DeclareOperation("WriteDigraph6", [IsDirectedGraph]);

DeclareGlobalFunction("DigraphsDir");