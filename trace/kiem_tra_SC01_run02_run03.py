from pathlib import Path

files = [
    Path(r"D:\trace\raw\trace_sc01_run02.tr"),
    Path(r"D:\trace\raw\trace_sc01_run03.tr")
]

for file in files:
    print("\n" + "=" * 65)
    print("FILE:", file.name)
    print("=" * 65)

    sent = {}
    received = {}
    events = {}

    with file.open("r", errors="ignore") as f:
        for line in f:
            data = line.split()

            if len(data) < 18:
                continue

            if data[6] != "cbr":
                continue

            try:
                time = float(data[1])
            except ValueError:
                continue

            key = (data[5], data[17].strip("[]"))

            events.setdefault(key, []).append(line.strip())

            if data[3] == "AGT" and data[0] == "s":
                sent[key] = time

            elif data[3] == "AGT" and data[0] == "r":
                received[key] = time

    delays = []

    for key in sent:
        if key in received:
            delay = received[key] - sent[key]
            delays.append((delay, key))

    delays.sort(reverse=True)

    print("\n10 GOI CO DELAY LON NHAT:")

    for delay, key in delays[:10]:
        print(f"\nFlow {key[0]}, Sequence {key[1]}")
        print(f"Delay: {delay:.9f} giay")

        for line in sorted(
            events[key],
            key=lambda x: float(x.split()[1])
        ):
            print(line)