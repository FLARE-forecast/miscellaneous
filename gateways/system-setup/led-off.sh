#!/bin/bash

# LED Off Module
# Executd from the Gateways
# Turns off both LED1 and LED2 on the gateways.
# Usage: Run after reboot.

set -ex

# Note: GPIO pins have been updated in the newer Linux kernel versions and the following code no longer works.
# Possible reason: GPIO kernel modules missing
# https://fit-pc.com/wiki/index.php?title=Application_note_-_fitlet2_controlling_front_LEDs&redirect=no
# $ ls /sys/class/gpio

# Turn off the LED1 on the gateways
echo 435 > /sys/class/gpio/export
echo 0 > /sys/class/gpio/gpio435/value

# Turn off the LED2 on the gateways
echo 437 > /sys/class/gpio/export
echo 0 > /sys/class/gpio/gpio437/value
