#!/bin/bash

# Network Interface Monitor Module
# Executd from the Gateways
# Monitors network activity on specific interface(s)
# Usage: Run when needed

########## HEADER ##########

module_name=network_interface_monitor

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Cleanup function to ensure tcpdump processes are killed
cleanup() {
  pkill -P $$ tcpdump
}

trap cleanup EXIT
trap "exit" SIGINT SIGTERM

while read -r line; do
  interface_name=$(echo "$line" | yq -r '.name')
  read -r log_line
  log_file_prefix=$(echo "$log_line" | yq -r '.log_file_prefix')
  log_file_prefix_path=$general_data_dir/$general_git_logs_branch/$log_file_prefix

  # Continuously monitor interface
  (
    while true; do
      while ! ip link show $interface_name up &>/dev/null; do
        sleep 5
      done

      echo "Starting tcpdump for $interface_name..."
      nohup sudo tcpdump -i $interface_name -G $network_interface_monitor_log_rotation_interval -w "$log_file_prefix_path"_%Y-%m-%d_%H:%M:%S.pcap > /dev/null 2>&1 &
      pid=$!

      while kill -0 $pid 2>/dev/null && ip link show $interface_name up &>/dev/null; do
        sleep 5
      done

      if kill -0 $pid 2>/dev/null; then
        echo "Stopping tcpdump for $interface_name..."
        sudo kill $pid
        wait $pid
      fi
    done
  ) &

done <<< "$network_interface_monitor_interfaces"

########## FOOTER ##########

# echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
