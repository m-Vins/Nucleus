#!/bin/bash


raw_directory="./test/raw_files"
file_offsets="./test/raw_files_offsets.csv"
ground_truth_dir="./test/ground_truth"

while IFS=',' read -r bin section_offset_raw section_offset_elf; do 
    echo "--------------------------------------------------------"
    echo "testing binary: $bin"
    echo "section_offset_elf: $section_offset_elf"
    echo "section_offset_raw: $section_offset_raw"

    
    arch=$(echo $bin | cut -d - -f1)
    echo "arch:           $arch"

    ground_truth_path_file="$ground_truth_dir/$arch/$bin"

    # Checking the ground truth path
    ground_truth_path_file="$ground_truth_dir/$arch/$bin"
    if [ -e $ground_truth_path_file ]; then
        echo "ground truth path:   $ground_truth_path_file"
    else
        echo "WARNING: file $ground_truth_path_file not present"
        continue
    fi

    # Checking if the raw file for the current binary is present
    raw_path="$raw_directory/$bin"
    if [ -e $raw_path ]; then
        echo "binary path:         $raw_path"
    else
        echo "WARNING: file $raw_path not present"
        continue
    fi

    # map the arch strings in the ones accepted by nucleus
    case "$arch" in
    x86)
        arch="x86-32"
        ;;
    x64)
        arch="x86-64"
        ;;
    mips64)
        arch="mips-64"
        ;;
    mips32)
        arch="mips-32"
        ;;
    arm32)
        arch="arm-32"
        ;;
    arm64)
        arch="arm-64"
        ;;
    *)
        arch="unknown"
        echo "ERROR arch unknown!"
        continue
        ;;
    esac

    echo "Mapped arch:    $arch"


    
    # executing nucleus and computing the true offset using awk
    # The true offset of the function is the offset found by nucleus, less the 
    # offset of the random data in the raw file, plus the offset of the code section
    # in the original binary
    nucleus_out=$(./nucleus -e $raw_path -d linear -f -t raw -a $arch)

    if [ $? != 0 ]; then
        echo "ERROR running file $bin"
    else
        nucleus_functions=$(echo "$nucleus_out"| cut -f1 | gawk -v \
            raw="$section_offset_raw" -v elf="$section_offset_elf" '{
                start = strtonum($0);
                offset = start + elf - raw;
                printf("0x%x\n",offset);
            }'
        )

        found_count=0
        not_found_count=0

        while IFS= read -r line
        do  
            func_addr=$(echo "$line" | cut -d " " -f 2)
            func_name=$(echo "$line" | cut -d " " -f 1)

            if echo "$nucleus_functions" | grep -q "$func_addr"; then
                printf "\t\033[1;32mFOUND:\033[0m      $func_name @ $func_addr\n"
                ((found_count++))
            else
                printf "\t\033[1;31mNOT_FOUND:\033[0m  $func_name @ $func_addr\n"
                ((not_found_count++))
            fi
        done < "$ground_truth_path_file"

    fi
    




done <<< $(tail -n +2 $file_offsets)