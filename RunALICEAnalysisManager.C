// Root macro to start the qvector correction analysis using the AliAnalysisManager
void RunALICEAnalysisManager(std::string macro, 
                   std::string run_list_name, 
                   int ijob, 
                   int number_of_chunks, 
                   std::string correction_file) {
  std::cout << "starting analysis over " 
            << number_of_chunks << " AOD chunks." << std::endl;  
  gInterpreter->ProcessLine(".include $ROOTSYS/include");
  gInterpreter->ProcessLine(".include $ALICE_ROOT/include");
  auto mgr = new AliAnalysisManager("AnalysisQn");
  auto handler = new AliAODInputHandler();
  mgr->SetInputEventHandler(handler);
  // Add the multiplicity task to the train.
  //auto multiplicity_task = reinterpret_cast<AliMultSelectionTask*>(
  //  gInterpreter->ExecuteMacro(
  //    "$ALICE_PHYSICS/OADB/COMMON/MULTIPLICITY/macros/AddTaskMultSelection.C"));

  // Add the Analysis task to the train.
  std::string add_task = macro+"(\"ZDC\",\""+correction_file+"\")";
  auto analysis_task = reinterpret_cast<AliAnalysisTaskFlowSpectators*>(
    gInterpreter->ExecuteMacro(add_task.data()));
  mgr->InitAnalysis();

  // Read files from the runlist at position 
  // [ijob*number_of_chunks,ijob+1 * number_of_chunks) 
  std::ifstream infile(run_list_name);
  std::string line;
  int line_counter = 0;
  std::vector<std::string> aod_files;
  if (infile.is_open()) {
    while (std::getline(infile, line)) {
     if (line_counter >= ijob*number_of_chunks 
         && line_counter < (ijob+1)*number_of_chunks) { 
       aod_files.push_back(line);
       std::cout << line << std::endl;
     }
     line_counter++;
    }
  }
  auto chain = new TChain("aodTree");
  for (auto aod : aod_files) {
    if (! aod.find("$AliAOD.root")) {
      aod +="#AliAOD.root";
    }
    std::cout << "Adding AOD file to the chain: " << aod << std::endl;
    chain->Add(aod.data());
  }
  mgr->StartAnalysis("local",chain);
}
