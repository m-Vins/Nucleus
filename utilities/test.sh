#!/bin/bash

# call with flag --nm to use the nm ground truth

_source_dir_=$(dirname "$0")
BASE_DIR=$(readlink -f "${_source_dir_}/..")

binaries_dir="${BASE_DIR}/test/binaries"
ground_truth_dir="${BASE_DIR}/test/ground_truth"
results_file="${BASE_DIR}/test/results.csv"

if [ $# -eq 1 ] && [ $1 == "--nm" ]; then
    ground_truth_dir="${BASE_DIR}/test/ground_truth_nm"
    results_file="${BASE_DIR}/test/results_nm.csv"
fi

# Create a header for the results file
echo "arch,binary,tested,found_count,not_found_count,false_positives" > $results_file

# Loop through each binary in the binaries directory
for binary in $(ls $binaries_dir); do
    echo "--------------------------------------------------------"
    echo "testing binary: $binary"

    # Extract the architecture from the binary name
    arch=$(echo $binary | cut -d / -f 4 | cut -d - -f1)

    # Checking the ground truth path
    ground_truth_path_file="$ground_truth_dir/$arch/$binary"
    if [ -e $ground_truth_path_file ]; then
        echo "ground truth path:   $ground_truth_path_file"
    else
        echo "WARNING: file $ground_truth_path_file not present"
        continue
    fi

    # Checking the binary path
    binary_path="$binaries_dir/$binary"
    if [ -e $binary_path ]; then
        echo "binary path:         $binary_path"
    else
        echo "WARNING: file $binary_path not present"
        continue
    fi

    # Run nucleus with the binary and capture the output
    nucleus_out=$(${BASE_DIR}/nucleus -e $binary_path -d linear -f) 

    # Check the return code of nucleus
    if [ $? != 0 ]; then
        echo "ERROR running file $binary"
        echo "$arch,$binary,error,,," >> $results_file
    else
        # Extract the functions from the nucleus output
        nucleus_functions=$(echo "$nucleus_out" | cut -f 1)

        # Count the number of functions found by nucleus
        nucleus_function_number=$(echo "$nucleus_functions" | wc -l)

        # Initialize the counters
        found_count=0
        not_found_count=0

        # Loop through each line in the ground truth file
        while IFS=" " read -r func_name func_addr;
        do
            # Check if the function address is present in the 'nucleus' output
            if echo "$nucleus_functions" | sed 's/0x0*/0x/' | grep -q "$func_addr"; then
                printf "\t\033[1;32mFOUND:\033[0m      $func_name @ $func_addr\n"
                ((found_count++))
            else
                printf "\t\033[1;31mNOT_FOUND:\033[0m  $func_name @ $func_addr\n"
                ((not_found_count++))
            fi
        done < "$ground_truth_path_file"

        # Compute the number of false positives: the number of 
        # functions that are found by nucleus and not present in the ground truth file
        false_positives=$((nucleus_function_number - found_count))

        echo "Found Functions: $found_count"
        echo "Not Found Functions: $not_found_count"
        echo "False Positives : $false_positives"

        # Write the results to the results file
        echo "$arch,$binary,yes,$found_count,$not_found_count,$false_positives" >> $results_file
    fi
done
