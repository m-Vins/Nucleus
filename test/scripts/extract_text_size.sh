#!/bin/bash

_source_dir_=$(dirname "$0")
BASE_DIR=$(readlink -f "${_source_dir_}/../..")

rm -f "${BASE_DIR}/test/text_sizes.txt"
touch "${BASE_DIR}/test/text_sizes.txt"

for binary in "${BASE_DIR}/test/binaries"/*; do
    # Use readelf to get the size of the code section
    readelf -SW $binary | awk '$2 == ".text" { printf "%d\n", "0x" $6}' >> "${BASE_DIR}/test/text_sizes.txt"
done
