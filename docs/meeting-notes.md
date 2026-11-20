# BIÊN BẢN HỌP NHÓM ĐỊNH KỲ

**Dự án:** Nghiên cứu và đánh giá hiệu năng giao thức định tuyến AODV trong mạng MANET sử dụng NS-2  

---

## Cuộc họp khởi động dự án (Giai đoạn 1)

- **Thời gian:** 14/11/2026
- **Thành phần tham dự:** Đủ 6 thành viên (TV1 đến TV6).
- **Chủ trì:** Nguyễn Anh Xuân (TV1 - Leader).
- **Nội dung thống nhất:**
  1. Thống nhất tên đề tài, phạm vi 20 node, khu vực 500m × 500m, thời gian 100s.
  2. Thống nhất 4 kịch bản thay đổi tốc độ tối đa: SC01 (0 m/s), SC02 (5 m/s), SC03 (10 m/s), SC04 (15 m/s).
  3. Phân chia vai trò, trách nhiệm từng thành viên theo Project Charter.
  4. Thống nhất cấu trúc thư mục chuẩn và nguyên tắc không commit file trace lớn lên GitHub.

---

## Cuộc họp Review tiến độ & Nghiệm thu sản phẩm đợt 1 (16/11/2026)

- **Thời gian:** 16/11/2026
- **Chủ trì:** Nguyễn Anh Xuân (TV1 - Leader)
- **Mục tiêu:** Đánh giá chất lượng và sự tương thích các sản phẩm bàn giao từ 3 thành viên: TV2 (Nguyễn Thành Đạt), TV4 (Nguyễn Minh Trí) và TV3 (Nguyễn Phúc Vượng).

### 1. Đánh giá chi tiết sản phẩm của từng thành viên

#### Thành viên TV4: Nguyễn Minh Trí (Mobility & Kịch bản mô phỏng)
- **Sản phẩm bàn giao:** 
  - Đủ 12 file di chuyển cho 4 kịch bản $\times$ 3 lượt chạy (`scenarios/SC0X_speed_X/mobility_sc0X_run0Y.txt`).
  - File tạo luồng lưu lượng ứng dụng `traffic_cbr.txt` cho từng kịch bản.
  - Script tự động hóa sinh kịch bản `scenarios/gen_scenarios.sh`.
  - Tài liệu thuyết minh `scenarios/README.md` và file cấu hình `.gitattributes`.
- **Ưu điểm:**
  - Thiết kế phương pháp nghiên cứu rất chuẩn: giữ nguyên vị trí ban đầu và chuỗi waypoint giữa các kịch bản trong cùng một seed, đảm bảo tốc độ di chuyển là biến độc lập duy nhất.
  - Kiểm tra và đảm bảo 20/20 node liên thông ở tầm phủ sóng 250m.
  - Khống chế dải tốc độ `[1, max]` m/s để triệt tiêu hiện tượng thắt cổ chai do nút đứng yên của mô hình Random Waypoint.
- **Điểm thống nhất:**
  - Nhóm phê duyệt phương án sử dụng **10 luồng UDP/CBR** (512 bytes, khoảng thời gian gửi 5s–95s) do TV4 đề xuất làm chuẩn cho toàn bộ quá trình chạy mô phỏng.
- **Đánh giá & Trạng thái nghiệm thu:** **Đạt 10/10 (Xuất sắc - Nghiệm thu hoàn toàn)**.

#### Thành viên TV2: Nguyễn Thành Đạt (Môi trường NS-2 & NAM)
- **Sản phẩm bàn giao:** Tài liệu hướng dẫn cài đặt môi trường và giải quyết lỗi biên dịch trên Ubuntu.
- **Ưu điểm:**
  - Hướng dẫn chi tiết, thực tế, xử lý triệt để lỗi biên dịch GCC bản mới bằng cách cài GCC-4.8, sửa `Makefile.in` và sửa lỗi cú pháp trong `linkstate/ls.h`.
  - Đưa ra giải pháp thực tiễn dùng gói cài sẵn `nam_1.14_amd64.deb` để khắc phục triệt để lỗi Segmentation Fault / treo đồ họa của NAM 1.15.
- **Điểm tồn tại cần khắc phục:**
  - Tên file ban đầu đặt là `docs/bao-cao-thanh-vien-2.md` chưa đúng với quy ước cấu trúc dự án. *(Đã được chuẩn hóa và hợp nhất vào `docs/setup-ns2-ubuntu.md`)*.
  - Chưa nộp ảnh chụp màn hình terminal (kiểm thử lệnh `ns`, `nam`, `awk`) vào thư mục `screenshots/terminal/`.
