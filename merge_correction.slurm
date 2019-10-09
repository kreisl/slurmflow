# Merges the correction files. 
# Keeps and renames the files of the previous iteration.
run_directory=$1
file_name = correction.root
# Renames the files of the previous iteration with an increasing number.
# The current iteration has no iterator postfix.
if [[ -e ${run_directory}/correction/${file_name} ]]; then
    previous=$(ls -1 ${run_directory}/correction/correction* | wc -l)
    mv ${run_directory}/correction/${file_name} \
    ${run_directory}/correction/correction${previous}.root
fi
# Merges the correction files using the root executable hadd
hadd ${run_directory}/correction/${file_name} \
  $(find ${run_directory}/data/*/ -name ${file_name} -type f -printf "%p ")
