# ============================================================
# DE TAI: DANH GIA HIEU NANG AODV TRONG MANG MANET BANG NS-2
# TV3: Xay dung mo hinh Tcl (cot loi, dung chung cho SC01-SC04)
#
# Chay tu thu muc tcl/ :
#   ns manet_aodv_base.tcl                       (mac dinh: SC01, 0 m/s, seed 1)
#   ns manet_aodv_base.tcl -sc SC03 -speed 10 -seed 1
#
# Co dong lenh:
#   -sc      ma kich ban: SC01 | SC02 | SC03 | SC04      (mac dinh SC01)
#   -speed   toc do toi da (m/s)                          (mac dinh theo kich ban:
#                                                          SC01=0 SC02=5 SC03=10 SC04=15)
#   -seed    seed ngau nhien (so nguyen)                  (mac dinh 1)
#   -tr      duong dan file trace .tr
#            (mac dinh ../trace/raw/trace_<sc>_run<seed>.tr)
#   -nam     duong dan file NAM .nam
#            (mac dinh ../trace/raw/nam_<sc>_run<seed>.nam)
#   -mob     file mobility cua TV4 (setdest)
#   -traffic file traffic cua TV4 (cbrgen)
#   -force   cho phep ghi de trace da ton tai (chi dung khi chay thu)
#   -internal cho phep dung bo sinh NOI BO khi thieu file TV4 (chi de TV3 test,
#            KHONG dung de tao trace chinh thuc)
#
# Nap mobility/traffic (uu tien theo thu tu):
#   1. Neu co -mob / -traffic: nap file do bang "source".
#   2. Neu khong, tu tim file cua TV4 theo quy uoc:
#        ../scenarios/<SC>_speed_<v>/mobility_<sc>_run<YY>.txt
#        ../scenarios/<SC>_speed_<v>/mobility_<sc>.txt
#        ../scenarios/<SC>_speed_<v>/traffic_cbr.txt
#        ../scenarios/traffic_cbr.txt
#   3. Neu van khong co file cua TV4: script DUNG VOI LOI (khong tu sinh ngam).
#      Chi khi co co -internal moi dung bo sinh NOI BO (Random Waypoint +
#      4 luong CBR) de TV3 tu kiem tra mo hinh. Ket qua CHINH THUC phai dung file TV4.
#
# Hai file cua TV4 duoc nap bang "source" nen phai dung dung ten bien
# cua script nay: $ns_ (simulator), $node_($i) (node), $god_ (GOD).
# ============================================================

# -------------------- 1. THAM SO CO DINH --------------------

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
set val(pause)          5.0

# Luong CBR noi bo (chi dung khi khong co file traffic cua TV4).
set val(packetSize)     512
set val(cbrInterval)    0.25
set val(flowStart)      1.0
set val(flowStop)       99.0

# Nut nguon / dich de to mau tren NAM (khop voi tcl/README.md).
set val(srcNodes)       {0 2 5 8}
set val(dstNodes)       {19 16 14 12}

array set defSpeed {SC01 0 SC02 5 SC03 10 SC04 15}

# -------------------- 2. DOC CO DONG LENH --------------------

proc usage {} {
    puts "Cach dung: ns manet_aodv_base.tcl \[-sc SC01..SC04\] \[-speed v\] \[-seed n\]"
    puts "           \[-tr file.tr\] \[-nam file.nam\] \[-mob file\] \[-traffic file\] \[-force\] \[-internal\]"
}

set val(sc)       SC01
set val(speed)    ""
set val(seed)     1
set val(tr)       ""
set val(nam)      ""
set val(mob)      ""
set val(traffic)  ""
set val(force)    0
set val(internal) 0

set k 0
while {$k < $argc} {
    set flag [lindex $argv $k]

    # Co khong can gia tri.
    if {[string equal $flag "-force"]} {
        set val(force) 1
        incr k
        continue
    }
    if {[string equal $flag "-internal"]} {
        set val(internal) 1
        incr k
        continue
    }

    if {($k + 1) >= $argc} {
        puts "LOI: co $flag thieu gia tri."
        usage
        exit 1
    }
    set value [lindex $argv [expr {$k + 1}]]

    switch -- $flag {
        -sc      { set val(sc) [string toupper $value] }
        -speed   { set val(speed) $value }
        -seed    { set val(seed) $value }
        -tr      { set val(tr) $value }
        -nam     { set val(nam) $value }
        -mob     { set val(mob) $value }
        -traffic { set val(traffic) $value }
        default {
            puts "LOI: khong nhan ra co $flag"
            usage
            exit 1
        }
    }
    incr k 2
}

