
from pathlib import Path
from collections import Counter

folder = Path(r"D:\trace\raw")

for file in sorted(folder.glob("*.tr")):
    sent = Counter()
    received = Counter()

    with file.open("r", errors="ignore") as f:
        for line in f:
            d = line.split()

            if len(d) <= 17:
                continue

            if d[3] == "AGT" and d[6] == "cbr":
                key = (d[5], d[17])

                if d[0] == "s":
                    sent[key] += 1
                elif d[0] == "r":
                    received[key] += 1

    duplicate_sent = sum(v - 1 for v in sent.values() if v > 1)
    duplicate_received = sum(v - 1 for v in received.values() if v > 1)
    unmatched_received = len(set(received) - set(sent))

    print(file.name)
    print("Gui trung:", duplicate_sent)
    print("Nhan trung:", duplicate_received)
    print("Goi nhan khong co goi gui:", unmatched_received)
    print("-------------------------")
