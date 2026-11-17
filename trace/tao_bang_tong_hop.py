
import csv
import re
from pathlib import Path
from statistics import mean
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

FOLDER = Path(r"D:\trace")

files = {
    "delay": "ket_qua_Delay_v2.csv",
    "pdr": "ket_qua_PDR_v2.csv",
    "throughput": "ket_qua_Throughput.csv",
    "routing": "ket_qua_Routing_Overhead.csv"
}

data = {}

# Doc va ghep 4 file CSV theo ten file trace
for metric, filename in files.items():
    with open(FOLDER / filename, encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            name = row["File"]
            if name not in data:
                data[name] = {"File": name}
            data[name].update(row)

# Chuyen cac gia tri so ve dang so
numeric_columns = [
    "Sent", "Received", "Lost", "PDR_percent",
    "Packet_Loss_percent", "Average_Delay_s",
    "Throughput_Kbps", "REQUEST", "REPLY",
    "ERROR", "HELLO", "Total_AODV"
]

for row in data.values():
    for col in numeric_columns:
        if col in row:
            row[col] = float(row[col])

# Sap xep theo SC01 -> SC04, Run01 -> Run03
rows = sorted(data.values(), key=lambda x: x["File"])

# Tao workbook
wb = Workbook()

# SHEET 1: CHI TIET 12 LAN CHAY
ws = wb.active
ws.title = "Chi tiet 12 lan chay"

headers = [
    "File", "Sent", "Received", "Lost",
    "PDR (%)", "Packet Loss (%)",
    "Delay (s)", "Throughput (Kbps)",
    "REQUEST", "REPLY", "ERROR", "HELLO",
    "Total AODV"
]
ws.append(headers)

for r in rows:
    ws.append([
        r["File"], r["Sent"], r["Received"], r["Lost"],
        r["PDR_percent"], r["Packet_Loss_percent"],
        r["Average_Delay_s"], r["Throughput_Kbps"],
        r["REQUEST"], r["REPLY"], r["ERROR"],
        r["HELLO"], r["Total_AODV"]
    ])

# SHEET 2: TRUNG BINH THEO KICH BAN
summary = wb.create_sheet("Trung binh kich ban")

summary_headers = [
    "Kich ban", "PDR trung binh (%)",
    "Packet Loss trung binh (%)",
    "Delay trung binh (s)",
    "Throughput trung binh (Kbps)",
    "So goi AODV trung binh"
]
summary.append(summary_headers)

for scenario in ["SC01", "SC02", "SC03", "SC04"]:
    group = [r for r in rows if scenario.lower() in r["File"].lower()]

    summary.append([
        scenario,
        mean(r["PDR_percent"] for r in group),
        mean(r["Packet_Loss_percent"] for r in group),
        mean(r["Average_Delay_s"] for r in group),
        mean(r["Throughput_Kbps"] for r in group),
        mean(r["Total_AODV"] for r in group)
    ])

# Dinh dang cac sheet
for sheet in wb.worksheets:
    sheet.freeze_panes = "A2"
    sheet.auto_filter.ref = sheet.dimensions

    for cell in sheet[1]:
        cell.font = Font(bold=True, color="FFFFFF")
        cell.fill = PatternFill("solid", fgColor="1F4E78")
        cell.alignment = Alignment(horizontal="center", vertical="center")

    for column in sheet.columns:
        max_length = max(len(str(cell.value or "")) for cell in column)
        sheet.column_dimensions[get_column_letter(column[0].column)].width = min(max_length + 3, 30)

    for row in sheet.iter_rows(min_row=2):
        for cell in row:
            cell.alignment = Alignment(horizontal="center")

# Dinh dang so lieu
for row in ws.iter_rows(min_row=2):
    for col in [5, 6, 7, 8]:
        row[col - 1].number_format = "0.0000"

for row in summary.iter_rows(min_row=2):
    for col in [2, 3, 4, 5, 6]:
        row[col - 1].number_format = "0.0000"

# Luu file
output = FOLDER / "Bang_tong_hop_12_lan_chay.xlsx"
wb.save(output)

print("DA TAO FILE EXCEL THANH CONG!")
print("Duong dan:", output)
print("So lan chay:", len(rows))
