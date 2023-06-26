#!/bin/bash
set -e  # Stop if there is a failure

raw_directory="./test/raw_files"
file_offsets="./test/raw_files_offsets.csv"

while IFS=',' read -r bin section_offset_elf section_offset_raw; do 
    

done < $file_offsets