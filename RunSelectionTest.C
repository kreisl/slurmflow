// Root macro to start the qvector correction analysis using the AliAnalysisManager
void RunSelectionTest() {
  gInterpreter->ProcessLine(".include $ROOTSYS/include");
  gInterpreter->ProcessLine(".include $ALICE_ROOT/include");
  auto mgr = new AliAnalysisManager("AnalysisQn");
  auto handler = new AliAODInputHandler();
  mgr->SetInputEventHandler(handler);
  TString add_task("AddTaskSelectionTest.C");
  auto analysis_task = reinterpret_cast<AliAnalysisTaskFlowZ*>(
    gInterpreter->ExecuteMacro(add_task));
  mgr->InitAnalysis();
  auto chain = new TChain("aodTree");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0001/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0002/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0003/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0004/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0005/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0006/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0007/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0009/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0010/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0011/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0012/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0013/AliAOD.root");
  chain->Add("/lustre/hebe/alice/alien/alice/data/2010/LHC10h/000137235/ESDs/pass2/AOD160/0014/AliAOD.root");
  mgr->StartAnalysis("local",chain);
}
