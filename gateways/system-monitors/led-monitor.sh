#!/bin/bash

# LED Monitor Module
# Executd from the Gateways
# Turns off both LED1 and LED2 on the gateways
# Usage: Run after reboot.

set -ex

# Note: GPIO pins have been updated in the newer Linux kernel versions and the following code no longer works.
# Possible reason: GPIO kernel modules missing
# https://fit-pc.com/wiki/index.php?title=Application_note_-_fitlet2_controlling_front_LEDs&redirect=no
# $ ls /sys/class/gpio

[ ! -d "/sys/class/gpio/gpio435" ] && echo 435 > /sys/class/gpio/export
[ ! -d "/sys/class/gpio/gpio436" ] && echo 436 > /sys/class/gpio/export
[ ! -d "/sys/class/gpio/gpio437" ] && echo 437 > /sys/class/gpio/export
[ ! -d "/sys/class/gpio/gpio438" ] && echo 438 > /sys/class/gpio/export

led1_green=$(cat "/sys/class/gpio/gpio435/value")
led1_yellow=$(cat "/sys/class/gpio/gpio436/value")
led2_green=$(cat "/sys/class/gpio/gpio437/value")
led2_yellow=$(cat "/sys/class/gpio/gpio438/value")

led1=$(([ $led1_yellow == 1 ] && echo "yellow") || (([ $led1_green == 1 ] && echo "green") || echo "off" ))
led2=$(([ $led2_yellow == 1 ] && echo "yellow") || (([ $led2_green == 1 ] && echo "green") || echo "off" ))

if ping -c 1 8.8.8.8 &> /dev/null
then
  if ping -c 1 github.com &> /dev/null
  then
    if [ $led1 != "green" ]; then
      echo 0 > /sys/class/gpio/gpio436/value
      echo 1 > /sys/class/gpio/gpio435/value
    fi
  else
    if [ $led1 != "yellow" ]; then
      echo 0 > /sys/class/gpio/gpio435/value
      echo 1 > /sys/class/gpio/gpio436/value
    fi
  fi
else
  if [ $led1 != "off" ]; then
    echo 0 > /sys/class/gpio/gpio435/value
    echo 0 > /sys/class/gpio/gpio436/value
  fi
fi

if ping -c 1 10.10.1.2 &> /dev/null
then
  if ping -c 1 10.10.1.1 &> /dev/null
  then
    if [ $led2 != "green" ]; then
      echo 0 > /sys/class/gpio/gpio438/value
      echo 1 > /sys/class/gpio/gpio437/value
    fi
  else
    if [ $led2 != "yellow" ]; then
      echo 0 > /sys/class/gpio/gpio437/value
      echo 1 > /sys/class/gpio/gpio438/value
    fi
  fi
else
  if [ $led2 != "off" ]; then
    echo 0 > /sys/class/gpio/gpio437/value
    echo 0 > /sys/class/gpio/gpio438/value
  fi
fi
