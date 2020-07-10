#!/bin/bash
#
# Runs the Qn-Vector corrections using the AliAnalysisManager on a local slurm
# The corrections are configured in the AddTask macro, which has to be supplied 
# to the run script.

################################################################################
# Get absolute path from a supplied relative path
# Globals:
#  None
# Arguments:
#  $1 relative path
# Returns:
#  None
################################################################################
function absolute_path() {                                               
  cd "$(dirname "$1")"
  printf "%s/%s\n" "$(pwd)" "$(basename "$1")"
}

################################################################################
# Prepends the SLURM settings to the beginning of the .slurm scripts
# Globals:
#  slurm_partition
#  max_job_duration
# Arguments:
#  $1 path to the slurm script
# Returns:
#  None
################################################################################
function prepend_slurm_settings() {
  local slurm_script=$1
  local script_name=$(basename ${slurm_script%.*})
  local new_file=${script_directory}/generated/${script_name}_settings.slurm
  cat - ${slurm_script} <<- HEADER > ${new_file}
		#!/bin/bash
		#SBATCH -p ${slurm_partition}
		#SBATCH --time=${max_job_duration}
HEADER
}

################################################################################
# Submits a correction job array and a merging job
#    -p debug -t 0:10:0 \
# Globals:
#  script_directory
#  output_directory
#  add_task
#  run_number
#  chunks_per_job
#  task_id_merge
# Arguments:
#  $1 run_list 
#  $2 run_number
# Returns:
#  None
################################################################################
function submit_job() {
  local run_list=$1
  local run_number=$2

  local run_directory=${output_directory}/${run_number}
  echo $run_directory
  local run_script=$script_directory/generated/create_correction_settings.slurm
  local merge_script=$script_directory/generated/merge_correction_settings.slurm
  local length=$(wc -l < $run_list)
  local modulo=$((length % chunks_per_job))
  local number=$((length / chunks_per_job))
  if (( length % chunks_per_job)); then
    ((number++))
  fi
  mkdir -p ${run_directory}/logs
  mkdir -p ${run_directory}/data
  local correction_file=$output_directory/merged/oadb.root
  local task_id_run=$(sbatch --parsable -J ${run_number} \
    -o ${run_directory}/logs/correct-%A_%a_%j.out \
    --array=1-$number -- $run_script $script_directory \
                $run_directory \
                $run_list \
                $chunks_per_job \
                $correction_file \
                $add_task \
  )
   task_id_merge="$task_id_merge:$(sbatch --parsable \
     --dependency afterany:${task_id_run} -J ${run_number}_merge \
     -o ${run_directory}/logs/merge-%A_%j.out -- ${merge_script} ${run_directory} \
   )"
}

################################################################################
# Submits a correction job array and a merging job
# Globals:
#  JOB_CHUNKS
#  JOB_LENGTH
#  JOB_PARTITION
# Arguments:
#  $1 output directory
#  $2 input list
#  $3 path of the add task
# Returns:
#  None
################################################################################
function main() {
  local output_directory
  output_directory=$(absolute_path $1)
  local input=$2
  local add_task_path=$3

  local chunks_per_job="${JOB_CHUNKS:-80}"
  local max_job_duration="${JOB_LENGTH:-7:00:00}"
  local slurm_partition="${JOB_PARTITION:-debug}"
  local script_directory
  script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" \
    >/dev/null 2>&1 && pwd )"
  local root_exe=$(which root)
  # Test if root installation available on the lustre
  if [[ ! $root_exe == *"/lustre/"* ]]; then
    echo "ROOT installation not found on /lustre."
    echo "local aliroot installation in /u/$USER not available on slurm."
    echo "aborting"
    exit
  fi
  # Configure scripts with the slurm settings
  mkdir -p ${script_directory}/generated
  prepend_slurm_settings ${script_directory}/create_correction.slurm
  prepend_slurm_settings ${script_directory}/merge_correction.slurm
  # Create output directories
  mkdir -p ${output_directory}/config
  mkdir -p ${output_directory}/merged
  # Copies AddTask macro to the output directory
  cp $add_task_path ${output_directory}/config/
  local add_task_name=$(basename $add_task_path)
  local add_task=$(absolute_path ${output_directory}/config/${add_task_name})
  local merging_ids=""
  while IFS= read line
  do
    echo ${line}
    local file_name=$(basename ${line})
    local run_number=${file_name%%.*}
    mkdir -p ${output_directory}/${run_number}
    submit_job ${line} ${run_number}
  done < "$input"
}

main "$@"
