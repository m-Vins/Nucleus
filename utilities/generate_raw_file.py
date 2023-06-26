import sys
import random
from elftools.elf.elffile import ELFFile

def extract_code_section_from_elf(elf_path):
    with open(elf_path, 'rb') as f:
        elf = ELFFile(f)

        # Find the code section by name
        section = elf.get_section_by_name('.text')
        if section is None:
            raise ValueError("Code section (.text) not found in the ELF file.")
        
        # Get the offset of the section
        section_offset = section['sh_offset']
        print(f"Offset of the code section: {section_offset}")

        # Extract the section data
        return section.data()


def write_raw_file(section_data, output_path, random_data_size):
    with open(output_path, 'wb') as output_file:
        # generating random data
        random_data = bytearray(random.getrandbits(8) for _ in range(random_data_size))
        # Write random data 
        output_file.write(random_data)
        # Write the section data to the output file
        output_file.write(section_data)


        

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 extract_code_section.py <elf_file_path> <output_file_path> <offset>")
        sys.exit(1)

    elf_path = sys.argv[1]
    output_path = sys.argv[2]
    offset = int(sys.argv[3])

    section_data = extract_code_section_from_elf(elf_path)
    write_raw_file(section_data,output_path,offset)