import subprocess
import os

# Set the range of numbers
start = 1
end = 500
target = "./test/bin/test1"

addresses = dict()

# Loop through the range
for offset in range(start, end):
    res = subprocess.run(f"./nucleus -e {target} -d linear -f -a x86 -t raw -f -b {offset}| grep -v DBG", shell=True, capture_output=True)

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



for key, value in addresses.items():
    print(key, "->", len(value))
