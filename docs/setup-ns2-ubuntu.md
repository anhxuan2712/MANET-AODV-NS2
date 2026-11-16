# HƯỚNG DẪN CÀI ĐẶT & THIẾT LẬP MÔI TRƯỜNG MÔ PHỎNG NS-2.35 & NAM TRÊN UBUNTU

* **Đề tài:** Nghiên cứu và đánh giá hiệu năng giao thức định tuyến AODV trong mạng MANET sử dụng NS-2
* **Thành viên phụ trách:** Nguyễn Thành Đạt (TV2)
* **Vai trò:** Phụ trách Môi trường mô phỏng (Giai đoạn 2)
* **Hệ điều hành thực nghiệm:** Linux Ubuntu (chạy trên máy ảo VMware Virtual Platform)
* **Sản phẩm bàn giao:** Bộ môi trường NS-2.35, NAM hoạt động ổn định và tài liệu hướng dẫn cài đặt chi tiết.

---

## I. MỤC TIÊU VÀ NHIỆM VỤ ĐƯỢC GIAO

1. Chuẩn bị và thiết lập môi trường hệ điều hành Ubuntu tương thích với Network Simulator 2 (NS-2.35).
2. Xử lý triệt để vấn đề tương thích trình biên dịch: Do Ubuntu bản mới sử dụng phiên bản GCC/G++ cao hơn nên không biên dịch được NS-2.35 cũ $\rightarrow$ Cần cấu hình và cài đặt bổ sung GCC-4.8 và G++-4.8.
3. Chỉnh sửa các lỗi cú pháp mã nguồn lịch sử trong NS-2.35 (lỗi `ls.h` và cấu hình Makefile).
4. Thiết lập biến môi trường toàn cục (`PATH`, `LD_LIBRARY_PATH`, `TCL_LIBRARY`).
5. Cài đặt và cấu hình phần mềm mô phỏng trực quan NAM (Network Animator), bao gồm cả giải pháp khắc phục lỗi tương thích đồ họa.
6. Kiểm tra tính sẵn sàng của hệ thống với các lệnh: `ns`, `nam`, `awk`.

---

## II. HƯỚNG DẪN CHI TIẾT CÁC BƯỚC CÀI ĐẶT

> **Lưu ý thao tác:** Trong Terminal của Ubuntu, phím tắt để dán lệnh là: `Ctrl + Shift + V`.

### Phần 1: Cấu hình Kho lưu trữ và Tải Source Code (Software & Updates)
1. Mở ứng dụng **Software & Updates** trên Ubuntu.
2. Tại tab **Ubuntu Software**, tích chọn vào ô: **Source code**.
3. Tại mục **Download from**, chọn máy chủ **VIETNAM** (Nếu chưa có sẵn, chọn *Other...* $\rightarrow$ kéo tìm đến *Vietnam* $\rightarrow$ chọn một host bất kỳ để tối ưu tốc độ tải).
4. Nhấn **Close** $\rightarrow$ chọn **Reload** để hệ thống cập nhật lại danh sách kho gói.

---

### Phần 2: Cập nhật nguồn gói lưu trữ Bionic & Cài đặt gói bổ trợ

Do GCC-4.8 và G++-4.8 không còn được hỗ trợ mặc định trên các bản phân phối Ubuntu gần đây, cần bổ sung kho gói của bản Ubuntu Bionic:

1. Mở Terminal và chỉnh sửa file danh sách nguồn:
   ```bash
   sudo nano /etc/apt/sources.list.d/ubuntu.sources
   ```
2. Thêm dòng cấu hình sau vào cuối file:
   ```text
   deb http://vn.archive.ubuntu.com/ubuntu/ bionic main universe
   ```
3. Nhấn tổ hợp phím `Ctrl + X` $\rightarrow$ nhấn `Y` $\rightarrow$ nhấn `Enter` để lưu file.
4. Cài đặt các công cụ build cơ bản và giao diện chỉnh sửa text:
   ```bash
   sudo apt install -y build-essential autoconf automake libxmu-dev
   sudo apt install -y gedit dbus-x11
   sudo apt update
   ```
   *(Lưu ý: Khi nhập mật khẩu sudo trên terminal, mật khẩu sẽ không hiển thị ký tự; gõ đúng mật khẩu rồi ấn Enter).*
