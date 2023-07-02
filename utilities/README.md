# UTILITIES FOLDER

- [cmp_symbols.sh](#cmp_symbolssh)
- [display_results.py](#display_resultspy)
- [generate_raw_dataset.sh](#generate_raw_datasetsh)
- [generate_raw_file](#generate_raw_file)
- [test_offset.py](#test_offsetpy)
- [test_prepare_binaries.sh](#test_prepare_binariessh)
- [test_raw.sh](#test_rawsh)
- [test.sh](#testsh)

## [cmp_symbols.sh](./cmp_symbols.sh)
This script can be used to try Nucleus on whichever non-stripped x86 ELF file. The output is enhanced to visualize the names of functions which are correctly found by the tool. False positives are signaled as well.

Usage
```sh
bash cmp_symbols.sh <elf_file_path> [--raw]
```
- `elf_file_path`: The path to the ELF file on which we want to run `nucleus`. The file must not be stripped.
- If the `--raw` option is specified, the ELF file is interpreted as raw.

## [display_results.py](./display_results.py)
This script visualizes the distribution of accuracy for different architectures, weighted by the number of false positives. It generates plots comparing different compilers (namely, Clang and GCC), as well as different levels of optimization. Generated images are saved in the [/images](../images/) directory.

Usage
```sh
python3 display_results.py
```

## [generate_raw_dataset.sh](./generate_raw_dataset.sh)
<!-- TODO -->



## [generate_raw_file](./generate_raw_file.py)
This Python script allows you to extract the code section from an ELF file and generate a raw file containing the extracted code section along with random data.

Usage

```sh
python3 extract_code_section.py <elf_file_path> <output_file_path> <offset>
```

- `elf_file_path`: The path to the ELF file from which to extract the code section.
- `output_file_path`: The path where the raw file will be saved.
- `offset`: The size (in bytes) of the random data to generate and append at the start of the output file.

## [test_offset.py](./test_offset.py)
<!-- TODO -->

## [test_prepare_binaries.sh](./test_prepare_binaries.sh)
This bash script can be used to automatically download and pre-process test binaries. Binaries are downloaded using the procedure described [here](https://github.com/Cisco-Talos/binary_function_similarity).

Usage
```sh
bash test_prepare_binaries.sh
```
*__Warning!__*  _This script requires 3.5 GB of disk space._

## [test_raw.sh](./test_raw.sh)
<!-- TODO -->

## [test.sh](./test.sh)
<!-- TODO -->

