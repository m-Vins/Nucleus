# Nucleus Forensics Project

## Artifacts

<!-- TODO ## Makefile commands explanation -->

## Reorganization of the directory tree

<!-- TODO -->

## Fixing the tool

The [source code](https://bitbucket.org/vusec/nucleus/src/master/) was broken due to change in the API of the library `Binary File Descriptor`.

### Issue 1

The function `bfd_octets_per_byte` is now different and it need to know the section of the binary whose we want to retrieve the number of octets per byte, this we wrote a function to retrieve the section given the virtual memory address:

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

### Issue 2

In [loader.cc](./src/loader.cc) function `load_sections_bfd` doesn't need the first parameter:

```diff
- bfd_flags = bfd_get_section_flags(bfd_h, bfd_sec);
+ bfd_flags = bfd_section_flags(bfd_sec);
```

### Issue 3

In [loader.cc](./src/loader.cc) function `load_sections_bfd` the following functions doesn't need the first parameter:

```diff
- vma = bfd_section_vma(bfd_h, bfd_sec);
- size = bfd_section_size(bfd_h, bfd_sec);
- secname = bfd_section_name(bfd_h, bfd_sec);
+ vma = bfd_section_vma(bfd_sec);
+ size = bfd_section_size(bfd_sec);
+ secname = bfd_section_name(bfd_sec);
```

## Raw files support

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

## Test on different architectures

<!-- TODO -->
