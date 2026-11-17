
from pathlib import Path
import csv

folder = Path(r"D:\trace\raw")
files = sorted(folder.glob("*.tr"))

PACKET_SIZE = 512  # Bytes payload

results = []

for file in files:
    first_send = None
    last_receive = None
    received = 0

    with file.open("r", errors="ignore") as f:
        for line in f:
            data = line.split()

            if len(data) < 8:
                continue

            event = data[0]
            time = float(data[1])
            layer = data[3]
            packet = data[6]

            if layer != "AGT" or packet != "cbr":
                continue

            if event == "s":
                if first_send is None or time < first_send:
                    first_send = time

            elif event == "r":
                received += 1

                if last_receive is None or time > last_receive:
                    last_receive = time

    if first_send is None or last_receive is None:
        print("Khong du du lieu:", file.name)
        continue

    duration = last_receive - first_send

    if duration <= 0:
        continue

    total_bytes = received * PACKET_SIZE

    throughput = total_bytes * 8 / duration / 1000

    results.append({
        "File": file.name,
        "Received_Packets": received,
        "Total_Bytes": total_bytes,
        "Duration_s": round(duration, 6),
        "Throughput_Kbps": round(throughput, 4)
    })

if results:
    output = Path(r"D:\trace\ket_qua_Throughput.csv")

    with output.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(
            f, fieldnames=results[0].keys()
        )
        writer.writeheader()
        writer.writerows(results)

    print("DA HOAN THANH!")
    print("So file da xu ly:", len(results))

    for item in results:
        print(item)

    print("Da luu:", output)

else:
    print("Khong co du lieu hop le!")
