#!/bin/bash
# ============================================================
# Chay tuan tu 4 kich ban SC01-SC04 voi manet_aodv_base.tcl
# Chay tu thu muc tcl/ :
#   chmod +x run_simulation.sh
#   ./run_simulation.sh            # seed 1
#   ./run_simulation.sh 1 2 3      # nhieu seed (run01, run02, run03)
#   FORCE=1 ./run_simulation.sh    # cho phep ghi de trace cu (chi khi chay thu)
#   INTERNAL=1 ./run_simulation.sh # dung bo sinh noi bo khi TV4 chua co file (chi de test,
#                                  # KHONG dung cho trace chinh thuc)
#
# Trace/NAM -> ../trace/raw/     Log -> ../trace/logs/
# ============================================================

set -u
cd "$(dirname "$0")" || exit 1

if ! command -v ns >/dev/null 2>&1; then
    echo "LOI: khong tim thay lenh 'ns'. Kiem tra cai dat NS-2.35 (nho TV2)."
    exit 1
fi

SEEDS=("$@")
if [ ${#SEEDS[@]} -eq 0 ]; then
    SEEDS=(1)
fi
for s in "${SEEDS[@]}"; do
    if ! [[ "$s" =~ ^[0-9]+$ ]]; then
        echo "LOI: seed '$s' phai la so nguyen khong am."
        exit 1
    fi
done

SCENARIOS=("SC01:0" "SC02:5" "SC03:10" "SC04:15")

FORCE_FLAG=""
if [ "${FORCE:-0}" = "1" ]; then
    FORCE_FLAG="-force"
fi
if [ "${INTERNAL:-0}" = "1" ]; then
    FORCE_FLAG="$FORCE_FLAG -internal"
    echo "CANH BAO: che do INTERNAL - trace tao ra KHONG dung cho ket qua chinh thuc."
fi

mkdir -p ../trace/raw ../trace/logs

fail=0
summary=()

for seed in "${SEEDS[@]}"; do
    run=$(printf "%02d" "$seed")

    for item in "${SCENARIOS[@]}"; do
        sc="${item%%:*}"
        speed="${item##*:}"
        lower=$(echo "$sc" | tr 'A-Z' 'a-z')

        tr="../trace/raw/trace_${lower}_run${run}.tr"
        nam="../trace/raw/nam_${lower}_run${run}.nam"
        log="../trace/logs/log_${lower}_run${run}.txt"

        echo "=== Chay ${sc} | ${speed} m/s | seed ${seed} ==="

        # shellcheck disable=SC2086
        ns manet_aodv_base.tcl -sc "$sc" -speed "$speed" -seed "$seed" \
            -tr "$tr" -nam "$nam" $FORCE_FLAG > "$log" 2>&1
        status=$?

        if [ $status -ne 0 ] || [ ! -s "$tr" ]; then
            echo "    THAT BAI (ma loi $status). Xem log: $log"
            summary+=("${sc} run${run}: THAT BAI")
            fail=1
            continue
        fi

        # Kiem tra nhanh (khong phai so lieu chinh thuc - TV5 se tinh bang script rieng).
        sent=$(awk '$1=="s" && $4=="AGT" && $7=="cbr" {n++} END{print n+0}' "$tr")
        recv=$(awk '$1=="r" && $4=="AGT" && $7=="cbr" {n++} END{print n+0}' "$tr")
        size=$(du -h "$tr" | cut -f1)

        if [ "$recv" -eq 0 ]; then
            note="CANH BAO: khong co goi CBR nhan duoc (kiem tra ket noi/traffic)"
        else
            note="OK"
        fi

        echo "    Trace: $tr ($size) | CBR gui=$sent nhan=$recv | $note"
        summary+=("${sc} run${run}: gui=${sent} nhan=${recv} (${size}) - ${note}")
    done
done

echo
echo "================ TONG KET ================"
for line in "${summary[@]}"; do
    echo "$line"
done
echo "=========================================="

exit $fail
