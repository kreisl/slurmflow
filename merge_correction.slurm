output_directory=$1
file_name = correction.root
# Renames the files of the previous iteration with an increasing number.
# The current iteration has no iterator postfix.
if [[ -e ${output_directory}/correction/${file_name} ]]; then
    previous=$(ls -1 ${output_directory}/correction/correction* | wc -l)
    mv ${output_directory}/correction/${file_name} \
    ${output_directory}/correction/correction${previous}.root
fi
# Merges the correction files.
hadd ${output_directory}/correction/${file_name} \
  $(find ${output_directory}/data/*/ -name ${file_name} -type f -printf "%p ")
