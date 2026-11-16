#!/usr/bin/env python3
# ==============================================================================
# Script Python vẽ đồ thị khoa học so sánh hiệu năng giữa các kịch bản
# Người phụ trách: Lê Tuấn Anh (TV6)
# Đầu vào: results/metrics.csv
# Đầu ra: results/figures/ (fig_pdr.png, fig_delay.png, fig_throughput.png, ...)
# ==============================================================================

import os
import matplotlib.pyplot as plt
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
METRICS_CSV = os.path.join(BASE_DIR, "results", "metrics.csv")
FIGURES_DIR = os.path.join(BASE_DIR, "results", "figures")

def plot_charts():
    if not os.path.exists(METRICS_CSV):
        print(f"Lỗi: Không tìm thấy file {METRICS_CSV}")
        return

    os.makedirs(FIGURES_DIR, exist_ok=True)
    df = pd.read_csv(METRICS_CSV)

    if df.empty or df['pdr_percent'].dropna().empty:
        print("Thông báo: Bảng metrics.csv chưa có số liệu. Vui lòng cập nhật số liệu sau khi chạy mô phỏng.")
        return

    print("Đang vẽ biểu đồ từ results/metrics.csv...")

    # Cấu hình phong cách biểu đồ khoa học
    plt.style.use('seaborn-v0_8-whitegrid' if 'seaborn-v0_8-whitegrid' in plt.style.available else 'default')

    # 1. Biểu đồ PDR
    plt.figure(figsize=(8, 5))
    plt.plot(df['speed_mps'], df['pdr_percent'], marker='o', color='b', linewidth=2)
    plt.title("Tỷ lệ phân phát gói tin thành công (PDR) theo tốc độ di chuyển", fontsize=12)
    plt.xlabel("Tốc độ di chuyển tối đa (m/s)", fontsize=10)
    plt.ylabel("PDR (%)", fontsize=10)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig(os.path.join(FIGURES_DIR, "fig_pdr.png"), dpi=300, bbox_inches='tight')
    plt.close()

    # 2. Biểu đồ Delay
    plt.figure(figsize=(8, 5))
    plt.plot(df['speed_mps'], df['delay_ms'], marker='s', color='r', linewidth=2)
    plt.title("Độ trễ trung bình đầu cuối theo tốc độ di chuyển", fontsize=12)
    plt.xlabel("Tốc độ di chuyển tối đa (m/s)", fontsize=10)
    plt.ylabel("Average End-to-End Delay (ms)", fontsize=10)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig(os.path.join(FIGURES_DIR, "fig_delay.png"), dpi=300, bbox_inches='tight')
    plt.close()

    # 3. Biểu đồ Throughput
    plt.figure(figsize=(8, 5))
    plt.plot(df['speed_mps'], df['throughput_kbps'], marker='^', color='g', linewidth=2)
    plt.title("Thông lượng mạng theo tốc độ di chuyển", fontsize=12)
    plt.xlabel("Tốc độ di chuyển tối đa (m/s)", fontsize=10)
    plt.ylabel("Throughput (kbps)", fontsize=10)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig(os.path.join(FIGURES_DIR, "fig_throughput.png"), dpi=300, bbox_inches='tight')
    plt.close()

    # 4. Biểu đồ Routing Overhead
    plt.figure(figsize=(8, 5))
    plt.plot(df['speed_mps'], df['routing_overhead'], marker='d', color='purple', linewidth=2)
    plt.title("Chi phí điều khiển định tuyến AODV theo tốc độ di chuyển", fontsize=12)
    plt.xlabel("Tốc độ di chuyển tối đa (m/s)", fontsize=10)
    plt.ylabel("Routing Overhead (gói AODV / gói dữ liệu)", fontsize=10)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig(os.path.join(FIGURES_DIR, "fig_routing_overhead.png"), dpi=300, bbox_inches='tight')
    plt.close()

    # 5. Biểu đồ Packet Loss
    plt.figure(figsize=(8, 5))
    plt.plot(df['speed_mps'], df['plr_percent'], marker='x', color='orange', linewidth=2)
    plt.title("Tỷ lệ mất gói tin (Packet Loss Ratio) theo tốc độ di chuyển", fontsize=12)
    plt.xlabel("Tốc độ di chuyển tối đa (m/s)", fontsize=10)
    plt.ylabel("Packet Loss Ratio (%)", fontsize=10)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig(os.path.join(FIGURES_DIR, "fig_packet_loss.png"), dpi=300, bbox_inches='tight')
    plt.close()

    print(f"Đã xuất toàn bộ 5 biểu đồ vào: {FIGURES_DIR}")

if __name__ == "__main__":
    plot_charts()
