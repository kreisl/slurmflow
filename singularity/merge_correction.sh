# Merges the correction files. 
# Keeps and renames the files of the previous iteration.
run_directory=$1
file_name=AnalysisResults.root
# Renames the files of the previous iteration with an increasing number.
# The current iteration has no iterator postfix.
if [[ -e ${run_directory}/data/${file_name} ]]; then
    previous=$(ls -1 ${run_directory}/data/AnalysisResults* | wc -l)
    mv ${run_directory}/data/${file_name} \
    ${run_directory}/data/AnalysisResults${previous}.root
fi
# Merges the correction files using the root executable hadd
hadd ${run_directory}/data/${file_name} \
  $(find ${run_directory}/data/*/ -name ${file_name} -type f -printf "%p ")
