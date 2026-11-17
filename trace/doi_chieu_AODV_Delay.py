from pathlib import Path
from collections import Counter

file = Path(r"D:\trace\raw\trace_sc01_run01.tr")

aodv_count = Counter()
aodv_samples = []

# Các gói CBR có Delay lớn đã phát hiện
target_flows = {"72", "81", "91", "101", "111",
                "121", "131", "141", "151", "161"}

print("CAC GOI CBR CAN DOI CHIEU:")

with file.open("r", errors="ignore") as f:
    for line in f:
        data = line.split()

        if len(data) < 18:
            continue

        time = float(data[1])

        # In các gói CBR thuộc 10 Flow có Delay lớn
        if (data[3] == "AGT" and data[6] == "cbr"
                and data[5] in target_flows
                and 8 <= time <= 21):

            print(line.strip())

        # Thống kê gói điều khiển AODV từ 8 đến 21 giây
        if (data[3] == "RTR" and data[6] == "AODV"
                and 8 <= time <= 21):

            packet_type = data[-1].strip("()")
            aodv_count[packet_type] += 1

            if len(aodv_samples) < 30:
                aodv_samples.append(line.strip())

print("\nTHONG KE AODV TU 8 DEN 21 GIAY:")

for name, number in aodv_count.items():
    print(name, ":", number)

print("\n30 DONG AODV DAU TIEN:")

for line in aodv_samples:
    print(line)