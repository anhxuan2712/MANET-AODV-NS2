

from pathlib import Path
import csv

folder = Path(r"D:\trace\raw")
output = Path(r"D:\trace\ket_qua_Delay.csv")

results = []

for file in sorted(folder.glob("*.tr")):
    sent = {}
    received = {}

    with file.open("r", errors="ignore") as f:
        for line in f:
            d = line.split()

            if len(d) <= 17:
                continue

            if d[3] != "AGT" or d[6] != "cbr":
                continue

            key = (d[5], d[17])
            time = float(d[1])

            if d[0] == "s":
                sent[key] = time
            elif d[0] == "r":
                received[key] = time

    delays = []

    for key in sent:
        if key in received:
            delay = received[key] - sent[key]

            if delay >= 0:
                delays.append(delay)

    avg_delay = sum(delays) / len(delays) if delays else 0
    max_delay = max(delays) if delays else 0
    min_delay = min(delays) if delays else 0

    results.append({
        "File": file.name,
        "Received_Packets": len(delays),
        "Average_Delay_s": round(avg_delay, 6),
        "Min_Delay_s": round(min_delay, 6),
        "Max_Delay_s": round(max_delay, 6)
    })

    print(file.name)
    print("So goi nhan:", len(delays))
    print("Delay trung binh:", round(avg_delay, 6), "s")
    print("Delay nho nhat:", round(min_delay, 6), "s")
    print("Delay lon nhat:", round(max_delay, 6), "s")
    print("-------------------------")

with output.open("w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(f, fieldnames=results[0].keys())
    writer.writeheader()
    writer.writerows(results)

print("Da luu:", output)
