
from pathlib import Path
from collections import Counter

file = Path(r"D:\trace\raw\trace_sc01_run01.tr")

sent = Counter()
received = Counter()

with file.open("r", errors="ignore") as f:
    for line in f:
        data = line.split()

        if len(data) < 18:
            continue

        if data[3] != "AGT" or data[6] != "cbr":
            continue

        if data[0] not in ("s", "r"):
            continue

        packet_id = (data[5], data[17].strip("[]"))

        if data[0] == "s":
            sent[packet_id] += 1
        else:
            received[packet_id] += 1

print("SO KHOA GUI:", len(sent))
print("SO KHOA NHAN:", len(received))

print("KHOA GUI BI TRUNG:",
      sum(1 for x in sent.values() if x > 1))

print("KHOA NHAN BI TRUNG:",
      sum(1 for x in received.values() if x > 1))

print("\n10 KHOA GUI TRUNG NHIEU NHAT:")
for key, count in sent.most_common(10):
    if count > 1:
        print(key, ":", count)