# Kiem tra gia tri.
if {![info exists defSpeed($val(sc))]} {
    puts "LOI: kich ban '$val(sc)' khong hop le (chi SC01, SC02, SC03, SC04)."
    exit 1
}
if {![string is integer -strict $val(seed)]} {
    puts "LOI: seed '$val(seed)' phai la so nguyen."
    exit 1
}
if {[string equal $val(speed) ""]} {
    set val(speed) $defSpeed($val(sc))
}
if {![string is double -strict $val(speed)] || $val(speed) < 0} {
    puts "LOI: speed '$val(speed)' phai la so >= 0."
    exit 1
}

# -------------------- 3. DUONG DAN VA TEN FILE --------------------

set scLower  [string tolower $val(sc)]
set speedInt [expr {int($val(speed))}]
set runTag   [format "%02d" $val(seed)]
set scenDir  "../scenarios/$val(sc)_speed_$speedInt"

# Trace/NAM: mac dinh vao ../trace/raw/, ten theo seed (khong gan cung run01).
if {[string equal $val(tr) ""]} {
    set val(tr) "../trace/raw/trace_${scLower}_run${runTag}.tr"
}
if {[string equal $val(nam) ""]} {
    set val(nam) "../trace/raw/nam_${scLower}_run${runTag}.nam"
}

# Tim file mobility cua TV4.
if {[string equal $val(mob) ""]} {
    foreach c [list \
        "$scenDir/mobility_${scLower}_run${runTag}.txt" \
        "$scenDir/mobility_${scLower}.txt"] {
        if {[file exists $c]} {
            set val(mob) $c
            break
        }
    }
} elseif {![file exists $val(mob)]} {
    puts "LOI: khong tim thay file mobility: $val(mob)"
    exit 1
}

# Tim file traffic cua TV4.
if {[string equal $val(traffic) ""]} {
    foreach c [list \
        "$scenDir/traffic_cbr.txt" \
        "../scenarios/traffic_cbr.txt"] {
        if {[file exists $c]} {
            set val(traffic) $c
            break
        }
    }
} elseif {![file exists $val(traffic)]} {
    puts "LOI: khong tim thay file traffic: $val(traffic)"
    exit 1
}

# Bat buoc co file cua TV4 (tru khi chay thu voi -internal).
if {!$val(internal)} {
    if {[string equal $val(mob) ""]} {
        puts "LOI: khong tim thay file mobility cua TV4 cho $val(sc) seed $val(seed)."
        puts "     Da tim: $scenDir/mobility_${scLower}_run${runTag}.txt"
        puts "             $scenDir/mobility_${scLower}.txt"
        puts "     Hay nho TV4 tao file, hoac truyen -mob <file>."
        exit 1
    }
    if {[string equal $val(traffic) ""]} {
        puts "LOI: khong tim thay file traffic_cbr.txt cua TV4."
        puts "     Da tim: $scenDir/traffic_cbr.txt"
        puts "             ../scenarios/traffic_cbr.txt"
        puts "     Hay nho TV4 tao file, hoac truyen -traffic <file>."
        exit 1
    }
}

# Khong ghi de trace goc (tru khi co -force).
file mkdir [file dirname $val(tr)]
file mkdir [file dirname $val(nam)]
if {!$val(force)} {
    foreach f [list $val(tr) $val(nam)] {
        if {[file exists $f]} {
            puts "LOI: $f da ton tai. Khong ghi de trace goc."
            puts "     Doi seed/ten file, di chuyen file cu, hoac them co -force khi chay thu."
            exit 1
        }
    }
}

# Seed cho bo sinh so cua NS-2 (backoff MAC...) va cua Tcl (bo sinh noi bo).
ns-random $val(seed)
expr {srand($val(seed))}

# -------------------- 4. KHOI TAO SIMULATOR --------------------

set ns_ [new Simulator]

set tracefd [open $val(tr) w]
set namfd   [open $val(nam) w]

$ns_ trace-all $tracefd

# -------------------- 5. CAU HINH MOI TRUONG KHONG DAY --------------------

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set chan_ [new $val(chan)]

# GOD quan ly thong tin cac node (file setdest co the dung $god_).
set god_ [create-god $val(nn)]

# Chi bat trace tang Agent (AGT: goi du lieu CBR) va Router (RTR: goi AODV).
# Tat MAC trace va movement trace de file trace gon, de TV5 phan tich bang AWK.
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
    -macTrace OFF \
    -movementTrace OFF

$ns_ namtrace-all-wireless $namfd $val(x) $val(y)

# -------------------- 6. TAO 20 NODE MANET --------------------
# Chi tao node. Vi tri ban dau va chuyen dong do mobility dat o buoc 7.

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
}

# -------------------- 7. MOBILITY --------------------

