output_directory=$1
find $output_directory/*/correction -name correction.root -type f \
| while read line; do
    # get the run number from the directory name of the correction files
    # and appends it to the file name of the copy
    run_name=`dirname $line`
    run_name="${run_name##$output_directory/}"
    run_name="${run_name%%/*}"
    cp "$line" $output_directory/merged/correction_${run_name}.root
done