5. Khởi động lại (Restart) máy ảo để hệ thống cập nhật đầy đủ cấu hình.

---

### Phần 2.1: Tải và Cài đặt thủ công GCC-4.8 & G++-4.8

Tiến hành tải trực tiếp các gói cài đặt `.deb` của GCC-4.8 và các thư viện liên quan từ mirror chính thức:

```bash
cd ~/Downloads/
mkdir -p abc && cd abc

wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-4.8/g++-4.8_4.8.5-4ubuntu8_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-4.8/libstdc++-4.8-dev_4.8.5-4ubuntu8_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-4.8/gcc-4.8-base_4.8.5-4ubuntu8_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-4.8/gcc-4.8_4.8.5-4ubuntu8_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-4.8/libgcc-4.8-dev_4.8.5-4ubuntu8_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-4.8/cpp-4.8_4.8.5-4ubuntu8_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-4.8/libasan0_4.8.5-4ubuntu8_amd64.deb

sudo apt install -y ./gcc-4.8_4.8.5-4ubuntu8_amd64.deb ./gcc-4.8-base_4.8.5-4ubuntu8_amd64.deb ./libstdc++-4.8-dev_4.8.5-4ubuntu8_amd64.deb ./cpp-4.8_4.8.5-4ubuntu8_amd64.deb ./libgcc-4.8-dev_4.8.5-4ubuntu8_amd64.deb ./libasan0_4.8.5-4ubuntu8_amd64.deb ./g++-4.8_4.8.5-4ubuntu8_amd64.deb
```

---

### Phần 3: Cấu hình mã nguồn và Biên dịch NS-2.35

