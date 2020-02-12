# NS-2

Network Simulator es un simulador discreto de eventos creado por la Universidad de Berkeley para modelar redes de tipo IP.
En la simulaci�n se toma en cuenta lo que es la estructura (topolog�a) de la red y el tr�fico de paquetes que posee la misma,
con el fin de crear una especie de diagn�stico que nos muestre el comportamiento que se obtiene al tener una red con ciertas caracter�sticas.

Trae implementaciones de protocolos tales como TCP y UDP, que es posible hacerlos comportar como un tr�fico FTP, Telnet, Web, CBR y VBR.
Maneja diversos mecanismos de colas que se generan en los routers, tales como DropTail, RED, CQB, algoritmo de Dijkstra, etc.

Actualmente, el proyecto NS es parte de VINT proyect que desarrolla herramientas para visualizar los resultados de una simulaci�n (por ejemplo, una interfaz gr�fica).
La versi�n con que fue probado (en este informe) es la NS versi�n 2 escrita en los lenguajes de programaci�n C++ y OTcl1.
