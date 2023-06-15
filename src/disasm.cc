#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#include <vector>
#include <list>
#include <map>
#include <queue>
#include <algorithm>

#include <capstone/capstone.h>

#include "loader.h"
#include "bb.h"
#include "disasm.h"
#include "strategy.h"
#include "util.h"
#include "options.h"
#include "log.h"

#include "disasm-aarch64.h"
#include "disasm-arm.h"
#include "disasm-mips.h"
#include "disasm-ppc.h"
#include "disasm-x86.h"

/*******************************************************************************
 **                              DisasmSection                                **
 ******************************************************************************/
void DisasmSection::print_BBs(FILE *out)
{
  fprintf(out, "<Section %s %s @0x%016jx (size %ju)>\n\n",
          section->name.c_str(), (section->type == Section::SEC_TYPE_CODE) ? "C" : "D",
          section->vma, section->size);
  sort_BBs();
  for (auto &bb : BBs)
  {
    bb.print(out);
  }
}

void DisasmSection::sort_BBs()
{
  BBs.sort(BB::comparator);
}

/*******************************************************************************
 **                                AddressMap                                 **
 ******************************************************************************/
void AddressMap::insert(uint64_t addr)
{
  if (!contains(addr))
  {
    unmapped.push_back(addr);
    unmapped_lookup[addr] = unmapped.size() - 1;
  }
}

bool AddressMap::contains(uint64_t addr)
{
  return addrmap.count(addr) || unmapped_lookup.count(addr);
}

unsigned
AddressMap::get_addr_type(uint64_t addr)
{
  assert(contains(addr));
  if (!contains(addr))
  {
    return AddressMap::DISASM_REGION_UNMAPPED;
  }
  else
  {
    return addrmap[addr];
  }
}
unsigned AddressMap::addr_type(uint64_t addr) { return get_addr_type(addr); }

void AddressMap::set_addr_type(uint64_t addr, unsigned type)
{
  assert(contains(addr));
  if (contains(addr))
  {
    if (type != AddressMap::DISASM_REGION_UNMAPPED)
    {
      erase_unmapped(addr);
    }
    addrmap[addr] = type;
  }
}

void AddressMap::add_addr_flag(uint64_t addr, unsigned flag)
{
  assert(contains(addr));
  if (contains(addr))
  {
    if (flag != AddressMap::DISASM_REGION_UNMAPPED)
    {
      erase_unmapped(addr);
    }
    addrmap[addr] |= flag;
  }
}

size_t
AddressMap::unmapped_count()
{
  return unmapped.size();
}

uint64_t
AddressMap::get_unmapped(size_t i)
{
  return unmapped[i];
}

void AddressMap::erase(uint64_t addr)
{
  if (addrmap.count(addr))
  {
    addrmap.erase(addr);
  }
  erase_unmapped(addr);
}

void AddressMap::erase_unmapped(uint64_t addr)
{
  size_t i;

  if (unmapped_lookup.count(addr))
  {
    if (unmapped_count() > 1)
    {
      i = unmapped_lookup[addr];
      unmapped[i] = unmapped.back();
      unmapped_lookup[unmapped.back()] = i;
    }
    unmapped_lookup.erase(addr);
    unmapped.pop_back();
  }
}

/*******************************************************************************
 **                            Disassembly engine                             **
 ******************************************************************************/
/**
 * This function loop over the sections of the file skipping the ones that
 * are not needed to be disassembled, and initializes the fields of the
 * added sections
 */
static int
init_disasm(Binary *bin, std::list<DisasmSection> *disasm)
{
  size_t i;
  uint64_t vma;
  Section *sec;
  DisasmSection *dis;

  // clear the list
  disasm->clear();
  for (i = 0; i < bin->sections.size(); i++)
  {
    // extract the current section
    sec = &bin->sections[i];

    // Check if the section is not a code section and,
    // if not restricted to code sections, it is also not a data section.
    if ((sec->type != Section::SEC_TYPE_CODE) && !(!options.only_code_sections && (sec->type == Section::SEC_TYPE_DATA)))
      continue;

    disasm->push_back(DisasmSection());
    dis = &disasm->back();

    dis->section = sec;
    for (vma = sec->vma; vma < (sec->vma + sec->size); vma++)
    {
      // insert the addresses in the addrmap
      dis->addrmap.insert(vma);
    }
  }
  verbose(1, "disassembler initialized");

  return 0;
}

