from pathlib import Path
from collections import defaultdict

file = Path(r"D:\trace\raw\trace_sc01_run01.tr")

thong_ke = defaultdict(lambda: defaultdict(int))
reply_lines = []

with file.open("r", errors="ignore") as f:
    for line in f:
        data = line.split()

        if len(data) < 10:
            continue

        if data[3] == "RTR" and data[6] == "AODV":
            time = float(data[1])

            if 8 <= time <= 21:
                event = data[0]
                packet_type = data[-1].strip("()")

                thong_ke[int(time)][(packet_type, event)] += 1

                if packet_type == "REPLY":
                    reply_lines.append(line.strip())

print("THONG KE AODV THEO TUNG GIAY:")

for second in sorted(thong_ke):
    print(f"\nGiay {second}:")
    for (packet_type, event), number in thong_ke[second].items():
        print(f"  {packet_type} - {event}: {number}")

print("\nTAT CA CAC SU KIEN AODV REPLY:")

for line in reply_lines:
    print(line)