# UTILITIES FOLDER

- [cmp_symbols.sh](./cmp_symbols.sh)
- [copy_binaries.sh](./copy_binaries.sh)
- [extract_ground_truth.sh](./extract_ground_truth.sh)
- [test_offset.py](./test_offset.py)

## [generate_raw_file.py](./generate_raw_file.py)

This Python script allows you to extract the code section from an ELF file and generate a raw file containing the extracted code section along with random data.

Usage

```sh
python3 extract_code_section.py <elf_file_path> <output_file_path> <offset>
```

- `elf_file_path`: The path to the ELF file from which to extract the code section.
- `output_file_path`: The path where the raw file will be saved.
- `offset`: The size (in bytes) of the random data to generate and append at the start of the output file.

## [test_prepare_binaries.sh](./test_prepare_binaries.sh)
This bash script can be used to automatically download and pre-process test binaries. Binaries are downloaded using the procedure described [here](https://github.com/Cisco-Talos/binary_function_similarity).

Usage
```sh
bash test_prepare_binaries.sh
```

*__Warning!__*  _This script requires 3.5 GB of disk space._