- **Đánh giá & Trạng thái nghiệm thu:** **Đạt 8.5/10 (Nghiệm thu có điều kiện)**. Yêu cầu TV2 bổ sung ảnh minh chứng kiểm thử vào thư mục `screenshots/terminal/`.

#### Thành viên TV3: Nguyễn Phúc Vượng (Mô hình Tcl)
- **Sản phẩm bàn giao:** Script mô phỏng NS-2 `tcl/manet_aodv_sc01.tcl`.
- **Ưu điểm:**
  - Khai báo đúng các thông số mô phỏng nền tảng: 20 nút, 500m × 500m, chuẩn MAC IEEE 802.11, hàng đợi DropTail/PriQueue (50 gói), AODV, thời gian 100s.
- **Các lỗi và hạn chế lớn cần chỉnh sửa (BẮT BUỘC):**
  1. **Không kết nối với kịch bản của TV4:** Tự sinh vị trí ban đầu ngẫu nhiên và tự code thủ tục `proc random-waypoint` trong Tcl thay vì dùng lệnh `source` nạp các file `mobility_scXX_runYY.txt` và `traffic_cbr.txt` của TV4.
  2. **Lưu file Trace sai vị trí quy chuẩn:** Xuất file `.tr` và `.nam` thẳng vào thư mục `tcl/` thay vì lưu vào `../trace/raw/`; gán cứng `run01` trong code.
  3. **Bật `macTrace ON` và `movementTrace ON`:** Làm phình to dung lượng file trace lên hàng trăm MB, gây khó khăn lớn cho công đoạn phân tích AWK của TV5. Cần chuyển về `OFF`, chỉ giữ `agentTrace ON` và `routerTrace ON`.
  4. **Commit message không chính xác:** Đặt tên commit là `"tcp v1"` trong khi hệ thống sử dụng UDP/CBR.
- **Đánh giá & Trạng thái nghiệm thu:** **Chưa đạt chuẩn (Yêu cầu làm lại/Refactor)**.

---

### 2. Bảng tổng hợp nghiệm thu công việc đợt 1

| Thành viên | Hạng mục công việc | Sản phẩm nộp | Kết quả đánh giá | Hạn hoàn thành khắc phục |
|---|---|---|---|---|
| **TV4 (Trí)** | Mobility & Kịch bản SC01–SC04 | 16 file scenario + script + doc | **Đạt xuất sắc** | Sẵn sàng cho giai đoạn chạy |
| **TV2 (Đạt)** | Môi trường NS-2, NAM, AWK | Hướng dẫn cài đặt | **Đạt** (Thiếu ảnh minh chứng) | Bổ sung ảnh trước ngày 18/11 |
| **TV3 (Vượng)** | Mô hình kịch bản Tcl AODV | File `manet_aodv_sc01.tcl` | **Chưa đạt** (Sai tích hợp, sai đường dẫn) | Cập nhật lại trước ngày 16/11 |

---

### 3. Kế hoạch hành động & Điều phối tiếp theo

1. **Yêu cầu TV3:** Cập nhật script Tcl tích hợp trực tiếp các file kịch bản của TV4 (dùng cờ `-mob` và `-traffic` hoặc nạp tự động theo kịch bản/seed), trỏ đường dẫn xuất trace về `../trace/raw/` và tắt `macTrace`, `movementTrace`. *(Có thể tham khảo trực tiếp file `tcl/manet_aodv_base.tcl` đã được xây dựng sẵn chuẩn khung nạp)*.
2. **Yêu cầu TV2:** Bổ sung ảnh chụp màn hình kiểm thử terminal vào `screenshots/terminal/`.
3. **Phối hợp TV3 & TV4:** Sau khi TV3 hoàn thiện mã Tcl, TV4 tiến hành chạy thử nghiệm toàn bộ 4 kịch bản $\times$ 3 lượt chạy (tổng cộng 12 lượt mô phỏng) trên máy ảo Ubuntu để sinh bộ dữ liệu trace đưa vào `trace/raw/` bàn giao cho TV5 phân tích.


---

## Cuộc họp Review tiến độ & Nghiệm thu đợt 2: Dữ liệu mô phỏng thực nghiệm (17/11/2026)

