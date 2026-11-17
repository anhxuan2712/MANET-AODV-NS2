
from pathlib import Path
import csv

folder = Path(r"D:\trace\raw")
output = Path(r"D:\trace\ket_qua_Delay_v2.csv")

files = sorted(folder.glob("trace_sc*_run*.tr"))

results = []

for file in files:
    sent_time = {}
    delays = []

    with file.open("r", errors="ignore") as f:
        for line in f:
            data = line.split()

            if len(data) < 18:
                continue

            if data[3] != "AGT" or data[6] != "cbr":
                continue

            event = data[0]
            time = float(data[1])
            flow_id = data[5]
            sequence = data[17].strip("[]")

            packet_id = (flow_id, sequence)

            if event == "s":
                sent_time[packet_id] = time

            elif event == "r":
                if packet_id in sent_time:
                    delay = time - sent_time[packet_id]

                    if delay >= 0:
                        delays.append(delay)

                    # Xoa de tranh tinh trung mot goi
                    del sent_time[packet_id]

    received = len(delays)

    average_delay = (
        sum(delays) / received
        if received > 0 else 0
    )

    results.append({
        "File": file.name,
        "Received_Packets": received,
        "Average_Delay_s": round(average_delay, 9)
    })

with output.open("w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=[
            "File",
            "Received_Packets",
            "Average_Delay_s"
        ]
    )
    writer.writeheader()
    writer.writerows(results)

print("KET QUA AVERAGE END-TO-END DELAY:")

for row in results:
    print(row)

print("\nDa luu:", output)
