#!/bin/bash

# Shutdown Scheduler Module
# Executd from the Gateways
# Shuts down the system according to the maintenance mode and power mode
# Usage: Run after reboot.

########## HEADER ##########

module_name=scheduler

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Check the maintenance mode
if [ "$general_gateway_maintenance_mode" = "true" ]; then
    echo "The system is in maintenance mode. Shutdown is not allowed."
else
    # Check the power mode and schedule the shutdown accordingly
    if [ "$general_gateway_power_mode" = "ac" ]; then
        echo "The system is in AC power mode. Scheduling shutdown at $scheduler_shutdown_time."
        # Schedule shutdown at the given time
        sudo shutdown -h "$scheduler_shutdown_time"
    elif [ "$general_gateway_power_mode" = "battery" ]; then
        echo "The system is in battery power mode. Scheduling shutdown in $scheduler_shutdown_delay_after_reboot minutes after reboot."
        # Schedule shutdown after the given delay
        sudo shutdown -h +$scheduler_shutdown_delay_after_reboot
    else
        echo "Unknown power mode: $general_gateway_power_mode"
        exit 1
    fi
fi

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
