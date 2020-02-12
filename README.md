# NS-2

Network Simulator es un simulador discreto de eventos creado por la Universidad de Berkeley para modelar redes de tipo IP.
En la simulación se toma en cuenta lo que es la estructura (topología) de la red y el tráfico de paquetes que posee la misma,
con el fin de crear una especie de diagnóstico que nos muestre el comportamiento que se obtiene al tener una red con ciertas características.

Trae implementaciones de protocolos tales como TCP y UDP, que es posible hacerlos comportar como un tráfico FTP, Telnet, Web, CBR y VBR.
Maneja diversos mecanismos de colas que se generan en los routers, tales como DropTail, RED, CQB, algoritmo de Dijkstra, etc.

Actualmente, el proyecto NS es parte de VINT proyect que desarrolla herramientas para visualizar los resultados de una simulación (por ejemplo, una interfaz gráfica).
La versión con que fue probado (en este informe) es la NS versión 2 escrita en los lenguajes de programación C++ y OTcl1.
