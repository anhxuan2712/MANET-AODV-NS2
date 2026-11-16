L# BIÊN BẢN HỌP NHÓM ĐỊNH KỲ

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
l

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
| **TV3 (Vượng)** | Mô hình kịch bản Tcl AODV | File `manet_aodv_sc01.tcl` | **Chưa đạt** (Sai tích hợp, sai đường dẫn) | Cập nhật lại trước ngày 17/11 |

---

### 3. Kế hoạch hành động & Điều phối tiếp theo

1. **Yêu cầu TV3:** Cập nhật script Tcl tích hợp trực tiếp các file kịch bản của TV4 (dùng cờ `-mob` và `-traffic` hoặc nạp tự động theo kịch bản/seed), trỏ đường dẫn xuất trace về `../trace/raw/` và tắt `macTrace`, `movementTrace`. *(Có thể tham khảo trực tiếp file `tcl/manet_aodv_base.tcl` đã được xây dựng sẵn chuẩn khung nạp)*.
2. **Yêu cầu TV2:** Bổ sung ảnh chụp màn hình kiểm thử terminal vào `screenshots/terminal/`.
3. **Phối hợp TV3 & TV4:** Sau khi TV3 hoàn thiện mã Tcl, TV4 tiến hành chạy thử nghiệm toàn bộ 4 kịch bản $\times$ 3 lượt chạy (tổng cộng 12 lượt mô phỏng) trên máy ảo Ubuntu để sinh bộ dữ liệu trace đưa vào `trace/raw/` bàn giao cho TV5 phân tích.