#!/bin/bash

file_in="./../binary_function_similarity/DBs/Dataset-1/training_Dataset-1.csv"
target_path="./test/ground_truth"


# Extract available archs
archs=$(cat $file_in | awk -F, '{print $2}' | awk -F/ '{print $4}' | awk -F- '{print $1}' | sort | uniq)
echo available archs: $archs

for arch in $archs; do
    folder_path="$target_path/$arch"
    echo "Creating folder: $folder_path"
    mkdir -p $folder_path
    
    
    # extract executable names for the current bin
    binaries=$(cat $file_in | awk -F, '{print $2}' | awk -F/ '{print $4}' | grep $arch | sort | uniq)
    
    for bin in $binaries; do
        file_out=$(basename "$bin" .i64)
        file_out="$target_path/$arch/$file_out"
        if [ -e "$file_out" ]; then
            echo "File $file_out already exists."
        else      
            # extracting info for the current bin
            echo "Extracting info for $bin"
            cat $file_in | grep $bin | awk -F, '{print $4,$3}' > $file_out
        fi
    done
done