1. **Tải bộ cài `ns-allinone-2.35.tar.gz`:**
   * Tải từ SourceForge: [https://sourceforge.net/projects/nsnam/files/allinone/ns-allinone-2.35/ns-allinone-2.35.tar.gz/download](https://sourceforge.net/projects/nsnam/files/allinone/ns-allinone-2.35/ns-allinone-2.35.tar.gz/download)
   * Chuyển tệp `ns-allinone-2.35.tar.gz` vừa tải về vào thư mục Home (`~`).

2. **Giải nén:**
   ```bash
   cd ~
   tar -xzvf ns-allinone-2.35.tar.gz
   ```

3. **Chỉnh sửa các file cấu hình `Makefile.in` để gán cố định trình biên dịch GCC 4.8:**
   * **Cấu hình `ns-2.35`:**
     ```bash
     cd ~/ns-allinone-2.35/ns-2.35
     gedit Makefile.in
     ```
     Sửa tại dòng 36 và 37:
     ```makefile
     CC = gcc-4.8
     CPP = g++-4.8
     ```
     *(Lưu lại và đóng file).*

   * **Cấu hình `nam-1.15`:**
     ```bash
     cd ~/ns-allinone-2.35/nam-1.15
     gedit Makefile.in
     ```
     Sửa tại dòng 46 và 47:
     ```makefile
     CC = gcc-4.8
     CPP = g++-4.8
     ```
     *(Lưu lại và đóng file).*

   * **Cấu hình `xgraph-12.2`:**
     ```bash
     cd ~/ns-allinone-2.35/xgraph-12.2
     gedit Makefile.in
     ```
     Sửa tại dòng 120 và 123:
     ```makefile
     CC = gcc-4.8
     CPP = g++-4.8
     ```
     *(Lưu lại và đóng file).*

   * **Cấu hình `otcl-1.14`:**
     ```bash
     cd ~/ns-allinone-2.35/otcl-1.14
     gedit Makefile.in
     ```
     Sửa tại dòng 7:
     ```makefile
     CC = gcc-4.8
     ```
     *(Lưu lại và đóng file).*

4. **Sửa lỗi cú pháp C++ trong `ls.h` (Lỗi `erase`):**
   ```bash
   cd ~/ns-allinone-2.35/ns-2.35/linkstate
   gedit ls.h
   ```
   Tìm đến dòng **137**:
   * *Mã ban đầu:*
     ```cpp
     void eraseAll() { erase(baseMap::begin(), baseMap::end()); }
     ```
   * *Sửa lại thành:*
     ```cpp
     void eraseAll() { this->erase(baseMap::begin(), baseMap::end()); }
     ```
   *(Lưu lại và đóng file).*

5. **Cài đặt thư viện đồ họa Xorg và tiến hành Build:**
   ```bash
   sudo apt-get install -y xorg-dev sl
   sudo apt-get update && sudo apt-get upgrade -y
   cd ~/ns-allinone-2.35
   export CC=gcc-4.8 CXX=g++-4.8 && ./install
   ```

---

### Phần 4: Cài đặt bổ sung NS2 và NAM từ hệ thống (Option)
Nếu muốn đồng bộ thêm các tiện ích có sẵn trên kho hệ thống:
```bash
sudo apt install -y ns2 nam
```

---

### Phần 5: Thiết lập Biến môi trường (Environment Variables)

1. Mở file cấu hình profile cá nhân:
   ```bash
   gedit ~/.bashrc
   ```
2. Thêm vào cuối file đoạn cấu hình sau *(thay `yourusername` bằng tên tài khoản người dùng trên máy Ubuntu)*:
   ```bash
   # NS-2.35 Environment Setup
   export PATH=$PATH:/home/yourusername/ns-allinone-2.35/bin:/home/yourusername/ns-allinone-2.35/tcl8.5.10/unix:/home/yourusername/ns-allinone-2.35/tk8.5.10/unix
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/yourusername/ns-allinone-2.35/otcl-1.14:/home/yourusername/ns-allinone-2.35/lib
   export TCL_LIBRARY=/home/yourusername/ns-allinone-2.35/tcl8.5.10/library
   ```
3. Lưu file và khởi động lại terminal hoặc chạy `source ~/.bashrc`.

---

### Phần 6: Giải pháp cài đặt NAM 1.14 (Khắc phục lỗi Segment Fault/Tương thích đồ họa)

Trong nhiều trường hợp, phiên bản NAM 1.15 tự build trên nền Linux mới bị lỗi treo đồ họa hoặc Segmentation Fault. Để đảm bảo NAM hiển thị trực quan 100% ổn định:
1. Tải gói đã đóng gói sẵn: [nam_1.14_amd64.deb trên Google Drive](https://drive.google.com/file/d/1dkNPNN23Vy6o_zT0uIRBgUAo1VCXcVOY/view)
2. Mở thư mục `Downloads` chứa file vừa tải, mở Terminal tại thư mục này và cài đặt:
   ```bash
   sudo dpkg --install nam_1.14_amd64.deb
   ```
3. **Kiểm tra:** Mở một Terminal mới và gõ lệnh:
   ```bash
   nam
   ```
   Cửa sổ giao diện đồ họa trực quan của NAM xuất hiện là đã cài đặt thành công 100%.

---

## III. KẾT QUẢ VÀ NGHIỆM THU (CHECKLIST)

| Hạng mục kiểm tra | Lệnh xác minh | Trạng thái |
| :--- | :--- | :---: |
| **Trình mô phỏng NS-2** | Gõ `ns` hiện dấu nhắc `%` | **Đạt** |
| **Giao diện trực quan NAM** | Gõ `nam` hiển thị cửa sổ Network Animator | **Đạt** |
| **Bộ công cụ bóc tách AWK** | Gõ `awk --version` phản hồi bình thường | **Đạt** |
| **Trình biên dịch GCC 4.8** | `gcc-4.8 --version` hiển thị 4.8.5 | **Đạt** |

---

## IV. KẾT LUẬN & BÀN GIAO CHO GIAI ĐOẠN TIẾP THEO

* Toàn bộ môi trường mô phỏng NS-2.35 và NAM đã được cài đặt, tinh chỉnh lỗi và cấu hình biến môi trường hoàn tất trên máy ảo Ubuntu.
* Hệ thống đã sẵn sàng cho **Thành viên 3 (Viết kịch bản Tcl)** và **Thành viên 4 (Chạy các kịch bản thực nghiệm SC01 - SC04)** thực hiện công việc mà không gặp rào cản về lỗi môi trường biên dịch.
