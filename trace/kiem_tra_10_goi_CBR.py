from pathlib import Path

file = Path(r"D:\trace\raw\trace_sc01_run01.tr")

target_flows = {
    "72", "81", "91", "101", "111",
    "121", "131", "141", "151", "161"
}

print("CAC SU KIEN CUA 10 GOI CBR:")

with file.open("r", errors="ignore") as f:
    for line in f:
        data = line.split()

        if len(data) < 18:
            continue

        # Lọc theo Flow ID và Sequence Number
        if data[5] in target_flows and data[6] == "cbr":
            time = float(data[1])

            if 8 <= time <= 21:
                print(line.strip())