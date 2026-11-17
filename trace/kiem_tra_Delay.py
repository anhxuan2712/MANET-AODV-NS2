
from pathlib import Path

file = Path(r"D:\trace\raw\trace_sc01_run01.tr")

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
        packet_id = (data[5], data[17].strip("[]"))

        if event == "s":
            sent_time[packet_id] = time

        elif event == "r" and packet_id in sent_time:
            delay = time - sent_time[packet_id]

            if delay >= 0:
                delays.append((delay, packet_id,
                               sent_time[packet_id], time))

            del sent_time[packet_id]

delays.sort(reverse=True)

print("SO GOI DA TINH:", len(delays))
print("DELAY TRUNG BINH:",
      sum(x[0] for x in delays) / len(delays))

print("\n10 GOI CO DELAY LON NHAT:")

for item in delays[:10]:
    print(item)
