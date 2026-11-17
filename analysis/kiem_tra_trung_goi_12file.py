
from pathlib import Path
from collections import Counter

folder = Path(r"D:\trace\raw")

for file in sorted(folder.glob("trace_sc*_run*.tr")):
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

            key = (data[5], data[17].strip("[]"))

            if data[0] == "s":
                sent[key] += 1
            else:
                received[key] += 1

    duplicate_sent = sum(v > 1 for v in sent.values())
    duplicate_received = sum(v > 1 for v in received.values())

    print(
        file.name,
        "| Gui trung:", duplicate_sent,
        "| Nhan trung:", duplicate_received
    )
