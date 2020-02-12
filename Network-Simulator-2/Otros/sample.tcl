
# Create a new simulator object.
set ns [new Simulator]
# Create a nam trace datafile.
set namfile [open sample.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile 658 682
# Create wired nodes.

# ----- Setup wireless environment. ----
set wireless_tracefile [open YourTraceFileName.trace w]
set topography [new Topography]
$ns trace-all $wireless_tracefile

$topography load_flatgrid 658 682
#
# Create God
#
set god_ [create-god 4]
#global node setting
$ns node-config -adhocRouting AODV \
                 -llType LL \
                 -macType Mac/802_11 \
                 -ifqType Queue/DropTail/PriQueue \
                 -ifqLen 50 \
                 -antType Antenna/OmniAntenna \
                 -propType Propagation/TwoRayGround \
                 -phyType Phy/WirelessPhy \
                 -channel [new Channel/WirelessChannel] \
                 -topoInstance $topography \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace ON

# Create wireless nodes.
set node(4) [$ns node]
## node(4) at 535.179504,600.466370
$node(4) set X_ 535.179504
$node(4) set Y_ 600.466370
$node(4) set Z_ 0.0
$node(4) color "black"
$ns initial_node_pos $node(4) 10.000000
$node(4) random-motion 1
$ns at 0.000000 "$node(4) setdest 474.432465 623.040710 1.339200"
set node(3) [$ns node]
## node(3) at 638.817566,527.098816
$node(3) set X_ 638.817566
$node(3) set Y_ 527.098816
$node(3) set Z_ 0.0
$node(3) color "black"
$ns initial_node_pos $node(3) 10.000000
$node(3) random-motion 1
set node(2) [$ns node]
## node(2) at 527.996704,526.842346
$node(2) set X_ 527.996704
$node(2) set Y_ 526.842346
$node(2) set Z_ 0.0
$node(2) color "black"
$ns initial_node_pos $node(2) 10.000000
$node(2) random-motion 1
$ns at 0.000000 "$node(2) setdest 573.914795 553.520447 1.097413"
set node(1) [$ns node]
## node(1) at 417.945404,528.638062
$node(1) set X_ 417.945404
$node(1) set Y_ 528.638062
$node(1) set Z_ 0.0
$node(1) color "black"
$ns initial_node_pos $node(1) 10.000000
$node(1) random-motion 1
$ns at 0.000000 "$node(1) setdest 349.911804 662.031494 3.094366"

# Create links between nodes.
# Add Link Loss Models

# Create agents.
set agent(2) [new Agent/TCPSink]
$ns attach-agent $node(3) $agent(2)
$agent(2) set packetSize_ 210
set agent(1) [new Agent/TCP]
$ns attach-agent $node(1) $agent(1)

$ns color 1 "black"
$agent(1) set fid_ 1
$agent(1) set packetSize_ 210
$agent(1) set window_ 20
$agent(1) set windowInit_ 1
$agent(1) set maxcwnd_ 0

# Create traffic sources and add them to the agent.
set traffic_source(1) [new Application/FTP]
$traffic_source(1) attach-agent $agent(1)
$traffic_source(1) set maxpkts_ 256

# Connect agents.
$ns connect $agent(1) $agent(2)


# Traffic Source actions.
$ns at 0.000000 "$traffic_source(1) start"
$ns at 60.000000 "$traffic_source(1) stop"

# Run the simulation
proc finish {} {
	global ns namfile
	$ns flush-trace
	close $namfile
	exec nam YourNamFileName.nam &	
	exit 0
	}
$ns at 60.000000 "finish"
$ns run
