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
################################################################################
script_directory=$1
output=$2
run=$3
number_of_chunks=$4
correction_file=$5
add_task=$6
working_directory=$PWD
# number of the job assigned by the slurm array task.
# This number is used to assign the analyzed data to the job.
ijob=$(($SLURM_ARRAY_TASK_ID - 1))
# Creates a output directory for the job. 
# Naming follows the job id in slurm [0,..., number of Jobs)
mkdir -p $output/data/$ijob
cd $output/data/$ijob
# Executes the RunAnalysis.C script
root -b -q -l "${script_directory}/RunCorrection.C( \
  \"${add_task}\", \
  \"${run}\", \
    ${ijob}, \
    ${number_of_chunks}, \
  \"${correction_file}\" \
)"
cd $working_directory
