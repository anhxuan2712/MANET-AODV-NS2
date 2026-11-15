#!/bin/bash
# ==============================================================================
# Sinh file mobility (Random Waypoint) và traffic (UDP/CBR) cho SC01–SC04
# Người phụ trách: TV4 (Nguyễn Minh Trí)
#
# Chỉ cần bash + awk (Ubuntu hoặc Git Bash trên Windows):
#   cd scenarios && ./gen_scenarios.sh
#   RUNS=1 ./gen_scenarios.sh                 # chỉ sinh 1 lần chạy / kịch bản
#   USE_SETDEST=1 NS_HOME=~/ns-allinone-2.35/ns-2.35 ./gen_scenarios.sh   # dùng setdest
#
# File đã tồn tại sẽ KHÔNG bị ghi đè (để giữ đúng dữ liệu đã dùng khi chạy).
# Muốn sinh lại thì tự xóa/di chuyển file cũ trước.
# ==============================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCEN_DIR="$BASE_DIR/scenarios"
NS_HOME="${NS_HOME:-$HOME/ns-allinone-2.35/ns-2.35}"
SETDEST="${SETDEST:-$NS_HOME/indep-utils/cmu-scen-gen/setdest/setdest}"

# ---- Tham số cố định (theo README / Project Charter) -------------------------
NN=20          # số node
X=500; Y=500   # khu vực (m)
SIM_TIME=100   # thời gian mô phỏng (s)
PAUSE=5        # pause time (s)
RUNS="${RUNS:-3}"   # số lần chạy / kịch bản (run01..runNN, seed = số run)
MIN_SPEED=1    # tốc độ tối thiểu (m/s) cho SC02–SC04, tránh node gần như đứng yên cả trận
USE_SETDEST="${USE_SETDEST:-0}"   # 1 = dùng setdest của NS-2 thay cho bộ sinh awk

# ---- Tham số lưu lượng (ĐỀ XUẤT - cần leader TV1 xác nhận) --------------------
N_CONN=10        # số luồng CBR
PKT_SIZE=512     # bytes (theo README)
INTERVAL=0.25    # giây/gói  => 4 gói/s/luồng
T_START=5.0      # luồng đầu tiên bắt đầu (các luồng sau lệch 0.5 s)
T_STOP=95.0      # tất cả luồng dừng
TRAFFIC_SEED=1   # cùng một file traffic cho cả 4 kịch bản

SCENARIOS=(SC01_speed_0 SC02_speed_5 SC03_speed_10 SC04_speed_15)
SPEEDS=(0 5 10 15)

# ------------------------------------------------------------------------------
gen_traffic() {
    awk -v n="$NN" -v nc="$N_CONN" -v size="$PKT_SIZE" -v itv="$INTERVAL" \
        -v ts="$T_START" -v te="$T_STOP" -v seed="$TRAFFIC_SEED" 'BEGIN {
        srand(seed)
        printf "# Traffic UDP/CBR: %d luong, %d bytes, interval %s s, seed %d\n", nc, size, itv, seed
        # xao tron danh sach node de chon nguon khac nhau
        for (i = 0; i < n; i++) p[i] = i
        for (i = n - 1; i > 0; i--) { j = int(rand() * (i + 1)); t = p[i]; p[i] = p[j]; p[j] = t }
        for (c = 0; c < nc; c++) {
            s = p[c]
            do { d = int(rand() * n) } while (d == s)
            st = ts + c * 0.5
            printf "#\n# %d connecting to %d at time %.1f\n#\n", s, d, st
            printf "set udp_(%d) [new Agent/UDP]\n", c
            printf "$ns_ attach-agent $node_(%d) $udp_(%d)\n", s, c
            printf "set null_(%d) [new Agent/Null]\n", c
            printf "$ns_ attach-agent $node_(%d) $null_(%d)\n", d, c
            printf "set cbr_(%d) [new Application/Traffic/CBR]\n", c
            printf "$cbr_(%d) set packetSize_ %d\n", c, size
            printf "$cbr_(%d) set interval_ %s\n", c, itv
            printf "$cbr_(%d) set random_ 0\n", c
            printf "$cbr_(%d) set maxpkts_ 100000\n", c
            printf "$cbr_(%d) attach-agent $udp_(%d)\n", c, c
            printf "$ns_ connect $udp_(%d) $null_(%d)\n", c, c
            printf "$ns_ at %.1f \"$cbr_(%d) start\"\n", st, c
            printf "$ns_ at %.1f \"$cbr_(%d) stop\"\n", te, c
        }
    }'
}