- **Thời gian:** 17/11/2026
- **Chủ trì review:** Nguyễn Anh Xuân (TV1 - Leader)
- **Nội dung:** Đánh giá kết quả thực thi mô phỏng của Thành viên 2 (Nguyễn Thành Đạt) qua Pull Request #5 (Commit `788f5f1`) và kho lưu trữ trace thực nghiệm trên Google Drive.
- **Sản phẩm bàn giao:**
  1. Thư mục Google Drive `trace/raw/` chứa đủ 12 file trace gốc: `trace_sc01_run01..03.tr` đến `trace_sc04_run01..03.tr`.
  2. Bổ sung 4 ảnh minh chứng thực nghiệm vào `screenshots/`: ảnh terminal chạy `./run_simulation.sh 1 2 3` và 3 ảnh hoạt ảnh NAM (`nam_sc01_static.png`, `nam_sc04_mobile_01.png`, `nam_sc04_mobile_02.png`).
  3. Bổ sung 12 file log chạy chi tiết vào `trace/logs/` (`log_sc01_run01.txt` đến `log_sc04_run03.txt`).

### 1. Kết quả kiểm tra đối chiếu kỹ thuật

1. **Tính đầy đủ của số liệu thực nghiệm: ĐẠT XUẤT SẮC (10/10)**
   - Đã chạy trọn vẹn đủ 4 kịch bản $\times$ 3 lượt chạy (seeds 1, 2, 3) = **12 lượt mô phỏng**.
   - Tất cả 12 lượt chạy đều kết thúc thành công ở mốc 100.0s, không xảy ra lỗi crash bộ nhớ hay lỗi segmentation fault.
2. **Tính chân thực và quy luật khoa học của dữ liệu Trace: ĐẠT XUẤT SẮC (10/10)**
   - Dung lượng các file trace tăng đều đặn theo tốc độ: SC01 (1.4 – 1.6 MB) $\rightarrow$ SC02 (1.7 – 1.8 MB) $\rightarrow$ SC03 (2.0 – 2.4 MB) $\rightarrow$ SC04 (2.2 – 2.5 MB).
   - Kiểm tra ngẫu nhiên bằng AWK:
     - **SC01 (0 m/s - Đứng yên):** Gửi 3.510 gói CBR, nhận đủ 3.510 gói (**PDR = 100.00%**), gói điều khiển AODV = 204 gói (chỉ tìm đường ban đầu).
     - **SC04 (15 m/s - Di chuyển nhanh):** Gửi 3.510 gói CBR, nhận 3.486 gói (**PDR = 99.32%**, xuất hiện 36 gói tin bị drop), gói điều khiển AODV tăng vọt lên **653 gói** (tăng hơn gấp 3 lần do mạng liên tục bị đứt tuyến và phải gửi RERR, RREQ).
   - Dữ liệu phản ánh đúng 100% bản chất lý thuyết của mạng MANET và giao thức định tuyến AODV.
3. **Hình ảnh minh chứng và lưu vết log: ĐẠT (10/10)**
   - Ảnh chụp terminal rõ ràng, sắc nét, thể hiện đúng các thông số đầu vào và kết quả kiểm tra CBR tức thì.
   - Hoạt ảnh NAM thể hiện trực quan các node di chuyển và vùng phủ sóng.

### 2. Kết luận nghiệm thu Thành viên 2

* **Đánh giá:** **10/10 (Xuất sắc - Nghiệm thu hoàn toàn Giai đoạn 5)**.
* **Kế hoạch hành động tiếp theo (Chuyển giao sang Giai đoạn 6):**
  - Dữ liệu trace thô đã sẵn sàng. Bàn giao ngay cho **Thành viên 5 (Kiều Đức Dương)** chạy script AWK và Python để bóc tách 5 chỉ số hiệu năng (PDR, PLR, Delay, Throughput, Routing Overhead) và cập nhật vào file `results/metrics.csv`.
  - Nhắc nhở **Thành viên 6 (Lê Tuấn Anh)** chuẩn bị sẵn script `analysis/plot_charts.py` để khi TV5 có bảng số liệu CSV là tiến hành vẽ đồ thị ngay.



---

## Cuộc họp Review tiến độ & Nghiệm thu đợt 3: Xử lý số liệu & Phân tích Trace (17/11/2026)

- **Thời gian:** 17/11/2026 (Tối)
- **Chủ trì review:** Nguyễn Anh Xuân (TV1 - Leader)
- **Nội dung:** Đánh giá và chuẩn hóa sản phẩm của Thành viên 5 (Kiều Đức Dương) - Phụ trách Phân tích Trace & Tính toán chỉ số hiệu năng.

### 1. Kết quả đánh giá chuyên môn
- **Tính toán chỉ số:** TV5 đã xử lý toàn diện 12 file trace, xây dựng bộ script Python chuyên sâu để bóc tách từng chỉ số: PDR, Packet Loss, Average End-to-End Delay, Throughput, Routing Overhead (phân tích chi tiết cả 4 loại gói AODV: REQUEST, REPLY, ERROR, HELLO).
- **Quy luật số liệu khoa học:**
  - PDR giảm nhẹ theo tốc độ: SC01 (99.99%) $\rightarrow$ SC02 (99.75%) $\rightarrow$ SC03 (99.47%) $\rightarrow$ SC04 (99.27%).
  - Routing Overhead tăng mạnh theo tốc độ: SC01 (208 gói) $\rightarrow$ SC02 (368 gói) $\rightarrow$ SC03 (584 gói) $\rightarrow$ SC04 (726 gói).
  - Throughput duy trì ổn định ~159 – 160 Kbps.
