#!/bin/bash

binaries_in_dir="./../binaries/"
binaries_out_dir="./test/binaries/"
binaries_list="./test/binaries_list.txt"

while IFS= read -r bin; do
    file=$binaries_in_dir/$bin
    if [ -e $file ];then
        echo "Copying $bin"
        cp $file $binaries_out_dir
    else
        echo "ERROR $bin doesn't exist in path $binaries_in_dirid_simo"
    fi
done < $binaries_list