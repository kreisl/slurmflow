################################################################################
# Calls root to execute the correction step using the AliAnalysisManager
# Globals
#  SLURM_ARRAY_TASK_ID
# Arguments
#  $1 directory of the scripts
#  $2 output directory
#  $3 name of the run list
#  $4 number of files (chunks) which are analyzed
#  $5 name of the correction file
#  $6 name of the AddTask
#  $7 id of slurm array task 
################################################################################
script_directory=$1
output=$2
run=$3
number_of_chunks=$4
correction_file=$5
add_task=$6
ijob=$7
working_directory=$PWD
# initialize the ALICE analysis environment
eval `alienv load AliPhysics/latest`
#changing to output directory
mkdir -p $output/data/$ijob
cd $output/data/$ijob
# Executes the RunAnalysis.C script
root -b -q -l "${script_directory}/RunALICEAnalysisManager.C( \
  \"${add_task}\", \
  \"${run}\", \
    ${ijob}, \
    ${number_of_chunks}, \
  \"${correction_file}\" \
)"
cd $working_directory
