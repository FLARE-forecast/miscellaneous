#!/bin/bash

# Status Monitor Module
# Executd from the Gateways
# Logs the current status of the system by checking on various services
# Usage: Run at least once after reboot, a few times per day, for instance.

########## HEADER ##########

module_name=status_monitor

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

uptime
/usr/bin/last reboot | head -n 5
/usr/bin/lsusb
dmesg | grep enx || true
dmesg | tail
df -h
/sbin/ip a
tail /var/log/vsftpd.log || true
ping -c 3 github.com || true
ping -c 3 8.8.8.8 || true

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