static int
fini_disasm(Binary *bin, std::list<DisasmSection> *disasm)
{
  verbose(1, "disassembly complete");

  return 0;
}

static int
nucleus_disasm_bb(Binary *bin, DisasmSection *dis, BB *bb)
{
  switch (bin->arch)
  {
  case Binary::ARCH_AARCH64:
    return nucleus_disasm_bb_aarch64(bin, dis, bb);
  case Binary::ARCH_ARM:
    return nucleus_disasm_bb_arm(bin, dis, bb);
  case Binary::ARCH_MIPS:
    return nucleus_disasm_bb_mips(bin, dis, bb);
  case Binary::ARCH_PPC:
    return nucleus_disasm_bb_ppc(bin, dis, bb);
  case Binary::ARCH_X86:
    return nucleus_disasm_bb_x86(bin, dis, bb);
  default:
    print_err("disassembly for architecture %s is not supported", bin->arch_str.c_str());
    return -1;
  }
}

static int
nucleus_disasm_section(Binary *bin, DisasmSection *dis)
{
  int ret;
  unsigned i, n;
  uint64_t vma;
  double s;
  // basic block
  BB *mutants;
  std::queue<BB *> Q;

  mutants = NULL;

  // skipping non code section if only_code_section is true
  if ((dis->section->type != Section::SEC_TYPE_CODE) && options.only_code_sections)
  {
    print_warn("skipping non-code section '%s'", dis->section->name.c_str());
    return 0;
  }

  verbose(2, "disassembling section '%s'", dis->section->name.c_str());

  Q.push(NULL);
  while (!Q.empty())
  {
    // if we are running with linear disassembly, this function will actually be
    // (void *)bb_mutate_linear
    // if the previous BB is null, it starts disassembly from the beginning of the raw file
    // otherwise, if the end of the previous BB is still included in the VMA of the raw file,
    // the next BB is set after the end of the parent one
    // otherwise, BB is set to start=0 and end=0
    // n is either 0 or 1
    n = bb_mutate(dis, Q.front(), &mutants);
    // remove the parent we have just processed
    Q.pop();
    for (i = 0; i < n; i++)
    {
      // this function returns -1 when it fails booting the disassembler
      // overall, the disassembler simply linearly sweeps the instructions, until it finds an invalid one
      // OR a control flow instruction
      if (nucleus_disasm_bb(bin, dis, &mutants[i]) < 0)
      {
        goto fail;
      }
      // if we are running with linear disassembly, this function will actually be
      // (void *)bb_score_linear
      // always sets score to 1
      if ((s = bb_score(dis, &mutants[i])) < 0)
      {
        goto fail;
      }
    }
    // if we are running with linear disassembly, this function will actually be
    // (void *)bb_select_linear
    // this sets everyone to alive
    if ((n = bb_select(dis, mutants, n)) < 0)
    {
      goto fail;
    }
    for (i = 0; i < n; i++)
    {
      // always true
      if (mutants[i].alive)
      {
        // say that in that address a new BB is starting
        dis->addrmap.add_addr_flag(mutants[i].start, AddressMap::DISASM_REGION_BB_START);
        // for each decoded instruction
        for (auto &ins : mutants[i].insns)
        {
          // say that in that address a new instruction is starting
          dis->addrmap.add_addr_flag(ins.start, AddressMap::DISASM_REGION_INS_START);
        }
        for (vma = mutants[i].start; vma < mutants[i].end; vma++)
        {
          // mark the region as disassembled
          dis->addrmap.add_addr_flag(vma, AddressMap::DISASM_REGION_CODE);
        }
        // add the basic block to the list
        dis->BBs.push_back(BB(mutants[i]));
        Q.push(&dis->BBs.back());
      }
    }
  }

  ret = 0;
  goto cleanup;

fail:
  ret = -1;

cleanup:
  if (mutants)
  {
    delete[] mutants;
  }
  return ret;
}

int nucleus_disasm(Binary *bin, std::list<DisasmSection> *disasm)
{
  int ret;

  if (init_disasm(bin, disasm) < 0)
  {
    goto fail;
  }

  for (auto &dis : (*disasm))
  {
    if (nucleus_disasm_section(bin, &dis) < 0)
    {
      goto fail;
    }
  }

  if (fini_disasm(bin, disasm) < 0)
  {
    goto fail;
  }

  ret = 0;
  goto cleanup;

fail:
  ret = -1;

cleanup:
  return ret;
}