- **Sản phẩm trực quan:** Xuất file Excel `Tong_hop_12_lan_chay.xlsx` có định dạng màu sắc chuyên nghiệp và báo cáo phân tích định dạng Word.

### 2. Chuẩn hóa cấu trúc và dữ liệu dự án
- Đã khắc phục lỗi tổ chức thư mục của TV5:
  - 18 script Python phân tích và kiểm tra được đưa vào thư mục chuẩn `analysis/`.
  - Các file CSV chi tiết và file Excel tổng hợp được đưa vào thư mục `results/`.
  - File Word báo cáo phân tích trace được đưa vào thư mục `report/Bao_cao_phan_tich_trace_TV5.docx`.
  - Loại bỏ hoàn toàn các file trace `.tr` thô khỏi Git repo để giữ dung lượng nhẹ (đã lưu trữ an toàn trên Google Drive).
  - Cập nhật đầy đủ số liệu trung bình 4 kịch bản vào bảng đích `results/metrics.csv`.

### 3. Kết luận nghiệm thu Thành viên 5
- **Đánh giá:** **9.5/10 (Xuất sắc về phân tích số liệu - Nghiệm thu hoàn toàn Giai đoạn 6)**.
- **Kế hoạch tiếp theo (Giai đoạn 7):** Bàn giao bảng số liệu `results/metrics.csv` cho **Thành viên 6 (Lê Tuấn Anh)** để chạy script `analysis/plot_charts.py` vẽ 5 biểu đồ hiệu năng, hoàn thiện báo cáo và slide thuyết trình.

---

## Cuộc họp Review bổ sung: Nghiệm thu Tài liệu Thẩm định Cấu hình (20/11/2026)

- **Thời gian:** 20/11/2026
- **Chủ trì review:** Nguyễn Anh Xuân (TV1 - Leader)
- **Nội dung:** Thẩm định và nghiệm thu tài liệu độc lập của Thành viên 5 (Kiều Đức Dương): *"Báo cáo đối chiếu cấu hình mô phỏng mạng MANET sử dụng giao thức định tuyến AODV"*.
- **Sản phẩm bàn giao:** File tài liệu Word `docs/bang-doi-chieu-cau-hinh-tv5.docx` (Trích xuất từ commit `8b7e3ff`).

### 1. Kết quả đánh giá chuyên môn
- **Tính cẩn trọng và chặt chẽ:** TV5 đã lập bảng đối chiếu chi tiết giữa kịch bản sơ khai (`manet_aodv_sc01.tcl`), kịch bản chuẩn hóa (`manet_aodv_base.tcl`) và bộ sinh kịch bản (`gen_scenarios.sh`).
- **Phát hiện xác đáng:** Nhận diện rõ việc tắt `macTrace` và `movementTrace` để tối ưu dung lượng file, đồng thời làm rõ sự khác biệt giữa cấu hình 4 luồng CBR nội bộ và 10 luồng CBR chuẩn hóa.
- **Tính học thuật:** Xác định rõ sự suy giảm PDR và gia tăng Routing Overhead là giả thuyết nghiên cứu cần kiểm chứng bằng dữ liệu trace thực tế, không võ đoán.

### 2. Thống nhất và Giải đáp của Leader cho TV5
1. **Lưu lượng chuẩn hóa:** Xác nhận sử dụng **10 luồng UDP/CBR** (512B, interval 0.25s, phát 5s–95s) do TV4 sinh ra.
2. **Kịch bản mô phỏng:** Chạy chính thức trên **`tcl/manet_aodv_base.tcl`** (chế độ tắt MAC trace để giảm dung lượng file xuống ~2MB/file).
3. **Bộ dữ liệu 12 file trace:** Đã được TV2 chạy và kiểm tra toàn vẹn, hoàn toàn tương thích và khớp với phân tích của TV5.

### 3. Kết luận nghiệm thu
- **Đánh giá:** **10/10 (Xuất sắc về phương pháp nghiên cứu và tư duy phản biện)**.
- **Hành động:** Lưu tài liệu vào `docs/bang-doi-chieu-cau-hinh-tv5.docx`. Hướng dẫn TV5 reset nhánh cá nhân đồng bộ với `main` để tránh xung đột lịch sử commit cũ.

