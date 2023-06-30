#!/bin/bash
set -e

_source_dir_=$(dirname "$0")
BASE_DIR=$(readlink -f "${_source_dir_}/../..")

destination="${BASE_DIR}/test/ground_truth_nm"
source="${BASE_DIR}/test/ground_truth"

# Create the destination directory if it doesn't exist
mkdir -p "$destination"

# Iterate over the subdirectories in the source directory
for subdirectory in "$source"/*/; do
    # Extract the subdirectory name
    subdirectory_name=$(basename "$subdirectory")
    
    # Create the corresponding subdirectory in the destination directory
    mkdir -p "$destination/$subdirectory_name"
done

for binary in "${BASE_DIR}/test/binaries"/*; do
    base=$(basename "$binary")
    subdirectory=$(basename "$binary" | cut -d '-' -f 1)
    file_name="$destination"/"$subdirectory"/"$base"
    touch $file_name
    
    # Iterate over each line in the output
    while IFS= read -r line; do
        function_name=$(echo "$line" | awk '{print $NF}')
        address_hex=$(echo "$line" | awk '{print $1}' | sed 's/^0*//')
        echo "$function_name 0x$address_hex" >> $file_name
    done < <(nm $binary | grep -i "t ")
done