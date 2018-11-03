#!/usr/bin/env python
# -*- coding: utf-8 -*-
import RPi.GPIO as GPIO
import os
import time,threading
import sys

# use the pin number as on the raspi board

GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)
PIN1=5   # Taste 1 Rot als Taster Input 
PIN2=33    # Taste 2 Grün als Taster Input

# Input Pins werden hier gesetzt, die oputputpins in LED Schalten
GPIO.setup(PIN1, GPIO.IN)
GPIO.setup(PIN2, GPIO.IN)

#Threads mit LEDs starten
# use the pin number as on the raspi board
GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)

# set pin  as output
POUT1=7  # LED am Taster 1 rot
POUT2=35   # LED am Taster 2 grün7

rot = 0
gru = 0

GPIO.setup(POUT1, GPIO.OUT)
GPIO.output(POUT1, False)
GPIO.setup(POUT2, GPIO.OUT)
GPIO.output(POUT2, False)

def switch_on_rot( pin ):
  global rot
  rot = not rot
  print "rot ist an : ",rot
  print "Rote Taste wurde gedrückt, jetzt umschalten"
  os.system("bash /home/pi/camrk/umschalter.sh")
  print "Rote Taste wurde gedrückt, es ist umgeschaltet"




def switch_on_gru( pin ):
  global gru
  print "gruen ist an : ", gru
  if gru == 0:  # Es lief ein kein Stream
                                  gru = 1     # Stream starten
                                  os.system("bash /home/pi/camrk/streamstart1.sh &")
                                  print 'Stream wurde gestartet'

  else:
                                 os.system("bash /home/pi/camrk/streamstop.sh")
                                 print 'Stream wurde gestoppt'
                                 gru = 0
  print "gruen ist an : ", gru
  GPIO.output(POUT2, gru)


GPIO.add_event_detect(PIN1, GPIO.FALLING, bouncetime=500)
GPIO.add_event_callback(PIN1, switch_on_rot)

GPIO.add_event_detect(PIN2, GPIO.FALLING, bouncetime=500)
GPIO.add_event_callback(PIN2, switch_on_gru)

#try:
gruenein=1
while True:
  time.sleep(0.5)
#  print "Bin in while von streamschalter1.py"
  if gru == 1: #blinken
    if gruenein == 1:
      GPIO.output(POUT2, gruenein)
      gruenein=0
    else:
      GPIO.output(POUT2, gruenein)
      gruenein=1
#except KeyboardInterupt:
#  GPIO.cleanup()
#  sys.exit()
