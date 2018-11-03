#!/bin/bash

# Dieses Script startet den omxplayer solange, bis er den tcpstream findet, der 
# in streamstart1.sh und umschalten.sh erzeugt wird. 

# ------------------------ Wichtige Konfigurationsvariablen --------------------------
# Die IP-Adresse des Raspberrys ueber Eingabe von ifconfig auf der Linux Konsole feststellen und eintragen:
ipaddress="192.168.0.59" 

while true
do
   /usr/bin/omxplayer --no-keys -b --live tcp://$ipaddress:5000
done
