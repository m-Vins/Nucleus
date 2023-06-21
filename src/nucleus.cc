#include <stdio.h>

#include <list>
#include <string>

#include "nucleus.h"
#include "disasm.h"
#include "cfg.h"
#include "loader.h"
#include "util.h"
#include "exception.h"
#include "options.h"
#include "export.h"
#include "log.h"

int main(int argc, char *argv[])
{
  size_t i;
  Binary bin;
  Section *sec;
  Symbol *sym;
  // this will contain the disassembled code
  std::list<DisasmSection> disasm;
  CFG cfg;

  set_exception_handlers();

  if (parse_options(argc, argv) < 0)
  {
    return 1;
  }

  if (load_binary(options.binary.filename, &bin, options.binary.type) < 0)
  {
    return 1;
  }

  verbose(1, "loaded binary '%s' %s/%s (%u bits) entry@0x%016jx",
          bin.filename.c_str(),
          bin.type_str.c_str(), bin.arch_str.c_str(),
          bin.bits, bin.entry);
  // when the file is raw, we only have one section, marked as code:
  // bin->sections.push_back(Section());
  // sec = &bin->sections.back();
  // sec->binary = bin;
  // sec->name = std::string("raw");
  // sec->type = Section::SEC_TYPE_CODE;
  for (i = 0; i < bin.sections.size(); i++)
  {
    sec = &bin.sections[i];
    verbose(1, "  0x%016jx %-8ju %-20s %s",
            sec->vma, sec->size, sec->name.c_str(),
            sec->type == Section::SEC_TYPE_CODE ? "CODE" : "DATA");
  }
  // for raw files, this will be false (skip)
  if (bin.symbols.size() > 0)
  {
    verbose(1, "scanned symbol tables");
    for (i = 0; i < bin.symbols.size(); i++)
    {
      sym = &bin.symbols[i];
      verbose(1, "  %-40s 0x%016jx %s",
              sym->name.c_str(), sym->addr,
              (sym->type & Symbol::SYM_TYPE_FUNC) ? "FUNC" : "");
    }
  }

  if (options.offs_n > 0)
  {
    std::map<uint64_t, uint64_t> functions_occurrences;

    for (int i = 0; i < options.offs_n; i++)
    {
      // Check if the file is raw
      if (options.binary.type != Binary::BIN_TYPE_RAW)
      {
        printf("ERROR: Option -o valid for raw files only\n");
        return -1;
      }

      verbose(1, "disasm from offset: %ld\n", bin.sections[0].vma);
      if (nucleus_disasm(&bin, &disasm) < 0)
      {
        return 1;
      }

      if (cfg.make_cfg(&bin, &disasm) < 0)
      {
        return 1;
      }

      // Loop over all the functions that have been found disasming from the
      // current offset, then update functions_occurrences to keep track of
      // the number of offset at which the given function has been found
      for (auto &f : cfg.functions)
      {

        BB *entry_bb = f.entry.front();
        unsigned offset = 0;

        for (auto &e : entry_bb->ancestors)
        {
          if (e.type == Edge::EDGE_TYPE_CALL)
            offset = e.offset;
        }

        uint64_t function_start = entry_bb->start + offset - i;
        if (functions_occurrences.find(function_start) == functions_occurrences.end())
        {
          functions_occurrences[function_start] = 0;
        }
        functions_occurrences[function_start]++;
      }

      bin.sections[0].vma++;
      cfg.clear_cfg();
      disasm.clear();
    }

    printf("start address\t\toccurrencies\n");
    printf("---------------------------------------\n");
    for (const auto &pair : functions_occurrences)
    {
      printf("0x%016jx\t%ld\n", pair.first, pair.second);
    }

    return 0;
  }

  if (nucleus_disasm(&bin, &disasm) < 0)
  {
    return 1;
  }

  if (cfg.make_cfg(&bin, &disasm) < 0)
  {
    return 1;
  }

  if (options.summarize_functions)
  {
    cfg.print_function_summaries(stdout);
  }
  else
  {
    fprintf(stdout, "\n");
    for (auto &dis : disasm)
    {
      dis.print_BBs(stdout);
    }
    cfg.print_functions(stdout);
  }

  if (!options.exports.ida.empty())
  {
    (void)export_bin2ida(options.exports.ida, &bin, &disasm, &cfg);
  }
  if (!options.exports.binja.empty())
  {
    (void)export_bin2binja(options.exports.binja, &bin, &disasm, &cfg);
  }
  if (!options.exports.dot.empty())
  {
    (void)export_cfg2dot(options.exports.dot, &cfg);
  }

  unload_binary(&bin);

  return 0;
}
