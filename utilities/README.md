# UTILITIES FOLDER

- [cmp_symbols.sh](#cmp_symbolssh)
- [display_results.py](#display_resultspy)
- [generate_raw_file](#generate_raw_file)
- [generate_raw_dataset.sh](#generate_raw_datasetsh)
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
make generate_plot
```

## [generate_raw_file](./generate_raw_file.py)

This Python script allows you to extract the code section from an ELF file and generate a raw file containing the extracted code section along with random data.

Usage

```sh
python3 extract_code_section.py <elf_file_path> <output_file_path> <offset>
```

- `elf_file_path`: The path to the ELF file from which to extract the code section.
- `output_file_path`: The path where the raw file will be saved.
- `offset`: The size (in bytes) of the random data to generate and append at the start of the output file.

## [generate_raw_dataset.sh](./generate_raw_dataset.sh)

This script is used to generate a database of raw files in [test/raw_files](./test/raw_files/).
It uses [generate_raw_file.py](./utilities/generate_raw_file.py) on each binary in [test/binary](./test/binaries/) to generate raw files, where the offset for the code_section in the raw file is chosen randomly. Along this process, it writes in [raw_files_offsets.csv](./test/raw_files_offsets.csv) the offset of the code section in the original elfs (using the output of the python script) and in the new raw files.

usage:

```sh
make generate_raw_files
```

## [test_offset.py](./test_offset.py)

This script run nucleus on a binary in a raw mode several time, each time starting from the next offset. Then it collectes the number of offsets that successfully find each function.

usage:

```sh
python3 test_offset.py <file_path>
```

## [test_prepare_binaries.sh](./test_prepare_binaries.sh)

This bash script can be used to automatically download and pre-process test binaries. Binaries are downloaded using the procedure described [here](https://github.com/Cisco-Talos/binary_function_similarity).

usage:

```sh
make download_all
```

_**Warning!**_ _This script requires 3.5 GB of disk space._

## [test_raw.sh](./test_raw.sh)

This script is used to test nucleus performance on raw files against the [ground truth](./../test/ground_truth/) generated from as explained [here](./../README.md#evaluating-different-architectures-performance) or the one generated using `nm` with [this script](./../test/scripts/generate_nm_gt_parallel.sh)

usage:

```sh
make test_raw
```

or

```sh
make test_raw_nm
```

## [test.sh](./test.sh)

This script is used to test nucleus against the [ground truth](./../test/ground_truth/) generated from as explained [here](./../README.md#evaluating-different-architectures-performance) or the one generated using `nm` with [this script](./../test/scripts/generate_nm_gt_parallel.sh).

usage:

```sh
make test
```

or

```sh
make test_nm
```
