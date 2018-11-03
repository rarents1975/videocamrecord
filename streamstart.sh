#!/bin/bash

# Dieses Script macht folgendes:
# - Streamen des Videostreams von der Kamera ins Internet
# - Parallel dazu Aufnahme als mp4 auf dem Raspberry
# - Parallel dazu Anzeige des Kamerabildes auf dem Raspistream (streamen in die tcpsink u. danach ausgeben auf dem omyplayer)

# Sofern schon ein Aufnahmeprozess (=gstreamer Prozess laeuft), wird dieser gekillt
# Sofern schon eine Kameranzeige auf dem Raspiscreen lauft (=omxplayer Prozess), wird dieser gekillt

# ------------------------ Wichtige Konfigurationsvariablen --------------------------
# Den Namen des Mikrofon Devices über den folgenden Befehl auf der Linux Konsole feststellen und eintragen:
# pactl list | grep -A2 'Source #' | grep 'Name: ' | cut -d" " -f2
audiodevice="alsa_input.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-mono"
# Die IP-Adresse des Raspberrys ueber Eingabe von ifconfig auf der Linux Konsole feststellen und eintragen:
ipaddress="192.168.0.59" 
# Die Kirchengemeinde eintragen, zu der gestreamt werden soll
kirche="xy/test"
#Verzeichnis, in welches die mp4-Aufnahmen geschrieben werden sollen
mpath="/home/pi/camrk/videostreams"

# Prüfen, ob gst-launch läuft. Wenn JA -> killen, wenn Nein nix machen
x=$(pidof gst-launch-1.0)
echo "x= "$x
xx=${x:-0}
echo "xx= "$xx
if [ $xx -gt 1 ]
then
  echo "gst-launch-1.0 laeuft"
  echo $xx
  sudo kill $xx
  echo "Kamera nun gestoppt"
  else
  echo "gsp-launch-1.0 laeuft nicht"
fi

# Prüfen, ob omxplayer-Script startOMXPlayer.sh läuft. Wenn JA -> killen, wenn Nein -> starten
y=$(ps -ef | grep 'startOMXPlayer'  | grep -v grep | awk '{print $2}')
echo "y= "$y
yy=${y:-0}
echo "yx= "$yy
if [ $yy -gt 1 ]
then
  echo "omxplayer laeuft"
  echo $yy
  sudo kill $yy
  echo "alte Instanz des omxplayers gestoppt"
  else
  echo "omxplayer laeuft nicht"
  # Starten des OMXPlayers
  sleep 1
  #/home/pi/camrk/startOMXPlayer.sh &
fi

# Anschliessend Videostream starten inkl. Aufnahme und Anzeige des Bildes auf dem Display
# Ueber den Parameter "do-timestamp=true" und "buffer-time=20000" ggfs. die Verzoegerung von Ton und Bild ausgleichen 
sleep 1
echo "stream und lokale mp4 aufnahme werden gestartet, anzeige des kamerabildes"
/usr/bin/gst-launch-1.0 v4l2src ! "video/x-raw,width=1280,height=720,framerate=15/1" ! omxh264enc target-bitrate=1000000 control-rate=variable ! \
video/x-h264,profile=high ! h264parse ! tee name=t t. ! queue ! \
flvmux name=mux pulsesrc do-timestamp=true device="$audiodevice" buffer-time=20000 ! \
audioresample ! audio/x-raw,rate=48000 ! queue ! voaacenc bitrate=32000 ! queue ! mux. mux. ! \
rtmpsink location=\"rtmp://xy.de/$kirche live=1\" sync=false t. ! queue ! \
flvmux name=rux pulsesrc do-timestamp=true device="$audiodevice" buffer-time=20000 ! \
audioresample ! audio/x-raw,rate=48000 ! queue ! voaacenc bitrate=32000 ! queue ! rux. rux. ! \
filesink location=$mpath/$(date +%Y%m%d_%H%M%S).mp4 sync=false t. ! queue ! \
flvmux name=lux pulsesrc do-timestamp=true device="$audiodevice" buffer-time=20000 ! \
audioresample ! audio/x-raw,rate=48000 ! queue ! voaacenc bitrate=32000 ! queue ! lux. lux. ! \
tcpserversink host=$ipaddress port=5000 sync=false &

#Starten des omxplayers und Anzeige des tscpstreams
sleep 2
/home/pi/camrk/startOMXPlayer.sh &
