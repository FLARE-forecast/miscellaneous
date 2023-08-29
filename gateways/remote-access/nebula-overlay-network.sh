#!/bin/bash

# Nebula Overlay Network Module
# This module manages the Nebula service by ensuring the service is restarted and logs are captured.
# Usage: Run after reboot and periodically, every hour, for instance.

########## HEADER ##########

module_name=nebula_overlay_network

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Killing any running instance of nebula
sudo /usr/bin/killall nebula || true
sleep 1

# Start nebula with configuration
sudo nohup /etc/nebula/nebula -config /etc/nebula/config.yaml &

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
