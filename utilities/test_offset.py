#!/usr/bin/python3

import subprocess
import os
import sys

REPO_PATH = os.path.dirname(os.path.abspath(__file__+ '/..'))

# Set the range of numbers
start = 1
end = 256
target = sys.argv[1]

addresses = dict()

# Loop through the range
for offset in range(start, end):
    # MAKE SURE DBG = 1
    res = subprocess.run(f"{REPO_PATH}/nucleus -e {target} -d linear -f -a x86 -t raw -f -b {offset}| grep -v DBG", shell=True, capture_output=True)

    output = res.stdout.decode()
    functions = output.split("\n")

    for function in functions[:-1] :
        address = function.split("\t")[0]

        address_int = int(address, 16)
        address_int -= offset

        if address_int in addresses :
            addresses[address_int].append(offset)
        else:
            addresses[address_int] = [offset]


print("OFFSET\t\tCOUNTER")
print("-"*50)
for address, offset in addresses.items():
    print(f"{hex(address)}\t\t{len(offset)}")
