#!/bin/bash

# Dieses Script schaltet folgendes aus:
# - Livestream, Lokale Aufnahme und Anzeige des Kamerabildes auf dem Raspiscreen
# - Anzeige des Kamerabildes auf dem Raspiscreen

# Gstreamer Prozesse beenden:
x=99
x=$(pidof gst-launch-1.0)
echo $x
sudo kill $x

# omxplayer Prozesse beenden
y=99
y=$(ps -ef | grep 'startOMXPlayer'  | grep -v grep | awk '{print $2}')
echo "y= "$y
sudo kill $y

# pulseaudio Prozesse beenden
z=99
z=$(pidof pulseaudio)
echo $z
sudo kill $z
