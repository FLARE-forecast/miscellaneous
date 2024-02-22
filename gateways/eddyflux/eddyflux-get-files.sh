#!/bin/bash

# EddyFlux Get Files Module
# This module downloads EddyFlux files to the gateway.
# Usage: Run periodically, every day, for instance.

# SSH Access Sample Command:
# ssh -o PubkeyAcceptedAlgorithms=+ssh-rsa -oHostKeyAlgorithms=+ssh-rsa,ssh-dss licor@10.10.1.4

# SCP File Transfer Sample Command:
# scp -o PubkeyAcceptedAlgorithms=+ssh-rsa -o HostKeyAlgorithms=+ssh-rsa,ssh-dss -r licor@10.10.1.4:data/summaries/* /data/fcre-eddyflux-data/

########## HEADER ##########

module_name=eddyflux_get_files

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

scp -o PubkeyAcceptedAlgorithms=+ssh-rsa -o HostKeyAlgorithms=+ssh-rsa,ssh-dss -r ${eddyflux_get_files_ssh_user}@${eddyflux_get_files_ssh_host}:${eddyflux_get_files_source_path} ${eddyflux_get_files_destination_path}

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
