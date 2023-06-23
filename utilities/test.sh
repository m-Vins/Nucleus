#!/bin/bash


binaries_dir="./test/binaries/"
ground_truth_dir="./test/ground_truth"

binary="mips64-gcc-9-Os_unrar"
# binary="mips64-clang-3.5-O0_curl"
echo "binary: $binary"

arch=$(echo $binary | cut -d / -f 4 | cut -d - -f1)
echo "arch:   $arch"

# Checking the fround truth path
ground_truth_path_file="$ground_truth_dir/$arch/$binary"
if [ -e $ground_truth_path_file ]; then
    echo "ground truth path:   $ground_truth_path_file"
else
    echo "WARNING: file $ground_truth_path_file not present"
fi


# Checking the binary path
binary_path="$binaries_dir/$binary"
if [ -e $binary_path ]; then
    echo "binary path:         $binary_path"
else
    echo "WARNING: file $binary_path not present"
fi


nucleus_out=$(./nucleus -e $binary_path -d linear -f) 


if [ $? != 0 ]; then
    echo "ERROR running file $binary"
else
    nucleus_functions=$(echo "$nucleus_out" | cut -f 1)

    found_count=0
    not_found_count=0

    while IFS= read -r line
    do  
        func_addr=$(echo "$line" | cut -d " " -f 2)
        func_name=$(echo "$line" | cut -d " " -f 1)

        if echo "$nucleus_functions" | sed 's/0x0*/0x/' | grep -q "$func_addr"; then
            printf "\t\033[1;32mFOUND:\033[0m      $func_name @ $func_addr\n"
            ((found_count++))
        else
            printf "\t\033[1;31mNOT_FOUND:\033[0m  $func_name @ $func_addr\n"
            ((not_found_count++))
        fi
    done < "$ground_truth_path_file"

    echo "Found functions: $found_count"
    echo "Not found functions: $not_found_count"
fi