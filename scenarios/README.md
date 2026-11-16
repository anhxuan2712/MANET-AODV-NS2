# Kịch bản mô phỏng SC01–SC04

**Người phụ trách:** Nguyễn Minh Trí (TV4)

## 1. Nội dung thư mục

| Thư mục | Tốc độ tối đa | File |
|---|---|---|
| `SC01_speed_0/`  | 0 m/s (đứng yên) | `mobility_sc01_run01..03.txt`, `traffic_cbr.txt` |
| `SC02_speed_5/`  | 5 m/s  | `mobility_sc02_run01..03.txt`, `traffic_cbr.txt` |
| `SC03_speed_10/` | 10 m/s | `mobility_sc03_run01..03.txt`, `traffic_cbr.txt` |
| `SC04_speed_15/` | 15 m/s | `mobility_sc04_run01..03.txt`, `traffic_cbr.txt` |

Tất cả được sinh bởi [`gen_scenarios.sh`](gen_scenarios.sh). `runNN` dùng seed = NN.

### Mô tả từng kịch bản (số liệu của run01)

| Kịch bản | Tốc độ | Số lệnh di chuyển | Tốc độ TB | Ý nghĩa |
|---|---|---|---|---|
| **SC01** | 0 m/s | 0 | – | Mạng tĩnh, node đứng yên; tuyến tìm một lần là dùng mãi. Làm **mốc so sánh**. |
| **SC02** | 1–5 m/s | 32 | 2,98 m/s | Tương đương đi bộ; topology thay đổi chậm. |
| **SC03** | 1–10 m/s | 45 | 5,53 m/s | Chạy / xe đạp; tuyến đứt thường xuyên hơn. |
| **SC04** | 1–15 m/s | 55 | 8,02 m/s | Xe chạy chậm; topology biến động mạnh nhất. |

Tốc độ cao hơn thì node đến đích sớm hơn, nên trong 100 s đi được nhiều chặng hơn (số lệnh di chuyển tăng dần).

### Giả thuyết kiểm thử (chưa có số liệu)

Khi tốc độ tăng, liên kết đứt nhiều hơn, AODV phải gửi RERR rồi RREQ/RREP để tìm lại tuyến. Dự đoán:

- PDR giảm, Packet Loss tăng.
- Average End-to-End Delay tăng (gói chờ trong lúc tìm lại tuyến).
- Routing Overhead tăng rõ.
- Throughput giảm.

Đây chỉ là giả thuyết để đối chiếu. Kết luận phải dựa trên số liệu thật do TV5 tính từ trace.

## 2. Tham số

**Cố định (theo README/Project Charter):** 20 node, 500 m × 500 m, 100 s, pause 5 s, Random Waypoint.

**Mobility (Random Waypoint):**
- Mỗi node: dừng 5 s → chọn điểm đến ngẫu nhiên trong khu vực → đi tới với tốc độ ngẫu nhiên trong `[1, max]` m/s → lặp lại.
- Tốc độ tối thiểu 1 m/s để tránh node có tốc độ gần 0 gần như đứng yên cả trận (nhược điểm đã biết của Random Waypoint khi tốc độ ~ U(0, max]).
- **Cùng một run, 4 kịch bản có cùng vị trí ban đầu và cùng chuỗi điểm đến**; chỉ tốc độ khác nhau. Như vậy tốc độ thực sự là biến độc lập duy nhất.
- SC01 (0 m/s): chỉ đặt vị trí ban đầu, không có lệnh di chuyển. Đã kiểm tra với tầm phủ 250 m: cả 3 run đều liên thông 20/20 node.

**Traffic UDP/CBR (đề xuất, cần TV1 xác nhận):** 10 luồng, gói 512 bytes, 4 gói/s/luồng (interval 0.25 s), bắt đầu từ 5.0 s (mỗi luồng lệch 0.5 s), dừng ở 95.0 s. Nguồn khác nhau, đích ≠ nguồn. Cùng một file cho cả 4 kịch bản.

## 3. Cách chạy (trên Ubuntu máy ảo VMware)

> Cần file Tcl `tcl/manet_aodv_base.tcl` (TV3) đọc được mobility/traffic theo đường dẫn
> `scenarios/<SC>_speed_<v>/mobility_<sc>_run<NN>.txt` và `traffic_cbr.txt`,
> dùng tên biến `$ns_`, `$node_(i)`, `$god_`.

```bash
git pull                          # lấy code mới nhất trên nhánh Nguyen_Minh_Tri
cd tcl
chmod +x run_simulation.sh ../scenarios/gen_scenarios.sh

# Chạy thử SC01 trước để kiểm tra mô hình
ns manet_aodv_base.tcl -sc SC01 -speed 0 -seed 1

# Chạy toàn bộ 4 kịch bản × 3 lần (bỏ qua trace đã có)
rm ../trace/raw/trace_sc01_run01.tr ../trace/raw/nam_sc01_run01.nam   # nếu chỉ là chạy thử
./run_simulation.sh
```

Kết quả:
- `trace/raw/trace_scXX_runNN.tr`, `nam_scXX_runNN.nam` (không commit, đã có trong `.gitignore`; sao lưu lên Drive)
- `trace/logs/scXX_runNN.log`: output của ns
- `trace/run_log.csv`: metadata từng lần chạy (kịch bản, tốc độ, seed, trạng thái, số gói CBR gửi/nhận ở tầng AGT, tên file)

`status = OK` nghĩa là ns chạy xong, trace không rỗng và có gói CBR nhận được. Số gửi/nhận trong log chỉ để kiểm tra nhanh; chỉ số chính thức do TV5 tính.

## 4. Sinh lại kịch bản

```bash
cd scenarios
./gen_scenarios.sh                       # file đã có sẽ được giữ nguyên
RUNS=5 ./gen_scenarios.sh                # thêm run04, run05
USE_SETDEST=1 NS_HOME=~/ns-allinone-2.35/ns-2.35 ./gen_scenarios.sh   # dùng setdest của NS-2
```

Muốn sinh lại một file thì xóa file đó trước. Không sửa tay file mobility/traffic.
