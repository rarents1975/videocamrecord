#!/bin/bash

# Dieses Script speichert die Kameraufnahme als mp4-Datei 
# und zeigt das Bild auch auf dem Raspi-Bildschirm an.

# Sofern schon ein Aufnahmeprozess (=gstreamer Prozess laeuft), wird dieser gekillt
# Sofern schon eine Kameranzeige auf dem Raspiscreen lauft (=omxplayer Prozess), wird dieser gekillt

# ------------------------ Wichtige Konfigurationsvariablen --------------------------
# Den Namen des Mikrofon Devices über den folgenden Befehl auf der Linux Konsole feststellen und eintragen:
# pactl list | grep -A2 'Source #' | grep 'Name: ' | cut -d" " -f2
audiodevice="alsa_input.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-mono"
# Die IP-Adresse des Raspberrys ueber Eingabe von ifconfig auf der Linux Konsole feststellen und eintragen:
ipaddress="192.168.0.59" 
#Verzeichnis, in welches die mp4-Aufnahmen geschrieben werden sollen
mpath="/home/pi/camrk/videostreams"

# Prüfen, of gst-launch-1.0 läuft. Wenn JA -> Prozess abschiessen -> wenn Nein, passiert nichts
f=0
x=0
echo "x= "$x
echo "f= "$f
f=$(pidof gst-launch-1.0)
echo "f= "$f
if [ -z "$f" ] 
then
f=-1
fi
echo "f= "$f
if [ $f -gt 0 ]
then
echo "gst-launch Prozess laeuft und wird jetzt gekillt"
sudo kill $f
#exit 1
else
echo "gst-launch Prozess laeuft nicht"
fi

# Prüfen, ob pulseaudio laeuft. Wenn JA -> Prozess abschiessen -> wenn Nein, passiert nichts
g=0
y=0
echo "y= "$y
echo "g= "$g
f=$(pidof pulseaudio)
echo "g= "$g
if [ -z "$g" ] 
then
g=-1
fi
echo "g= "$g
if [ $g -gt 0 ]
then
echo "pulseaudio Prozess laeuft und wird jetzt gekillt"
sudo kill $g
#exit 1
else
echo "pulseaudio Prozess laeuft nicht"
fi

# Prüfen, ob omxplayer-Script startOMXPlayer.sh läuft. Wenn JA -> killen, wenn Nein -> mit gstreamer als mp4 aufnehmen 
# und gleichzeitig in in die tcpsink streamen. Dann 
# mit dem omxplayer die inhalte der tcpsink auslesen und auf dem Bildschirm darstellen

# Prozess-ID des OMXPlayer Startscriptes feststellen: 
x=$(ps -ef | grep 'startOMXPlayer'  | grep -v grep | awk '{print $2}')
echo "x= "$x
if [ -z "$x" ] # Abfrage ob auf x nichts steht
then
x=-1
fi
echo "x= "$x
if [ $x -gt 0 ]
then
echo "Ein omxplayer Prozess laeuft schon und wird jetzt gekillt"
sudo kill $x
echo "omxplayer Prozess nun gekillt"
else
echo "omxplayer laeuft nicht"
fi

#Den OMXPLAYER starten
echo "Starte den omxplayer"
/home/pi/camrk/startOMXPlayer.sh &

echo "Starte gstreamer, nehme als mp4 auf und streame in die tcpsink"
#In die TCP Sync streamen was ueber den omxplayer ausgegeben werden soll
gst-launch-1.0 v4l2src  ! "video/x-raw,width=1280,height=720,framerate=15/1" ! omxh264enc target-bitrate=1000000 control-rate=variable ! \
video/x-h264,profile=high ! h264parse ! tee name=t t. ! queue ! \
flvmux name=rux pulsesrc do-timestamp=true device="$audiodevice" buffer-time=20000 ! \
audioresample ! audio/x-raw,rate=48000 ! queue ! voaacenc bitrate=32000 ! queue ! rux. rux. ! \
filesink location=$mpath/$(date +%Y%m%d_%H%M%S).mp4 sync=false t. ! queue ! \
flvmux name=mux pulsesrc do-timestamp=true device="$audiodevice" buffer-time=20000 ! \
audioresample ! audio/x-raw,rate=48000 ! queue ! voaacenc bitrate=32000 ! queue ! mux. mux. ! \
tcpserversink host=$ipaddress port=5000

#fi
