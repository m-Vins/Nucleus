#!/bin/bash

file_in="./../binary_function_similarity/DBs/Dataset-1/training_Dataset-1.csv"
target_path="./test/ground_truth"
# binaries_list is a file containing the names of all the binaries extracted, it is useful to
# fetch the binaries we need from the database
binaries_list="./test/binaries_list.txt"
# clear the file
echo "" > $binaries_list


# Extract available archs
archs=$(cat $file_in | awk -F, '{print $2}' | awk -F/ '{print $4}' | awk -F- '{print $1}' | sort | uniq)
echo available archs: $archs

for arch in $archs; do
    folder_path="$target_path/$arch"
    echo "Creating folder: $folder_path"
    mkdir -p $folder_path
    
    while IFS= read -r line; do
        program=$(echo "$line" | cut -d " " -f 2)
        bin=$(echo "$line" | cut -d " " -f 1)
 
        # removing ".i64" from the name
        file_out=$(basename "$bin" .i64)

        # write the path of the binary in binaries_list in order 
        # to fetch them afterwards using the script copy_binaries.sh
        echo "$program/$file_out" >> $binaries_list

        file_out="$target_path/$arch/$file_out"

        # Check if the file already exists
        if [ -e "$file_out" ]; then
            echo "File $file_out already exists."
        else      
            # extracting info for the current bin following the structure:
            # function_name start_address
            echo "Extracting info for $bin"
            cat $file_in | grep $bin | awk -F, '{print $4,$3}' > $file_out
        fi

    done <<< "$(cat $file_in | awk -F, '{print $2}' | awk -F/ '{print $4,$3}' | grep $arch | sort | uniq)"
done
