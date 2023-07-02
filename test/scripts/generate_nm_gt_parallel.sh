#!/bin/bash

_source_dir_=$(dirname "$0")
BASE_DIR=$(readlink -f "${_source_dir_}/../..")

destination="${BASE_DIR}/test/ground_truth_nm"
source="${BASE_DIR}/test/ground_truth"

threads=24

# Create the destination directory if it doesn't exist
mkdir -p "$destination"

# Iterate over the subdirectories in the source directory
for subdirectory in "$source"/*/; do
    # Extract the subdirectory name
    subdirectory_name=$(basename "$subdirectory")
    
    # Create the corresponding subdirectory in the destination directory
    mkdir -p "$destination/$subdirectory_name"
done

index=0
# Iterate over all files in the directory
for binary in "${BASE_DIR}/test/binaries"/*; do
    base=$(basename "$binary")
    subdirectory=$(basename "$binary" | cut -d '-' -f 1)
    file_name="$destination"/"$subdirectory"/"$base"
    # Check if the corresponding file does not exist
    if [[ ! -f $file_name ]]; then
        # Determine the tmp file index
        tmp_file="$((index % threads)).tmp"
        # Append the file name to the tmp file
        echo "$binary" >> "$tmp_file"
        ((index++))
    fi 
done

for ((t = 0; t < threads; t++)); do
    bash ${BASE_DIR}/test/scripts/generate_nm_gt.sh ${t}.tmp &
done

wait

rm *.tmp