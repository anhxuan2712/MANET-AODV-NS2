

from pathlib import Path
import csv

folder = Path(r"D:\trace\raw")
output = Path(r"D:\trace\ket_qua_PDR.csv")

results = []

for file in sorted(folder.glob("*.tr")):
    sent = set()
    received = set()

    with file.open("r", errors="ignore") as f:
        for line in f:
            d = line.split()

            if len(d) <= 17:
                continue

            if d[3] != "AGT" or d[6] != "cbr":
                continue

            key = (d[5], d[17])

            if d[0] == "s":
                sent.add(key)
            elif d[0] == "r":
                received.add(key)

    received_valid = sent & received

    total_sent = len(sent)
    total_received = len(received_valid)

    pdr = total_received / total_sent * 100 if total_sent else 0
    loss = 100 - pdr

    results.append({
        "File": file.name,
        "Sent": total_sent,
        "Received": total_received,
        "PDR_percent": round(pdr, 4),
        "PacketLoss_percent": round(loss, 4)
    })

    print(file.name)
    print("Sent:", total_sent)
    print("Received:", total_received)
    print("PDR:", round(pdr, 4), "%")
    print("Packet Loss:", round(loss, 4), "%")
    print("----------------------")

with output.open("w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(f, fieldnames=results[0].keys())
    writer.writeheader()
    writer.writerows(results)

print("Da luu:", output)
