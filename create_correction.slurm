script_directory=$1
output=$2
run=$3
number_of_chunks=$4
calibration_file=$5
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
root -b -q -l "$script_directory/RunCorrection.C( \
    \"$add_task\", \
    \"${run}\", \
    ${ijob}, \
    ${number_of_chunks}, \
    \"${calibration_file}\")"
cd $working_directory
