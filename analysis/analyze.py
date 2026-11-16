#!/usr/bin/env python3
# ==============================================================================
# Script Python tổng hợp và thống kê dữ liệu đa lần chạy (Seeds 1, 2, 3)
# Người phụ trách: Kiều Đức Dương (TV5)
# Đầu vào: File kết quả phân tích hoặc log từ AWK
# Đầu ra: results/metrics.csv (Bảng trung bình các chỉ số theo kịch bản)
# ==============================================================================

import os
import pandas as pd
import numpy as np

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
METRICS_CSV = os.path.join(BASE_DIR, "results", "metrics.csv")

def main():
    print("=== BẮT ĐẦU TỔNG HỢP VÀ THỐNG KÊ DỮ LIỆU CHỈ SỐ ===")
    
    if not os.path.exists(METRICS_CSV):
        print(f"Lỗi: Không tìm thấy file {METRICS_CSV}")
        return

    df = pd.read_csv(METRICS_CSV)
    print("\nDữ liệu hiện tại trong results/metrics.csv:")
    print(df)
    
    # TV5 sẽ bổ sung logic tổng hợp từ các lần chạy tại đây
    print("\nHoàn tất xử lý thống kê.")

if __name__ == "__main__":
    main()