# Random Waypoint (bộ sinh tích hợp, chỉ cần awk - chạy được cả trên Windows Git Bash)
#  - Vị trí ban đầu chỉ phụ thuộc seed  => cùng run thì 4 kịch bản có CÙNG vị trí đầu.
#  - Chuỗi điểm đến của node i chỉ phụ thuộc (seed, i) => chỉ tốc độ là khác nhau.
#  - Mỗi chặng: dừng PAUSE giây, chọn điểm đến ngẫu nhiên, tốc độ ~ U[MIN_SPEED, max].
#  - max = 0 => topology tĩnh (SC01), chỉ ghi vị trí ban đầu.
gen_rwp() {
    local speed="$1" seed="$2"
    awk -v n="$NN" -v x="$X" -v y="$Y" -v T="$SIM_TIME" -v p="$PAUSE" \
        -v vmax="$speed" -v vmin="$MIN_SPEED" -v seed="$seed" 'BEGIN {
        printf "# Random Waypoint: nodes %d, area %dx%d, time %d s, pause %d s, speed [%s, %s] m/s, seed %d\n", \
               n, x, y, T, p, (vmax > 0 ? vmin : 0), vmax, seed
        srand(seed)
        for (i = 0; i < n; i++) { px[i] = 1 + rand() * (x - 2); py[i] = 1 + rand() * (y - 2) }
        for (i = 0; i < n; i++) {
            printf "$node_(%d) set X_ %.6f\n", i, px[i]
            printf "$node_(%d) set Y_ %.6f\n", i, py[i]
            printf "$node_(%d) set Z_ 0.000000\n", i
        }
        if (vmax <= 0) exit
        for (i = 0; i < n; i++) {
            srand(seed * 1000 + i + 1)
            cx = px[i]; cy = py[i]; t = p
            while (t < T) {
                dx = 1 + rand() * (x - 2); dy = 1 + rand() * (y - 2)
                v  = vmin + rand() * (vmax - vmin)
                printf "$ns_ at %.6f \"$node_(%d) setdest %.6f %.6f %.6f\"\n", t, i, dx, dy, v
                t += sqrt((dx - cx) ^ 2 + (dy - cy) ^ 2) / v + p
                cx = dx; cy = dy
            }
        }
    }'
}

write_once() {   # write_once <file> <lệnh...>
    local out="$1"; shift
    if [[ -e "$out" ]]; then
        echo "   [bỏ qua] đã có: ${out#$BASE_DIR/}"
        return
    fi
    "$@" > "$out.tmp" && mv "$out.tmp" "$out"
    echo "   [tạo]    ${out#$BASE_DIR/}"
}

if [[ $USE_SETDEST == 1 && ! -x "$SETDEST" ]]; then
    echo "Không tìm thấy setdest: $SETDEST" >&2
    echo "Đặt NS_HOME (thư mục ns-2.35) hoặc SETDEST cho đúng rồi chạy lại." >&2
    exit 1
fi

echo "=== Sinh kịch bản: $NN node, ${X}x${Y} m, ${SIM_TIME}s, pause ${PAUSE}s, $RUNS lần chạy ==="
for i in "${!SCENARIOS[@]}"; do
    sc_dir="${SCENARIOS[$i]}"; speed="${SPEEDS[$i]}"
    sc=$(echo "${sc_dir%%_*}" | tr 'A-Z' 'a-z')     # sc01
    dir="$SCEN_DIR/$sc_dir"
    mkdir -p "$dir"
    echo "--> $sc_dir (tốc độ tối đa $speed m/s)"

    write_once "$dir/traffic_cbr.txt" gen_traffic

    for run in $(seq 1 "$RUNS"); do
        r=$(printf "%02d" "$run")
        mob="$dir/mobility_${sc}_run${r}.txt"
        if [[ $USE_SETDEST == 1 && "$speed" != 0 ]]; then
            write_once "$mob" "$SETDEST" -v 1 -n "$NN" -p "$PAUSE" -M "$speed" \
                                -t "$SIM_TIME" -x "$X" -y "$Y"
        else
            write_once "$mob" gen_rwp "$speed" "$run"
        fi
    done
done
echo "=== Xong. Nhớ commit các file trong scenarios/ để cả nhóm dùng chung. ==="
