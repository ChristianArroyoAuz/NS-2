#SimulacionInalambricas.tcl

#****************************************************************
#								*
#	Simulacion de trafico FTP y CBR sobre TCP		*
#								*
# 		Comunicaciones Inalambricas			*
# Arroyo Christian						*
# Gualli Franscisco						*
# Parra ANdres							*
# Shaigua Mayra							*
# Tapia Juan							*
# Vasquez Edison						*
# Viracocha Javier						*
#								*
# 10/08/2016							*
#****************************************************************

#se crea el objeto simulador
set ns [new Simulator]

#Open the general trace file
set tf [open SimulacionInalambricas.tr w]
$ns trace-all $tf

#Open the nam trace file
set nf [open SimulacionInalambricas.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
	global ns tf nf
	$ns flush-trace

	#Close the trace files
	close $nf
	close $tf

	#Execute nam on the trace file
	exec nam SimulacionInalambricas.nam &
	exit 0
}

#se define el color para los enlaces
#$ns color 40 red
#$ns color 41 blue

#se asocia el color a los paquetes
#$tcp set fid_40		;#red packets
#$tcpsink set fid_41		;#blue packets

#se crean los nodos
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#se crean los enlaces
$ns duplex-link $n0 $n1 10Mb 20mseg DropTail	;#enlace 1
$ns duplex-link $n0 $n2 5Mb 10mseg DropTail	;#enlcae 2
$ns duplex-link $n0 $n3 1Mb 10mseg DropTail	;#enlace 3
$ns duplex-link $n0 $n4 8Mb 20mseg DropTail	;#enlace 4

#se crea el agente TCP
set tcp1 [new Agent/TCP]			;#el que va a generar el trafico
set tcp2 [new Agent/TCP]
set tcp3 [new Agent/TCP]
set tcp4 [new Agent/TCP]

set tcpsink1 [new Agent/TCPSink]		;#el que va a recibir el trafico
set tcpsink2 [new Agent/TCPSink]
set tcpsink3 [new Agent/TCPSink]
set tcpsink4 [new Agent/TCPSink]

#vinculo el agente n0 con el generador del trafico
$ns attach-agent $n0 $tcp1
$tcp1 set fid_ 40
$ns color 40 blue

$ns attach-agent $n0 $tcp2
$tcp2 set fid_ 41
$ns color 41 red

$ns attach-agent $n0 $tcp3
$tcp3 set fid_ 42
$ns color 42 green

$ns attach-agent $n0 $tcp4
$tcp4 set fid_ 43
$ns color 43 orange
	
#vinculo el agente n1 con el que recibe el trafico
$ns attach-agent $n1 $tcpsink1
$ns attach-agent $n2 $tcpsink2
$ns attach-agent $n3 $tcpsink3
$ns attach-agent $n4 $tcpsink4
	
#se vincula el nodo origen con el receptor
$ns connect $tcp1 $tcpsink1
$ns connect $tcp2 $tcpsink2
$ns connect $tcp3 $tcpsink3
$ns connect $tcp4 $tcpsink4
	
#se genera el trafico FTP para el enlace 1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns at 0.1 "$ftp1 start"
$ns at 5.0 "finish"
#$ns at 1.2 "exit"

#se genera el trafico FTP para el enlace 2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

$ns at 0.2 "$ftp2 start"
$ns at 5.0 "finish"

#se genera el trafico CBR para el enlace 3
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $tcp3

$ns at 0.3 "$cbr1 start"
$ns at 5.0 "finish"

#se genera el trafico CBR para el enlace 4
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $tcp4

$ns at 0.4 "$cbr2 start"
$ns at 5.0 "finish"

#Run the simulation
$ns run
