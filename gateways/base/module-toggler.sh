#!/bin/bash

# Network Interface Monitor Module
# Executd from the Gateways
# Monitors network activity on specific interface(s)
# Usage: Run when needed

########## HEADER ##########

module_name=general # status_update is a part of general

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Function to display modules and their status
display_modules_status() {
    echo "Modules and their current status:"
    modules=($(yq eval 'keys | .[]' $config_file))
    for idx in "${!modules[@]}"; do
        if [ "${modules[$idx]}" == "general" ]; then
            status=$(yq e ".general.gateway_maintenance_mode" $config_file)
            echo "$((idx+1)). ${modules[$idx]} (maintenance_mode): $status"
        else
            status=$(yq e ".${modules[$idx]}.enabled" $config_file)
            echo "$((idx+1)). ${modules[$idx]}: $status"
        fi
    done
}

# Function to toggle the status of a module
toggle_module_status() {
    local opt="$1"
    local current_status

    if [ "$opt" == "general" ]; then
        current_status=$(get_config_value "general" "gateway_maintenance_mode")
        if [ "$current_status" == "true" ]; then
            yq eval ".${opt}.gateway_maintenance_mode = false" -i $config_file
            echo "Set ${opt}'s gateway_maintenance_mode to false."
        else
            yq eval ".${opt}.gateway_maintenance_mode = true" -i $config_file
            echo "Set ${opt}'s gateway_maintenance_mode to true."
        fi
    else
        current_status=$(get_config_value "$opt" "enabled")
        if [ "$current_status" == "true" ]; then
            yq eval ".${opt}.enabled = false" -i $config_file
            echo "Set ${opt} to false."
        else
            yq eval ".${opt}.enabled = true" -i $config_file
            echo "Set ${opt} to true."
        fi
    fi
}

# Display modules and their status
display_modules_status

# Get user selection
echo "Select modules to toggle its status (e.g., 1 3 6) or enter 'q' to exit without changes:"
read -a selections

for selected in "${selections[@]}"; do
    # Exit if user chooses the exit option
    if [ "$selected" == "q" ]; then
        echo "Exiting without changes."
    
    # Validate user input
    elif [ "$selected" -lt 1 ] || [ "$selected" -gt "${#modules[@]}" ]; then
        echo "Invalid selection: $selected. Exiting without changes."
    
    else
        idx=$((selected-1))
        toggle_module_status "${modules[$idx]}"
    fi
done

# After toggling the status, display and log the final status
echo "Final Status:"
display_modules_status 2>&1 | tee $general_data_dir/$general_git_logs_branch/$general_module_toggler_log_file

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
