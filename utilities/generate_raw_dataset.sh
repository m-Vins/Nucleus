#!/bin/bash

# Directory paths
binaries_dir="./test/binaries/"    # Path to directory containing binary files
out_dir="./test/raw_files/"        # Path to directory where raw files will be generated
offset_file="./test/raw_files_offsets.csv"   # Path to the offset file

# Maximum dimension of the random data, don't use it too big to avoid wasting memory
MAX_OFFSET=1024

# Header for the offset file
echo "binary,section_offset_elf,section_offset_raw" > $offset_file

# Iterate over each file in the binaries directory
for bin in $(ls $binaries_dir); do 
    file_in=$binaries_dir/$bin     # Input binary file path
    file_out=$out_dir/$bin         # Output raw file path

    # Generate a random offset between 1 and MAX_OFFSET
    random_offset=$((1 + RANDOM % MAX_OFFSET))

    # Print the current file being processed and the random offset
    echo "generating raw file from $bin with offset $random_offset"

    # Write the binary name and offset to the offset file
    printf "$bin," >> $offset_file
    printf "$random_offset," >> $offset_file

    # Run a Python script to generate the raw file using the input binary and offset,
    # and append the resulting section offset to the offset file
    python3 ./utilities/generate_raw_file.py $file_in $file_out $random_offset | cut -d " " -f2 >> $offset_file
done
