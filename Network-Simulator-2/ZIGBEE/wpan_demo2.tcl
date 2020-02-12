#############################################
#             Star over 802.15.4            #
#              (beacon enabled)             #
#      Copyright (c) 2003 Samsung/CUNY      #
# - - - - - - - - - - - - - - - - - - - - - #
#        Prepared by Jianliang Zheng        #
#         (zheng@ee.ccny.cuny.edu)          #
#############################################

# ======================================================================
# Definir opciones
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# Tipo de canal
set val(prop)           Propagation/TwoRayGround   ;# Modelo de radio-   propagacion
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(ifq)            Queue/DropTail/PriQueue    ;# interfaz de tipo de cola
set val(ll)             LL                         ;# tipo de capa de enlace
set val(ant)            Antenna/OmniAntenna        ;# modelo de antena
set val(ifqlen)         150                        ;# paquete maximo en Ifq
set val(nn)             8                          ;# numero de nodos
set val(rp)             AODV                       ;# protocolo de enrutamiento
set val(x)		50
set val(y)		50

set val(nam)		wpan_demo2.nam
set val(traffic)	ftp                        ;# cbr/poisson/ftp

#leer los argumentos de línea de comandos
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

#aqui se hace la lectura de los nodos es decir el tiempo en que cada va a entrar en funcionamiento 

set appTime1            7.0	;# en segundos 
set appTime2            7.1	;# en segundos
set appTime3            7.2	;# en segundos 
set appTime4            7.3	;# en segundos 
set appTime5            7.4	;# en segundos 
set appTime6            7.5	;# en segundos 
set stopTime            100	;# en segundos 

