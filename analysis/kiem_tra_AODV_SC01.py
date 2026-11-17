
from pathlib import Path

p = Path(r"D:\trace\raw\trace_sc01_run01.tr")

print("CAC SU KIEN AODV TU 9 DEN 21 GIAY:")

with p.open("r", errors="ignore") as f:
    for line in f:
        d = line.split()

        if len(d) < 8:
            continue

        if d[3] == "RTR" and d[6] == "AODV":
            time = float(d[1])

            if 9 <= time <= 21:
                print(line.strip())
