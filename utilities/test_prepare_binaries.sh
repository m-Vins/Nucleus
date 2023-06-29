#!/bin/bash
set -e  # Stop if there is a failure

_source_dir_=$(dirname "$0")
BASE_DIR=$(readlink -f "${_source_dir_}/..")

# Get the number of files in a directory (excluding hidden files)
file_count=$(find "${BASE_DIR}/test/binaries" -type f ! -name ".*" | wc -l)

# Count the number of lines in the file
line_count=$(wc -l < "${BASE_DIR}/test/binaries_list.txt")

# Compare the counts
if [ "$file_count" -eq "$line_count" ]; then
    echo "Nothing to be done here!"
else
# --------------- DOWNLOAD BINARIES -------------- #

# *** Requires virtualenv ***
#python3 -m pip install --user virtualenv

# create a new "env" environment
#python3 -m venv ../env
# enter the virtual environment
#source ../env/bin/activate

# Install the requirements in the current environment
pip install click==8.1.3 && pip install gdown==4.6.4

python3 ${BASE_DIR}/test/scripts/gdrive_download.py --binaries


# ----------------- COPY BINARIES ---------------- #

binaries_in_dir="${BASE_DIR}/test/binaries/Dataset-1/"
binaries_out_dir="${BASE_DIR}/test/binaries/"
binaries_list="${BASE_DIR}/test/binaries_list.txt"

while IFS= read -r bin; do
    file=$binaries_in_dir/$bin
    if [ -e $file ];then
        echo "Copying $bin"
        cp $file $binaries_out_dir
    else
        echo "ERROR $bin doesn't exist in path $binaries_in_dirid_simo"
    fi
done < $binaries_list

rm -fr ${BASE_DIR}/test/binaries/Dataset-1

fi