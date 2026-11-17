from pathlib import Path
from collections import Counter

file = Path(r"D:\trace\raw\trace_sc01_run01.tr")

types = Counter()

with file.open("r", errors="ignore") as f:
    for line in f:
        data = line.split()

        if len(data) < 8:
            continue

        if data[3] == "RTR" and data[6] == "AODV":
            if data[0] == "s":
                packet_type = data[-1].strip("()")
                types[packet_type] += 1

print("CAC LOAI GOI AODV DUOC GUI:")

for name, number in types.items():
    print(name, ":", number)