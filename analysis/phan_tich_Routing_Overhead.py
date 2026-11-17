
from pathlib import Path
from collections import Counter
import csv

folder = Path(r"D:\trace\raw")
output = Path(r"D:\trace\ket_qua_Routing_Overhead.csv")

files = sorted(folder.glob("trace_sc*_run*.tr"))

results = []

for file in files:
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

    total = sum(types.values())

    results.append({
        "File": file.name,
        "REQUEST": types["REQUEST"],
        "REPLY": types["REPLY"],
        "ERROR": types["ERROR"],
        "HELLO": types["HELLO"],
        "Total_AODV": total
    })

with output.open("w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=[
            "File", "REQUEST", "REPLY",
            "ERROR", "HELLO", "Total_AODV"
        ]
    )
    writer.writeheader()
    writer.writerows(results)

print("KET QUA ROUTING OVERHEAD:")

for row in results:
    print(
        row["File"],
        "| REQUEST:", row["REQUEST"],
        "| REPLY:", row["REPLY"],
        "| ERROR:", row["ERROR"],
        "| HELLO:", row["HELLO"],
        "| TONG:", row["Total_AODV"]
    )

print("\nDa luu ket qua tai:", output)
