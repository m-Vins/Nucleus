# Nucleus Forensics Project

## Artifacts

## Fixing the tool

The [source code](https://bitbucket.org/vusec/nucleus/src/master/) was broken due to change in the API of the library `Binary File Descriptor`.

### Issue 1

To fix the problem -> created:

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

then

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

In [loader.cc](./src/loader.cc) function `load_sections_bfd`

```diff
- bfd_flags = bfd_get_section_flags(bfd_h, bfd_sec);
+ bfd_flags = bfd_section_flags(bfd_sec);
```

### Issue 3

In [loader.cc](./src/loader.cc) function `load_sections_bfd`

```diff
- vma = bfd_section_vma(bfd_h, bfd_sec);
- size = bfd_section_size(bfd_h, bfd_sec);
- secname = bfd_section_name(bfd_h, bfd_sec);
+ vma = bfd_section_vma(bfd_sec);
+ size = bfd_section_size(bfd_sec);
+ secname = bfd_section_name(bfd_sec);
```

## Raw files support

## Test on different architectures
