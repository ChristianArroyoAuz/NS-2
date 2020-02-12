###############################################################################
#                                                                             #
#         Variable Setting                                                    #
#                                                                             #
###############################################################################

# Skyplex parameters
Mac/Tdma set max_slot_num_ 6           ;# slot per frame (preamble excluded)
Mac/Tdma set slot_packet_len_ 1504     ;# slot size (bytes)
Mac/Tdma set num_frame_ 3              ;# multiframe size (in frames)

Mac/Tdma set bandwidth_ 2.112Mb

global opt
set opt(chan)           Channel/Sat
set opt(bw_up)		2.112Mb        ;# uplink bandwidth
set opt(bw_down)	38.016Mb       ;# downlink bandwidth
set opt(phy)            Phy/Sat
set opt(mac)            Mac/Tdma
set opt(ifq)            Queue/DropTail
set opt(qlim)		1500           ;# queue size (pkts)
set opt(ll)             LL/Sat
set opt(wiredRouting)   OFF


Agent/TCP set window_ 100000	       ;# arbitrarily high adv. wind
Agent/TCP set packetSize_ 1412         ;# TCP payload (for full packet +92B)


Agent/UDP set packetSize_ 65536
Application/Traffic/CBR set packetSize_ 1452

###############################################################################
#                                                                             #
#         Starting Simulation                                                 #
#                                                                             #
###############################################################################

global ns
set ns [new Simulator]

# Tracing enabling must precede link and node creation 
set outfile [open out.tr w]
$ns trace-all $outfile

# Set up satellite and terrestrial nodes

# Configure the node generator for bent-pipe satellite
# geo-repeater uses type Phy/Repeater
$ns node-config -satNodeType geo-repeater \
		-phyType Phy/Repeater \
		-channelType $opt(chan) \
		-downlinkBW $opt(bw_down)  \
		-wiredRouting $opt(wiredRouting)


# GEO satellite at 13 degrees longitude East (Hotbird 6)
set sat [$ns node]
$sat set-position 13

set index 0
set cind 0

set ev_file [open event.tr w]

# This function configure the terminal
proc new-terminal { lat lon } {
	
	global ns opt index sat req ter ev_file

	$ns node-config -satNodeType terminal \
        	        -llType $opt(ll) \
       		        -ifqType $opt(ifq) \
       		        -ifqLen $opt(qlim) \
        	       	-macType $opt(mac) \
        	       	-phyType $opt(phy) \
        	       	-channelType $opt(chan) \
        	       	-downlinkBW $opt(bw_down) \
        	       	-wiredRouting $opt(wiredRouting)

	# Configure the node generator for satellite terminals
	# create terminal and set its position 
	set ter($index) [$ns node]
	$ter($index) set-position $lat $lon

	# create the satellite link
	$ter($index) add-gsl geo $opt(ll) $opt(ifq) $opt(qlim) $opt(mac) \
             $opt(bw_up) $opt(phy) [$sat set downlink_] [$sat set uplink_]

	$ter($index) trace-event $ev_file

	# create node requester object
	set req($index) [$ter($index) install-requester Requester/Constant]

	incr index
}

# Attach agents for CBR traffic generator 
proc new-cbr {src dst rate} {

	global cbr ns udp null cind ter

	set udp($cind) [new Agent/UDP]
	set null($cind) [new Agent/Null]
	set cbr($cind) [new Application/Traffic/CBR]

	$ns attach-agent $ter($src) $udp($cind)
	$ns attach-agent $ter($dst) $null($cind)

	$cbr($cind) attach-agent $udp($cind)
	$cbr($cind) set rate_ $rate

	$ns connect $udp($cind) $null($cind)
	$ns at 0.0 "$cbr($cind) start"

	incr cind
}

# Attach agents for FTP  
proc new-tcp {src dst vers} {

	global ftp ns cind ter ter fd

	set tcp($cind) [$ns create-connection $vers $ter($src) \
		TCPSink/Sack1 $ter($dst) $cind]
	set ftp($cind) [$tcp($cind) attach-app FTP]
	$ns at 0.0 "$ftp($cind) start"

	set fd($cind) [open tcp${cind}.tr w]
	$tcp($cind) set trace_all_ 0
	$tcp($cind) trace cwnd_
	$tcp($cind) attach $fd($cind)

	incr cind
}


###############################################################################
#                                                                             #
#         Setup Scenario                                                      #
#                                                                             #
###############################################################################

# init terminals
new-terminal 43.71 10.38
new-terminal 43.71 10.38

# set requests
$req(0) set request_ 1 
$req(1) set request_ 1

$ns at 200.0 "$req(0) set request_ 10"
$ns at 400.0 "$req(0) set request_ 1"

new-tcp 0 1 TCP/Sack1

# create allocator object
$ter(0) install-allocator Allocator/Proportional

# Add an error model to the receiving terminal node
# set em_ [new ErrorModel]
# $em_ unit pkt
# $em_ set rate_ 0.02
# $em_ ranvar [new RandomVariable/Uniform]
# $n3 interface-errormodel $em_ 

$ns trace-all-satlinks $outfile

# We use centralized routing
set satrouteobject_ [new SatRouteObject]
$satrouteobject_ compute_routes

$ns at 20 "finish"

proc finish {} {
	global ns outfile
	$ns flush-trace
	close $outfile

	exit 0
}

$ns run