# Inicializacion de las variables globales
set ns_		[new Simulator]
set tracefd     [open ./wpan_demo2.tr w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "wpan_demo2.nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

$ns_ puts-nam-traceall {# nam4wpan #}		;# informar nam que este es un archivo de rastreo para WPAN ( manejo especial necesario)

Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on		;# default = off (debe estar encendido antes de que otros comandos ' wpanNam ' pueden trabajar )

#Mac/802_15_4 wpanNam ColFlashClr gold		;# default = gold

# Para el modelo 'TwoRayGround'
#en esta parte se configura los anillos de radiacion y el alcance, es decir la potencia que va a tener en ese alcance
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
set dist(50m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(50m)
Phy/WirelessPhy set RXThresh_ $dist(50m)

# configurar objeto topografía
#con el comando se define la topologia en este caso circular pero se la modifico para que sea lineal
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

# aqui se crea los nodos  o mas bien se los manda a la creacion para uqe aparezcan en la interfaz grafica 
set god_ [create-god $val(nn)]
#se configura el canal y se le asigana un valor dinamico es decir que va ir cambiando
set chan_1_ [new $val(chan)]

# se hace la configuracion del nodo 

$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace OFF \
		-routerTrace OFF \
		-macTrace ON \
		-movementTrace OFF \
                #-energyModel "EnergyModel" \
                #-initialEnergy 1 \
                #-rxPower 0.3 \
                #-txPower 0.3 \
		-channel $chan_1_ 

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# se desactiva el movimiento aleatorio
}

# fuente ./wpan_demo2.scn
##aqui se define la posicion inicial de los nodos
$node_(0) set X_ 25.0
$node_(0) set Y_ 25.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 0.0
$node_(1) set Y_ 25.0
$node_(1) set Z_ 0.0
$node_(2) set X_ -25.0
$node_(2) set Y_ 25.0
$node_(2) set Z_ 0.0
$node_(3) set X_ 50.0
$node_(3) set Y_ 25.0
$node_(3) set Z_ 0.0
$node_(4) set X_ 75.0
$node_(4) set Y_ 25.0
$node_(4) set Z_ 0.0
$node_(5) set X_ 100.0
$node_(5) set Y_ 25.0
$node_(5) set Z_ 0.0
$node_(6) set X_ 125.0
$node_(6) set Y_ 25.0
$node_(6) set Z_ 0.0
$node_(7) set X_ -50.0
$node_(7) set Y_ 25.0
$node_(7) set Z_ 0.0

#esta parte del codigo es muy importante ya que aqui se va a definir que nodos van a ser los coordinadores y se les va poner una etiqueta, ademas se les da el instante de tiempo en el que van a encenderse, y empiezan a eniviar una senial que va a reconocer a los demas dispositivos que estan alrededor
$ns_ at 0.0	"$node_(7) NodeLabel PAN Coor"
$ns_ at 0.0	"$node_(7) sscs startPANCoord"		;# startPANCoord <txBeacon=1> <BO=3> <SO=3>
$ns_ at 0.0	"$node_(1) NodeLabel PAN Coor"
$ns_ at 0.0	"$node_(1) sscs startPANCoord"
$ns_ at 0.0	"$node_(3) NodeLabel PAN Coor"
$ns_ at 0.0	"$node_(3) sscs startPANCoord"
$ns_ at 0.0	"$node_(5) NodeLabel PAN Coor"
$ns_ at 0.0	"$node_(5) sscs startPANCoord"
#se inicia los nodos o dispositivos esclavos en donde se les da un tiempo para que cada uno se inicialice 
$ns_ at 0.5	"$node_(0) sscs startDevice 1 0"	;# startDevice <isFFD=1> <assoPermit=1> <txBeacon=0> <BO=3> <SO=3>
$ns_ at 1.5	"$node_(2) sscs startDevice 1 0"
$ns_ at 2.5	"$node_(4) sscs startDevice 1 0"
$ns_ at 3.5	"$node_(6) sscs startDevice 1 0"
#$ns_ at 4.5	"$node_(7) sscs startDevice 1 0"
#$ns_ at 5.5	"$node_(0) sscs startDevice 1 0"

Mac/802_15_4 wpanNam PlaybackRate 3ms

$ns_ at $appTime1 "puts \"\nTransmitting data ...\n\""

# Configuracion del flujo de trafico entre los nodos

proc cbrtraffic { src dst interval starttime } {
   global ns_ node_
   set udp_($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp_($src)
   set null_($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null_($dst)
   set cbr_($src) [new Application/Traffic/CBR]
   eval \$cbr_($src) set packetSize_ 70
   eval \$cbr_($src) set interval_ $interval
   eval \$cbr_($src) set random_ 0
   #eval \$cbr_($src) set maxpkts_ 10000
   eval \$cbr_($src) attach-agent \$udp_($src)
   eval $ns_ connect \$udp_($src) \$null_($dst)
   $ns_ at $starttime "$cbr_($src) start"
}

proc poissontraffic { src dst interval starttime } {
   global ns_ node_
   set udp($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp($src)
   set null($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null($dst)
   set expl($src) [new Application/Traffic/Exponential]
   eval \$expl($src) set packetSize_ 70
   eval \$expl($src) set burst_time_ 0
   eval \$expl($src) set idle_time_ [expr $interval*1000.0-70.0*8/250]ms	;# idle_time + pkt_tx_time = interval
   eval \$expl($src) set rate_ 250k
   eval \$expl($src) attach-agent \$udp($src)
   eval $ns_ connect \$udp($src) \$null($dst)
   $ns_ at $starttime "$expl($src) start"
}

if { ("$val(traffic)" == "cbr") || ("$val(traffic)" == "poisson") } {
   puts "\nTraffic: $val(traffic)"
   #Mac/802_15_4 wpanCmd ack4data on
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]
   $ns_ at $appTime1 "Mac/802_15_4 wpanNam PlaybackRate 0.5ms"
   $ns_ at [expr $appTime1 + 0.5] "Mac/802_15_4 wpanNam PlaybackRate 1.5ms"
   $val(traffic)traffic 7 1 0.6 $appTime1
   $val(traffic)traffic 1 3 0.6 $appTime3
   $val(traffic)traffic 3 5 0.6 $appTime5
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) $val(traffic) traffic from node 7 to node 1\""
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime3) $val(traffic) traffic from node 1 to node 3\""
   $ns_ at $appTime5 "$ns_ trace-annotate \"(at $appTime5) $val(traffic) traffic from node 3 to node 5\""
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p MAC -s 0 -d -1 -c navy
   if { "$val(traffic)" == "cbr" } {
   	set pktType cbr
   } else {
   	set pktType exp
   }
   Mac/802_15_4 wpanNam FlowClr -p $pktType -s 0 -d 3 -c blue
   Mac/802_15_4 wpanNam FlowClr -p $pktType -s 4 -d 0 -c green4
   Mac/802_15_4 wpanNam FlowClr -p $pktType -s 0 -d 1 -c cyan4
}
  
proc ftptraffic { src dst starttime } {
   global ns_ node_
   set tcp($src) [new Agent/TCP]
   eval \$tcp($src) set packetSize_ 50
   set sink($dst) [new Agent/TCPSink]
   eval $ns_ attach-agent \$node_($src) \$tcp($src)
   eval $ns_ attach-agent \$node_($dst) \$sink($dst)
   eval $ns_ connect \$tcp($src) \$sink($dst)
   set ftp($src) [new Application/FTP]
   eval \$ftp($src) attach-agent \$tcp($src)
   $ns_ at $starttime "$ftp($src) start"
}
     
if { "$val(traffic)" == "ftp" } {
   puts "\nTraffic: ftp"
   #Mac/802_15_4 wpanCmd ack4data off
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]
   $ns_ at $appTime1 "Mac/802_15_4 wpanNam PlaybackRate 0.20ms"
   $ns_ at [expr $appTime1 + 0.5] "Mac/802_15_4 wpanNam PlaybackRate 1.5ms"
   ftptraffic 7 1 $appTime1
   ftptraffic 1 3 $appTime3
   ftptraffic 3 5 $appTime5
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) ftp traffic from node 7 to node 1\""
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime3) ftp traffic from node 1 to node 3\""
   $ns_ at $appTime5 "$ns_ trace-annotate \"(at $appTime5) ftp traffic from node 3 to node 5\""
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p MAC -s 0 -d -1 -c navy
   Mac/802_15_4 wpanNam FlowClr -p tcp -s 0 -d 3 -c blue
   Mac/802_15_4 wpanNam FlowClr -p ack -s 3 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p tcp -s 0 -d 4 -c green4
   Mac/802_15_4 wpanNam FlowClr -p ack -s 4 -d 0 -c green4
   Mac/802_15_4 wpanNam FlowClr -p tcp -s 0 -d 1 -c cyan4
   Mac/802_15_4 wpanNam FlowClr -p ack -s 1 -d 0 -c cyan4
}

# define el tamanio del nodo el nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 2
}

# llamada a nodos cuando la simulacion es en los extremos
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"NS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"

proc stop {} {
    global ns_ tracefd appTime1 val env
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    foreach index [array names env] {
        #puts "$index: $env($index)"
        if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                set hasDISPLAY 1
        }
    }
    if { ("$val(nam)" == "wpan_demo2.nam") && ("$hasDISPLAY" == "1") } {
    	exec nam wpan_demo2.nam &
    }
}

puts "\nStarting Simulation..."
$ns_ run
