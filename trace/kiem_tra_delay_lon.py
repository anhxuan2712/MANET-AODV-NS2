
from pathlib import Path

p = Path(r"D:\trace\raw\trace_sc01_run01.tr")

sent = {}
received = {}

with p.open("r", errors="ignore") as f:
    for line in f:
        d = line.split()

        if len(d) <= 17:
            continue

        if d[3] != "AGT" or d[6] != "cbr":
            continue

        key = (d[5], d[17])
        time = float(d[1])

        if d[0] == "s":
            sent[key] = (time, d[2])
        elif d[0] == "r":
            received[key] = (time, d[2])

delays = []

for key in sent:
    if key in received:
        delay = received[key][0] - sent[key][0]

        if delay >= 0:
            delays.append((
                delay, key,
                sent[key][0], sent[key][1],
                received[key][0], received[key][1]
            ))

delays.sort(reverse=True)

print("5 GOI CO DELAY LON NHAT:")

for item in delays[:5]:
    delay, key, send_time, send_node, recv_time, recv_node = item

    print("-------------------------")
    print("Flow ID, Sequence:", key)
    print("Node gui:", send_node)
    print("Node nhan:", recv_node)
    print("Thoi diem gui:", send_time)
    print("Thoi diem nhan:", recv_time)
    print("Delay:", round(delay, 6), "giay")
