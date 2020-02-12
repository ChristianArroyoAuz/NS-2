#simple.tcl

set ns [new Simulator]
#Open the nam trace file
set nf [open simulacion2.nam w]
$ns namtrace-all $nf
#Open the general trace file 
set tf [open simulacion2.tr w]
$ns trace-all $tf
#Define a 'finish' procedure 
proc finish {} {
        global ns nf tf
        $ns flush-trace
        #Close the trace files 
        close $nf 
        close $tf
        #Execute nam on the trace file 
        exec nam simulacion2.nam & 
        exit 0
}
#creando nodos
set n0 [$ns node] 
set n1 [$ns node] 
#caracteristicas del enlace
$ns duplex-link $n0 $n1 1.5Mb 10ms DropTail 
#creamos enlace tcp, ip ya está creado
set tcp [new Agent/TCP] 
#TCPSink donde se define....
set tcpsink [new Agent/TCPSink] 
$ns attach-agent $n0 $tcp
#tráfico va de 0 a 1
$ns attach-agent $n1 $tcpsink 
$ns connect $tcp $tcpsink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
#$ns at 1 "puts \"Hello World!\""
#iniciando tx ftp
$ns at 0.2 "$ftp start"
#finalizando conexion
$ns at 1.2 "exit"
$ns run 
