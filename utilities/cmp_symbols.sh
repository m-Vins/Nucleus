#!/bin/bash
set -e  # Stop if there is a failure

# Check if the user has provided an argument
if [ $# -eq 0 ]; then
    echo -e "\n\033[1;35m\tbash cmp_symbols.sh <ELF file, not stripped> [--raw]\033[0m"
    echo -e "Compares the output of nucleus (run on the stripped file) with the output of nm, adding symbol names to functions."
    echo -e "If the --raw option is specified, the ELF file is interpreted as raw.\n"
    exit
fi

if [ $# -eq 2 ] && [ $2 == "--raw" ]; then
    extra="-t raw -a x86"
fi

elf_name=$1
elf_name=$(realpath $elf_name)
_source_dir_=$(dirname "$0")
BASE_DIR=$(readlink -f "${_source_dir_}/..")

# check if the file is stripped
file_info=$(file -L $elf_name)
is_stripped=$(echo "$file_info" | { grep -v "not stripped" || true; })
if [[ -n "$is_stripped" ]]; then
    echo -e "\033[1;31m[error]\033[0m File is stripped!"
    exit 1
fi

nm_out=$(nm $elf_name)
elf_stripped="${elf_name}_stripped"
cp $elf_name $elf_stripped
strip -s $elf_stripped

# Iterate over each line in the output
while IFS= read -r line; do
    # Extract the function number
    function_num=$(echo $line | sed -e 's,^.*x\(.*\) .* .*$,\1,g')
    # Extract the symbol name of the function
    function_name=$(echo $nm_out | sed -e "s,^.*${function_num} \(.\) \([^ ]\+\).*$,\2 (\1),")

    word_count=$(echo "$function_name" | wc -w)
    if [ "$word_count" -ne 2 ]; then
        echo -e "$line\t-->\033[1;31m symbol not found \033[0m"
    else
        echo -e "$line\t-->\033[1;32m $function_name \033[0m"
    fi
done < <("${BASE_DIR}/nucleus" -e $elf_stripped -d linear $extra | grep function)

rm $elf_stripped