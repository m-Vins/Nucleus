# Nucleus Forensics Project

Students:

- Vincenzo Mezzela ( [mezzela@eurecom.fr](mailto:mezzela@eurecom.fr) )
- Ilaria Pilo ( [pilo@eurecom.fr](mailto:pilo@eurecom.fr) )

## Index

- [Project description](#project-description)
  - [Reorganization of the directory tree](#reorganization-of-the-directory-tree)
  - [Fixing the tool](#fixing-the-tool)
  - [Raw files support](#raw-files-support)
  - [Evaluating different architectures performance](#evaluating-different-architectures-performance)
- [Makefile commands](#makefile-commands)
- [Usage](#nucleus-usage)

---

## Project Description

The Nucleos project for the Forensics course aims to enhance and revitalize an existing tool called Nucleus, available at [https://bitbucket.org/vusec/nucleus/src/master/](https://bitbucket.org/vusec/nucleus/src/master/). Nucleus is primarily designed to locate function headers in stripped binaries, aiding in the analysis of binary files. However, due to changes in library APIs, the tool was no longer functioning as intended.

The outperformed tasks can be categorized into the following areas of improvement:

1. [**Reorganization of the directory tree**](#reorganization-of-the-directory-tree):
   The initial task involves cloning the Nucleus repository and enhance the directory structure with respect to the basic version proposed [initially](https://bitbucket.org/vusec/nucleus/src/master/) which is pretty basic. This improves code maintainability, readability, and collaboration.
   <!-- TODO migliorare qui -->

2. [**Fixing the Tool**](#fixing-the-tool):
   Addressing the issues that prevent it from functioning correctly. By understanding the changes in library APIs and making the necessary modifications to the codebase in order to restore the tool's functionality.

3. [**Raw files support**](#raw-files-support):
   The tool currently focuses on Portable Executable (PE) and Executable and Linkable Format (ELF) binaries. However, there is still room for improvement in supporting raw binary files.

4. [**Evaluating different architectures performance**](#evaluating-different-architectures-performance):
   While Nucleos has undergone extensive testing for x86 architecture, the effectiveness of its approach on other architectures remains uncertain. For this task, a large number of binaries (~3000) belonging to different architectures along with their ground truth have been exploited to evaluate the performance of the tool. An other ground truth has been built using the `readelf` tool to carry out further testing.

### Reorganization of the directory tree

- [src](./src/): This directory contains the source code files of the project.
- [include](./include): Header files reside in this directory.
- [obj](./obj): This directory is used to store object files generated during the compilation process.
- [test](./test): It contains all the files used for testing (binaries, ground_truth, ...), for further information refer [here](./test/README.md).
- [utilities](./utilities/): It contains a set of scripts used for different purposes, for further information refer [here](./utilities/README.md).

### Fixing the tool

The [source code](https://bitbucket.org/vusec/nucleus/src/master/) was broken due to change in the API of the library `Binary File Descriptor`.

#### Issue 1

The function `bfd_octets_per_byte` is now different and it need to know the section of the binary whose we want to retrieve the number of octets per byte, thus we wrote a function to retrieve the section given the virtual memory address:

```c
asection *get_section_by_vma(const bfd *bfd_h, const uint64_t vma)
{
  for (asection *bfd_sec = bfd_h->sections; bfd_sec->next != bfd_h->section_last->next; bfd_sec = bfd_sec->next)
  {
    if (bfd_sec->vma <= vma && bfd_sec->vma + bfd_sec->size > vma)
      return bfd_sec;
  }

  // section not found!
  return nullptr;
}
```

then to fix the issue:

```diff
- bfd_vma data_offset = bfd_reloc->address * bfd_octets_per_byte(bfd_h);
+asection *bfd_sec = get_section_by_vma(bfd_h, sec.vma);
+if (bfd_sec == NULL)
+{
+   print_err("failed to get section from vma");
+   goto fail;
+}
+bfd_vma data_offset = bfd_reloc->address * bfd_octets_per_byte(bfd_h, bfd_sec);
+bfd_byte *data = sec.bytes + (data_offset - sec.vma);
```

#### Issue 2

In [loader.cc](./src/loader.cc) function `load_sections_bfd` doesn't need the first parameter:

```diff
- bfd_flags = bfd_get_section_flags(bfd_h, bfd_sec);
+ bfd_flags = bfd_section_flags(bfd_sec);
```

#### Issue 3

In [loader.cc](./src/loader.cc) function `load_sections_bfd` the following functions doesn't need the first parameter:

```diff
- vma = bfd_section_vma(bfd_h, bfd_sec);
- size = bfd_section_size(bfd_h, bfd_sec);
- secname = bfd_section_name(bfd_h, bfd_sec);
+ vma = bfd_section_vma(bfd_sec);
+ size = bfd_section_size(bfd_sec);
+ secname = bfd_section_name(bfd_sec);
```

### Raw files support

The support for raw file was already present in `nucleus`, even though it uses a very simple approach since it just disassemles from the start of the file (or at a given offset chosen by the user).
Our goal was to try to improve this technique to make `nucleus` able to find the best offset to start disassebling the file.

The very first thing we've done was to try to understand how the tool works, especially focusing on the disassemblying phase. To do so, we've instrumented the program in order to log information to see the flow of the program using the format `[DBG..] blablabla` so that grepping on `DBG` show us only the info that we need.
In order to enable the loggin it's just needed to set `DBG` to `1` in [disasm-x86.cc](./src/disasm-x86.cc) and in [disasm.cc](/src/disasm.cc).

<!-- TODO explain a bit how the disassembling works -->

Since the option to start disassembling at a given offset was already present, we tried to see if changing the offset makes `nucleus` to perform better. Using the [script test_offset.py](./utilities/test_offset.py) we collected the number of offsets that succesfully find each function.
The script showed us that changing the offset almost doesn't affect the result of `nucleus` because almost all the functions have been found running `nucleus` at every offset. This suggests us that the disassembling process probably realignes very fast.

<!-- TODO explain better -->

Nevertheless, we added the option `-o` in `nucleus` in order to make it trying to disassemble at a different number of offset and collect information about the number of offset that find each function. Exactly the same ad the previous python script, but now embedded in `nucleus`.

<!-- TODO add a screnshoot of the output -->

### Evaluating different architectures performance

To evaluate the performance of nucleus over different architectures, a database of binaries present at [https://github.com/Cisco-Talos/binary_function_similarity](https://github.com/Cisco-Talos/binary_function_similarity) has been exploited.
We've tried to embedd the [script](https://github.com/Cisco-Talos/binary_function_similarity/blob/main/gdrive_download.py) to download the binaries in our project to easily populate our [binaries folder](./test/binaries/) by running the command `make download`.
A subset of the database has been used to execute the test. The list of the used binaries is present [here](./test/binaries_list.txt), it is basically the list of the binaries belonging to the training subset used in [this project](https://github.com/Cisco-Talos/binary_function_similarity). A ground truth has been extracted from the information present in the same project using the [script](./test/scripts/extract_ground_truth.sh) on the file `binary_function_similarity/DBs/Dataset-1/training_Dataset-1.csv`, we haven't made it easily reproducible since we've run this script only once, and the extracted ground truth is available [here](./test/ground_truth/).
The extracted ground truth is basically a collection of files grouped by different architectures that contains the pairs (`function name`, `start address`).

<!-- TODO write something about the ground truth extracted using readelf -->

At this point, we have all the information we need to test nucleus using the binaries and the relative ground truth. The script [test.sh](./utilities/test.sh) compares the result of `nucleus` and the ground truth, it counts:

- the number of functions found by nucleus that are present in the ground truth
- the number of functions present in the grount truth but not found by nucleus
- the number of functions found by nucleus that are not present in the ground truth

these information are then stored by the script in the file [results.csv](./test/results.csv) with the following format:

| arch  | binary                       | tested | found_count | not_found_count | false_positives |
| ----- | ---------------------------- | ------ | ----------- | --------------- | --------------- |
| arm32 | arm32-clang-3.5-O0_afalg.so  | yes    | 0           | 1               | 41              |
| arm32 | arm32-clang-3.5-O0_curl      | yes    | 121         | 1               | 1057            |
| arm32 | arm32-clang-3.5-O0_dasync.so | yes    | 2           | 0               | 27              |

the script can be execute by typing `make test`.

<!-- TODO continue... -->

---

## Makefile commands

- `make` : build nucleus
- `build_simple_test` : build the programs in the folder `./test/simple_tests`
- `simple_test` : execute `cmp_symbols.sh` on the simple_test binaries
- `test` : run `./utilities/test.sh` on the binaries in `./test/binaries`
- `generate_raw_files` : generate a dataset of raw files starting from the binaries in `./test/binaries`
- `test_raw` : run `./utilities/test_raw.s` over the raw files generated by `generate_raw_files`
- `download_all` : download ~3000 binaries in `./test/binaries` (**WARNING**: it takes time and space on the disk)
- `clean` : remove the intermediate object files, the nucleus binary and the simple_test binaries. It does not touch the binaries in `./test/binaries`

---

## Nucleus Usage

### Container Build

In order to avoid wasting time with various dependencies, it's possible to build a docker container using the [Dockerfile](./Dockerfile).

- to build : `docker build -t nucleos .`
- to run: `docker run -it nucleos`

Please note that this repository contains only a subset(~100) of all the binaries(~3000) that we've used to run the tests, then same for the container.
If you want to reproduce the test on all the binaries, just run `make download_all`, and then `make test`. Be aware that this operation is **very time and memory consuming**.

### Commands and Options

```
nucleus disassembler v0.65
Copyright (C) 2016, 2017 Dennis Andriesse, Vrije Universite\it Amsterdam

./nucleus [-vwhtafbDpgi] -e <binary> -d <strategy>
  -e <binary>
     : target binary
  -d <strategy>
     : select disassembly strategy
         linear       Linear disassembly
         recursive    Recursive disassembly (incomplete implementation, not recommended)
  -t <binary format>
     : hint on binary format (may be ignored)
         auto         Try to automatically determine binary format (default)
         raw          Raw binary (memory dump, ROM, network capture, ...)
         elf          Unix ELF
         pe           Windows PE
  -a <arch>
     : disassemble as specified instruction architecture (only for raw binaries)
         auto         Try to automatically determine architecture (default)
         aarch64      aarch64 (experimental)
         arm          arm (experimental)
         mips         mips (experimental)
         ppc          ppc: Specify ppc-32 or ppc-64 (default ppc-64, experimental)
         x86          x86: Specify x86-16, x86-32 or x86-64 (default x86-64)
  -f : produce list of function entry points and sizes
  -b <vma>
     : binary base vma (only for raw binaries)
  -D : disassemble data sections as code
  -p : allow privileged instructions
  -g <file>
     : export CFG to graphviz dot file
  -i <file>
     : export binary info to IDA Pro script
  -n <file>
     : export binary info to Binary Ninja script
  -o : <n_offset> try at n_offset different offsets from the binary base vma (only for raw binaries)
  -v : verbose
  -w : disable warnings
  -h : help
```

The `-o <n_offset>` option has been added by us for the implementation of the [raw files support](#raw-files-support), it makes nucleus executing the whole analysis `n_offset` times, each time starting from the next offset. The first offset can be chosen using the option `-b <vma>`. Over each iteration, nucleus count the number of offsets that find each function. Afterwards, a score is assigned to the functions found over all the iterations using the following equation : $score = N\_{offsetsfunction}/N\_{offsets} $ where _N_offsetsfunction_ is the number of offsets that find the functions. In this way, it is easier to spot functions that has been found only when the disassembler doesn't realign.

![](./images/screen_nucleus_raw.png)