# Bo sinh Random Waypoint NOI BO (chi dung khi khong co file cua TV4).
proc random-waypoint {ns node maxspeed pause xmax ymax} {
    if {$maxspeed <= 0} {
        return
    }

    set currentX [$node set X_]
    set currentY [$node set Y_]

    set destX [expr {rand() * $xmax}]
    set destY [expr {rand() * $ymax}]

    # Tranh toc do bang 0 de node co the di chuyen den dich.
    set speed [expr {0.1 + rand() * ($maxspeed - 0.1)}]

    set dx [expr {$destX - $currentX}]
    set dy [expr {$destY - $currentY}]
    set distance [expr {sqrt($dx * $dx + $dy * $dy)}]

    $node setdest $destX $destY $speed

    set travelTime [expr {$distance / $speed}]
    set nextTime [expr {[$ns now] + $travelTime + $pause}]

    $ns at $nextTime "random-waypoint $ns $node $maxspeed $pause $xmax $ymax"
}

if {![string equal $val(mob) ""]} {
    puts "Mobility : $val(mob)  (file cua TV4)"
    source $val(mob)
} else {
    puts "CANH BAO : che do -internal: dung Random Waypoint NOI BO (chi de test, khong dung cho trace chinh thuc)."
    for {set i 0} {$i < $val(nn)} {incr i} {
        $node_($i) set X_ [expr {rand() * $val(x)}]
        $node_($i) set Y_ [expr {rand() * $val(y)}]
        $node_($i) set Z_ 0.0
    }
    if {$val(speed) > 0} {
        for {set i 0} {$i < $val(nn)} {incr i} {
            $ns_ at 0.1 "random-waypoint $ns_ $node_($i) $val(speed) $val(pause) $val(x) $val(y)"
        }
    }
}

# -------------------- 8. TRAFFIC UDP/CBR --------------------

if {![string equal $val(traffic) ""]} {
    puts "Traffic  : $val(traffic)  (file cua TV4)"
    source $val(traffic)
} else {
    puts "CANH BAO : che do -internal: dung 4 luong CBR NOI BO (chi de test, khong dung cho trace chinh thuc)."
    set flowId 0
    foreach src $val(srcNodes) dst $val(dstNodes) {
        set udp_($flowId) [new Agent/UDP]
        $ns_ attach-agent $node_($src) $udp_($flowId)

        set null_($flowId) [new Agent/Null]
        $ns_ attach-agent $node_($dst) $null_($flowId)

        $ns_ connect $udp_($flowId) $null_($flowId)

        set cbr_($flowId) [new Application/Traffic/CBR]
        $cbr_($flowId) set packetSize_ $val(packetSize)
        $cbr_($flowId) set interval_ $val(cbrInterval)
        $cbr_($flowId) set random_ 0
        $cbr_($flowId) attach-agent $udp_($flowId)

        $ns_ at $val(flowStart) "$cbr_($flowId) start"
        $ns_ at $val(flowStop)  "$cbr_($flowId) stop"

        incr flowId
    }
}

# -------------------- 9. HIEN THI TREN NAM --------------------
# Dat vi tri NAM sau khi mobility da gan X_, Y_.
# Xanh la: nut nguon | Do: nut dich | Xanh duong: nut trung gian.

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 20

    if {[lsearch -exact $val(srcNodes) $i] >= 0} {
        set col green
    } elseif {[lsearch -exact $val(dstNodes) $i] >= 0} {
        set col red
    } else {
        set col blue
    }
    $ns_ at 0.0 "$node_($i) color $col"
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ at $val(stop) "$node_($i) reset"
}

# -------------------- 10. KET THUC MO PHONG --------------------

proc finish {} {
    global ns_ tracefd namfd val

    $ns_ flush-trace

    close $tracefd
    close $namfd

    puts "=============================================="
    puts "MO PHONG MANET AODV DA KET THUC"
    puts "Kich ban       : $val(sc)"
    puts "So node        : $val(nn)"
    puts "Toc do toi da  : $val(speed) m/s"
    puts "Seed           : $val(seed)"
    puts "Thoi gian      : $val(stop) giay"
    if {[string equal $val(mob) ""]} {
        puts "Mobility       : NOI BO (chi de test)"
    } else {
        puts "Mobility       : $val(mob)"
    }
    if {[string equal $val(traffic) ""]} {
        puts "Traffic        : NOI BO (chi de test)"
    } else {
        puts "Traffic        : $val(traffic)"
    }
    puts "Trace          : $val(tr)"
    puts "NAM            : $val(nam)"
    puts "=============================================="
    puts "Mo NAM bang lenh: nam $val(nam)"

    exit 0
}

$ns_ at $val(stop) "finish"

puts "Bat dau mo phong $val(sc) ..."
puts "AODV | $val(nn) nodes | $val(x) x $val(y) m | speed=$val(speed) m/s | seed=$val(seed)"

$ns_ run
