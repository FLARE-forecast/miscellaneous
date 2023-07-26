#!/bin/bash

# Network Interface Monitor Script
# Executed from the Gateways
# Runs tcpdump to monitor a network interface
# Usage: If required, run after reboot.

set -ex

config_file=/home/ubuntu/miscellaneous/gateways/config-files/config.yml

# Parse the config file using yq
general_gateway_name=$(yq e '.general.gateway_name' $config_file)
general_data_dir=$(yq e '.general.data_dir' $config_file)
general_git_logs_branch=$(yq e '.general.git_logs_branch' $config_file)
network_interface_monitor_enabled=$(yq e '.network_interface_monitor.enabled' $config_file)
network_interface_monitor_log_rotation_interval=$(yq e '.network_interface_monitor.log_rotation_interval' $config_file)

# Body of the script

# Check if the script is enabled
if [ "$network_interface_monitor_enabled" != "true" ]; then
  echo "The script is not enabled. Exiting ..."
  exit 0
fi

# Loop over each interface and log file configuration
interfaces=$(yq e '.network_interface_monitor.interfaces | keys | .[]' $config_file)

for interface in $interfaces; do
  interface_name=$(yq e ".network_interface_monitor.interfaces[\"$interface\"].name" $config_file)
  interface_log_file=$(yq e ".network_interface_monitor.interfaces[\"$interface\"].log_file" $config_file)
  interface_log_file_path="$general_data_dir/$general_git_logs_branch/$interface_log_file"

  sudo tcpdump -i $interface_name -G $network_interface_monitor_log_rotation_interval -w "$interface_log_file_path"_%Y-%m-%d_%H:%M:%S.pcap &
done

# Wait for all the background processes to complete before exiting the script 
wait
