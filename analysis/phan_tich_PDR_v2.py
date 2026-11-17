
from pathlib import Path
from collections import defaultdict
import csv

folder = Path(r"D:\trace\raw")
output = Path(r"D:\trace\ket_qua_PDR_v2.csv")

files = sorted(folder.glob("trace_sc*_run*.tr"))

results = []

for file in files:
    sent = set()
    received = set()

    with file.open("r", errors="ignore") as f:
        for line in f:
            data = line.split()

            if len(data) < 18:
                continue

            if data[3] != "AGT" or data[6] != "cbr":
                continue

            flow_id = data[5]
            sequence = data[17].strip("[]")

            packet_id = (flow_id, sequence)

            if data[0] == "s":
                sent.add(packet_id)

            elif data[0] == "r":
                received.add(packet_id)

    total_sent = len(sent)
    total_received = len(sent & received)
    lost = total_sent - total_received

    pdr = (
        total_received / total_sent * 100
        if total_sent > 0 else 0
    )

    loss_rate = (
        lost / total_sent * 100
        if total_sent > 0 else 0
    )

    results.append({
        "File": file.name,
        "Sent": total_sent,
        "Received": total_received,
        "Lost": lost,
        "PDR_percent": round(pdr, 4),
        "Packet_Loss_percent": round(loss_rate, 4)
    })

with output.open("w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=[
            "File", "Sent", "Received", "Lost",
            "PDR_percent", "Packet_Loss_percent"
        ]
    )
    writer.writeheader()
    writer.writerows(results)

print("KET QUA PDR VA PACKET LOSS:")

for row in results:
    print(row)

print("\nDa luu:", output)
