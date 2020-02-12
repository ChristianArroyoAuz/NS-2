#simple.tcl

set ns [new Simulator]
#Open the nam trace file
set nf [open udp.nam w]

$ns color 1 Blue 
$ns color 2 Red 
$ns namtrace-all $nf
#Open the general trace file 
set tf [open udp.tr w]
$ns trace-all $tf
#Define a 'finish' procedure 
proc finish {} {
        global ns nf tf
        $ns flush-trace
        #Close the trace files 
        close $nf 
        close $tf
        #Execute nam on the trace file 
        exec nam udp.nam & 
        exit 0
}
#creando nodos
set n0 [$ns node]
set n1 [$ns node] 
#caracteristicas del enlace
$ns duplex-link $n0 $n1 1.5Mb 10ms DropTail 
#creamos enlace tcp, ip ya está creado
set udp [new Agent/UDP] 
#TCPSink donde se define....
set null0 [new Agent/Null] 
$ns attach-agent $n0 $udp
#tráfico va de 0 a 1
$ns attach-agent $n1 $null0
$ns connect $udp $null0
$udp set class_ 2
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp
#$ns at 1 "puts \"Hello World!\""
#iniciando tx ftp
$ns at 0.2 "$cbr0 start"
#finalizando conexion
$ns at 1.2 "exit"
$ns run 
