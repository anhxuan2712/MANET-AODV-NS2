# ============================================================
# DE TAI: DANH GIA HIEU NANG AODV TRONG MANG MANET BANG NS-2
# TV3: Xay dung mo hinh Tcl
# Cau hinh mac dinh: SC01 - toc do di chuyen 0 m/s
#
# Cach chay:
#   ns manet_aodv_sc01.tcl
#
# Hoac truyen tham so:
#   ns manet_aodv_sc01.tcl SC02 5 1
#   ns manet_aodv_sc01.tcl SC03 10 1
#   ns manet_aodv_sc01.tcl SC04 15 1
#
# Tham so lan luot: ma_kich_ban toc_do_toi_da seed
# ============================================================

# -------------------- 1. THAM SO MO PHONG --------------------

set val(chan)           Channel/WirelessChannel
set val(prop)           Propagation/TwoRayGround
set val(netif)          Phy/WirelessPhy
set val(mac)            Mac/802_11
set val(ifq)            Queue/DropTail/PriQueue
set val(ll)             LL
set val(ant)            Antenna/OmniAntenna
set val(ifqlen)         50
set val(nn)             20
set val(rp)             AODV

set val(x)              500
set val(y)              500
set val(stop)           100.0

set val(packetSize)     512
set val(cbrInterval)    0.25
set val(flowStart)      1.0
set val(flowStop)       99.0

# Mac dinh la SC01: cac node dung yen (0 m/s).
set val(scenario)       SC01
set val(speed)          0.0
set val(pause)          5.0
set val(seed)           1

# Cho phep thay doi kich ban, toc do va seed tu dong lenh.
if {$argc >= 1} {
    set val(scenario) [lindex $argv 0]
}
if {$argc >= 2} {
    set val(speed) [lindex $argv 1]
}
if {$argc >= 3} {
    set val(seed) [lindex $argv 2]
}

# Khoi tao bo sinh so ngau nhien de co the lap lai thi nghiem.
ns-random $val(seed)

# Ten file dau ra theo quy uoc cua nhom.
set tracefile "trace_[string tolower $val(scenario)]_run01.tr"
set namfile   "nam_[string tolower $val(scenario)]_run01.nam"

# -------------------- 2. KHOI TAO SIMULATOR --------------------

set ns_ [new Simulator]

set tracefd [open $tracefile w]
set namfd   [open $namfile w]

# Ghi trace tong quat va trace phuc vu NAM.
$ns_ trace-all $tracefd

# -------------------- 3. CAU HINH MOI TRUONG KHONG DAY --------------------

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set chan_ [new $val(chan)]

# GOD quan ly thong tin cac node trong mang khong day.
create-god $val(nn)

$ns_ node-config \
    -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channel $chan_ \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace ON \
    -movementTrace ON

$ns_ namtrace-all-wireless $namfd $val(x) $val(y)

# -------------------- 4. TAO 20 NODE MANET --------------------

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns_ node]

    # Dat vi tri ban dau ngau nhien trong khu vuc 500 x 500 m.
    set x [expr rand() * $val(x)]
    set y [expr rand() * $val(y)]

    $node_($i) set X_ $x
    $node_($i) set Y_ $y
    $node_($i) set Z_ 0.0

    # Khong kich hoat co che di chuyen mac dinh cua node.
    $node_($i) random-motion 0

    # Hien thi node tren NAM.
    $ns_ initial_node_pos $node_($i) 20
}

# -------------------- 5. MO HINH DI CHUYEN RANDOM WAYPOINT --------------------
# TV4 co the thay doi toc do toi da bang tham so dong lenh.
# Neu speed = 0, cac node giu nguyen vi tri (SC01).
# Neu speed > 0, moi node chon diem den va toc do ngau nhien,
# sau khi den noi se dung trong pause giay roi chon diem moi.

proc random-waypoint {ns node maxspeed pause xmax ymax} {
    if {$maxspeed <= 0} {
        return
    }

    set currentX [$node set X_]
    set currentY [$node set Y_]

    set destX [expr rand() * $xmax]
    set destY [expr rand() * $ymax]

    # Tranh toc do bang 0 de node co the di chuyen den dich.
    set speed [expr 0.1 + rand() * ($maxspeed - 0.1)]
    if {$speed > $maxspeed} {
        set speed $maxspeed
    }

    set dx [expr $destX - $currentX]
    set dy [expr $destY - $currentY]
    set distance [expr sqrt($dx * $dx + $dy * $dy)]

    $node setdest $destX $destY $speed

    set travelTime [expr $distance / $speed]
    set nextTime [expr [$ns now] + $travelTime + $pause]

    $ns at $nextTime "random-waypoint $ns $node $maxspeed $pause $xmax $ymax"
}

# Bat dau Random Waypoint cho tung node.
if {$val(speed) > 0} {
    for {set i 0} {$i < $val(nn)} {incr i} {
        $ns_ at 0.1 "random-waypoint $ns_ $node_($i) $val(speed) $val(pause) $val(x) $val(y)"
    }
}

# -------------------- 6. TAO CAC LUONG UDP/CBR --------------------
# README khong quy dinh so luong luong CBR.
# Script su dung 4 luong mau, moi luong co 1 node gui va 1 node nhan.
# Cac tham so luong du lieu duoc giu co dinh giua cac kich ban.

set flowPairs {
    {0 10}
    {2 12}
    {4 14}
    {6 16}
}

set flowId 0

foreach pair $flowPairs {
    set src [lindex $pair 0]
    set dst [lindex $pair 1]

    # Tao UDP agent tai node nguon.
    set udp_($flowId) [new Agent/UDP]
    $ns_ attach-agent $node_($src) $udp_($flowId)

    # Tao Null agent tai node dich.
    set null_($flowId) [new Agent/Null]
    $ns_ attach-agent $node_($dst) $null_($flowId)

    # Ket noi UDP nguon voi Null dich.
    $ns_ connect $udp_($flowId) $null_($flowId)

    # Tao ung dung CBR va gan vao UDP.
    set cbr_($flowId) [new Application/Traffic/CBR]
    $cbr_($flowId) set packetSize_ $val(packetSize)
    $cbr_($flowId) set interval_ $val(cbrInterval)
    $cbr_($flowId) set random_ 0
    $cbr_($flowId) attach-agent $udp_($flowId)

    # Bat dau va ket thuc gui du lieu.
    $ns_ at $val(flowStart) "$cbr_($flowId) start"
    $ns_ at $val(flowStop) "$cbr_($flowId) stop"

    incr flowId
}

# -------------------- 7. KET THUC MO PHONG --------------------

proc finish {} {
    global ns_ tracefd namfd tracefile namfile val

    $ns_ flush-trace

    close $tracefd
    close $namfd

    puts "=============================================="
    puts "MO PHONG MANET AODV DA KET THUC"
    puts "Kich ban       : $val(scenario)"
    puts "So node        : $val(nn)"
    puts "Toc do toi da  : $val(speed) m/s"
    puts "Thoi gian      : $val(stop) giay"
    puts "Trace          : $tracefile"
    puts "NAM            : $namfile"
    puts "=============================================="
    puts "Mo NAM bang lenh: nam $namfile"

    exit 0
}

$ns_ at $val(stop) "finish"

puts "Bat dau mo phong $val(scenario) ..."
puts "AODV | $val(nn) nodes | $val(x) x $val(y) m | speed=$val(speed) m/s"

$ns_ run
