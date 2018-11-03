#!/usr/bin/env python
# -*- coding: utf-8 -*-
import RPi.GPIO as GPIO
import os
import time,threading
import sys
global Blink1
# use the pin number as on the raspi board
GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)
# set pin  as output and shut down LED
POUT1=7
Blink1=1
GPIO.setup(POUT1, GPIO.OUT)
GPIO.output(POUT1, False)
# Blinke Parameter setzen
Blink1=1
# ==0 -> LED1 ist aus,   ==1 -> blinkt,    ==2 -> dauerhaft ein
# Tread mit LED Blinken

def Blinke1():
            global Blink1
            while True:
                  if Blink1==1 or Blink1==0:
                    GPIO.output(POUT1, False)
                    time.sleep(.2)
                  if Blink1==1 or Blink1==2:
                    GPIO.output(POUT1, True)
                    time.sleep(.2)

th1=threading.Thread(target=Blinke1)
th1.start()


# Schleife um Internet zu pruefen und Blinken einzuschalten / auszuschalten
ip = "google.com"
while True:
      time.sleep(1)
#pruefen ob Internet läuft
      istein = os.system("ping -c 2 > /dev/null " + ip)
      if istein == 0:  # 0 bedeutet, der Ping zu google geht
       Blink1=2
      else:
       Blink1=1
