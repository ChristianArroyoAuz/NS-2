set stopTime 100
set BO 3
set SO 3
set speed 1
#speed is in m/s

# Parametros TDMA
Mac/Tdma set max_slot_num_ 8           ;# slot per frame (preamble excluded)
Mac/Tdma set slot_packet_len_ 1504     ;# slot size (bytes)
Mac/Tdma set num_frame_ 3              ;# multiframe size (in frames)

Mac/Tdma set bandwidth_ 2.112Mb
# Define options

set val(chan)        Channel/WirelessChannel    ;# Channel Type
set opt(bw_up)		2.112Mb        ;# uplink bandwidth
set opt(bw_down)	38.016Mb       ;# downlink bandwidth
set val(prop)        Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)         Phy/WirelessPhy/802_15_4
set val(mac)         Mac/Tdma
set val(ifq)           Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)          Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)      50                         ;# max packet in ifq
set val(nn)          2                         ;# number of mobilenodes
set val(rp)          AODV                       ;# routing protocol
set val(x)           50
set val(y)           50
set opt(err)        UniformErrorProc

set val(nam)                2nodes.nam
set val(traffic) cbr                        ;# cbr/poisson/ftp

#read command line arguments
proc getCmdArgu {argc argv} {
        global val
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
        }
}
getCmdArgu $argc $argv

##This is optional error model. you can delete it if u dont need it
proc UniformErrorProc {} {
#          puts "useing error model-"
            set err [new ErrorModel]
#          $err unit pkt
            $err set rate_ 0.05
            return $err
}

# Initialize Global Variables
set ns_             [new Simulator]
set tracefd     [open ./2nodes.tr w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "2nodes.nam" } {
       set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

$ns_ puts-nam-traceall {# nam4wpan #}                   ;# inform nam that this is a trace file for wpan (special handling needed)

#Mac/802_15_4 wpanNam macType $para1  # added by pranesh
Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on                   ;# default = off (should be turned on before other 'wpanNam' commands can work)
#Mac/802_15_4 wpanNam ColFlashClr gold             ;# default = gold

# For model 'TwoRayGround'
set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(15m)
Phy/WirelessPhy set RXThresh_ $dist(15m)

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
#ns-random 1  gives same result in trace file everytime simulation is done
#ns-random 0 gives different result in trace file when simulated
ns-random 0
# Create God
set god_ [create-god $val(nn)]
set chan_1_ [new $val(chan)]

# configure node
$ns_ node-config -adhocRouting $val(rp) \
                        -llType $val(ll) \
                        -macType $val(mac) \
                        -ifqType $val(ifq) \
                        -ifqLen $val(ifqlen) \
                        -antType $val(ant) \
                        -propType $val(prop) \
                        -phyType $val(netif) \
                        -topoInstance $topo \
                        -agentTrace ON \
                        -routerTrace OFF \
                        -macTrace ON \
                        -movementTrace OFF \
                        -energyModel "EnergyModel" \
                        -initialEnergy 10 \
                        -idlePower 0.00279 \
                        -rxPower 0.0565 \
                        -txPower 0.048 \
                        -sleepPower 0.000030 \
                        -transitionPower 0.002 \
                        -transitionTime 0.0002 \
                        -IncomingErrProc $opt(err) \
                        -channel $chan_1_ 

for {set i 0} {$i < $val(nn) } {incr i} {
            set node_($i) [$ns_ node]      
            $node_($i) random-motion 0             ;# disable random motion
}
##initial postion of node 0 and node 1
$node_(0) set X_ 25.0
$node_(0) set Y_ 25.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 10.0
$node_(1) set Y_ 25.0
$node_(1) set Z_ 0.0


$ns_ at 0.0  "$node_(0) NodeLabel PAN Coor"
$ns_ at 0.0  "$node_(0) sscs startPANCoord 1 $BO $SO"  ;# startPANCoord <txBeacon=1> <BO=3> <SO=3>
$ns_ at 5  "$node_(1) sscs startDevice 0 0 0 $BO $SO"

Mac/802_15_4 wpanNam PlaybackRate 3ms
$ns_ at 50 "puts \"\nTransmitting data ...\n\""

##define traffic type and date rate 
set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp_(0)
set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(0) $null_(0)
set cbr_ [new Application/Traffic/CBR]
$cbr_ set packetSize_ 100
$cbr_ set interval_ 0.2
$cbr_ set random_ 1
$cbr_ attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 50 "$cbr_ start"
# the following command is for moving the node 1. you can disable it if you dont need it.
#node 1 will start to meet at time 70 towards the cordinate(42,25) at the speed of $speed. $speed is defined at top.
$ns_ at 70 "$node_(1) setdest 42.00 25 $speed"

# defines the node size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
            $ns_ initial_node_pos $node_($i) 2
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

##to stop simulation
$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"

proc stop {} {
    global ns_ tracefd appTime val env
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    foreach index [array names env] {

        if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                set hasDISPLAY 1
        }
    }
}
puts "\nStarting Simulation..."
$ns_ run

