#!/bin/bash

_source_dir_=$(dirname "$0")
BASE_DIR=$(readlink -f "${_source_dir_}/../..")

# Set the input file path
file_path="${BASE_DIR}/test/binaries_list.txt"

# Define the number of binaries to select for each architecture
num_binaries=10

# Extract the binaries
binaries_all=$(cat $file_path | cut -d/ -f2 | sort)

# Extract the architecture
archs=$(echo "$binaries_all" | cut -d- -f1 | sort | uniq)

# Create a folder
mkdir -p ${BASE_DIR}/test/binaries_subset

for arch in $archs; do
    for bin in $(echo "$binaries_all" | grep $arch | shuf | head -n $num_binaries ); do
        cp ${BASE_DIR}/test/binaries/$bin ${BASE_DIR}/test/binaries_subset/$bin
    done
done