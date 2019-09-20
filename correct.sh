#!/bin/bash

function absolute_path() {                                               
  cd "$(dirname "$1")"
  printf "%s/%s\n" "$(pwd)" "$(basename "$1")"
}

function prepend_slurm_settings() {
  local slurm_script=$1
  local script_name=$(basename ${slurm_script%.*})
  local new_file=${script_directory}/generated/${script_name}_settings.slurm
  cat - ${slurm_script} <<- HEADER > ${new_file}
	#!/bin/bash
	#SBATCH -p ${slurm_partition}
HEADER
  # Unused options
	#SBATCH --time=${max_job_duration}
}

function submit_job() {
  local run_script=$script_directory/generated/create_correction_settings.slurm
  local merge_script=$script_directory/generated/merge_correction_settings.slurm
  local output_directory=$1
  local run_list=$2
  local run_number=$3  
  local add_task=$4
  local length=$(wc -l < $run_list)
  local modulo=$((length % chunks_per_job))
  local number=$((length / chunks_per_job))
  if (( length % chunks_per_job)); then
    ((number++))
  fi
  mkdir -p $output_directory/logs
  mkdir -p $output_directory/data
  mkdir -p $output_directory/correction
  correctionpath=$(absolute_path $output_directory/../merged)
  calibration_file=$correctionpath/correction_${run_number}.root
  echo $calibration_file
  local task_id_run=$(sbatch --parsable -J ${run_number} \
    -o ${output_directory}/logs/slurm-%A_%a.out \
    -e ${output_directory}/logs/slurm-%A_%a.out --array=1-$number $run_script \
    $script_directory $output_directory $run_list $chunks_per_job \
    $calibration_file $add_task)
  task_id_merge="$task_id_merge:$(sbatch --parsable \
    --dependency afterany:${task_id_run} -J ${run_number}_merge \
    -o ${output_directory}/logs/slurm-%A_%a.out \
    -e ${output_directory}/logs/slurm-%A_%a.out ${merge_script} ${output})"
}

function main() {
  local chunks_per_job="${JOB_CHUNKS:-80}"
  local max_job_duration="${JOB_LENGTH:-7:00:00}"
  local slurm_partition="${JOB_PARTITION:-debug}"
  local script_directory
  script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" \
    >/dev/null 2>&1 && pwd )"

  echo "Number of chunks per job:" $chunks_per_job 
  local output_directory=$1
  local input=$2
  local add_task_path=$3
  local root_exe=$(which root)
  # Test if root installation available on the lustre
  if [[ ! $root_exe == *"/lustre/"* ]]; then
    echo "ROOT installation not found on /lustre."
    echo "local aliroot installation in /u/$USER not available on slurm."
    echo "aborting"
    exit
  fi
  prepend_slurm_settings $script_directory/create_correction.slurm
  prepend_slurm_settings $script_directory/merge_correction.slurm
  prepend_slurm_settings $script_directory/copy_correction.slurm
  mkdir -p ${output_directory}/config
  mkdir -p ${output_directory}/merged
  cp $add_task_path ${output_directory}/config/
  add_task_name=$(basename $add_task_path)
  local merging_ids=""
  while IFS= read line
  do
    echo ${line}
    file_name=$(basename ${line})
    run_number=${file_name%%.*}
    mkdir -p ${output_directory}/${run_number}
    task=$(absolute_path $output_directory/config/${add_task_name})
    submit_job ${output_directory}/${run_number} ${line} ${run_number} ${task}
  done < "$input"
  merging_ids=${task_id_merge##:}
  sbatch --dependency afterany:$merging_ids -J copying_correction_files \
    -o ${output_directory}/merged/slurm-%A.out \
    -e ${output_directory}/merged/slurm-%A.out \
    ${script_directory}/generated/copy_correction_settings.slurm \
    ${output_directory}
}

main "$@"
