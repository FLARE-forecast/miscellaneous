#!/bin/bash

# Module Toggler
# Executd from the Gateways
# Report and update status of modules
# Usage: Run when needed
########## HEADER ##########

module_name=general # status_update is a part of general

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Set up some colors for user-friendly display
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to get all modules without the "general" module
get_filtered_modules() {
    local modules=($(yq eval 'keys | .[]' $config_file))
    local filtered_modules=()
    for module in "${modules[@]}"; do
        if [ "$module" != "general" ]; then
            filtered_modules+=("$module")
        fi
    done
    echo "${filtered_modules[@]}"
}

# Using the above function to get the filtered list
filtered_modules=($(get_filtered_modules))

# Function to display modules and their status
display_modules_status() {
    echo "FLARE gateway modules and their current status:"
    max_index_length=${#filtered_modules[@]}
    for idx in "${!filtered_modules[@]}"; do
        formatted_idx=$(printf "%${max_index_length}s" "$((idx+1))")
        status=$(yq e ".${filtered_modules[$idx]}.is_enabled" $config_file)
        status_text_colored=$( [ "$status" == "true" ] && echo "${GREEN}[+] enabled${NC}" || echo "${RED}[-] disabled${NC}" )
        echo -e "$formatted_idx. ${filtered_modules[$idx]}: $status_text_colored"
    done
}

# Function to toggle the status of a module
toggle_module_status() {
    local opt_idx="$1"
    local opt="${filtered_modules[$opt_idx]}"
    local current_status
    current_status=$(get_config_value "$opt" "is_enabled")
    if [ "$current_status" == "true" ]; then
        yq eval ".${opt}.is_enabled = false" -i $config_file
        echo
        echo "${opt} disabled."
        # Check if the module being disabled is shutdown_scheduler
        if [ "$opt" == "shutdown_scheduler" ]; then
            sudo shutdown -c # Cancel shutdown
        fi
    else
        yq eval ".${opt}.is_enabled = true" -i $config_file
        echo
        echo "${opt} enabled."
    fi
}

# Display modules and their status
echo
display_modules_status
echo

# Get user selection
echo -e "Choose one or more modules separated by space (e.g., 1 3 6) to toggle their status (enable/disable), or type 'q' to exit without making any changes:"
read -a selections

for selected in "${selections[@]}"; do
    # Exit if user chooses the exit option
    if [ "$selected" == "q" ]; then
        echo
        echo "Exiting without changes."
    # Validate user input
    elif [ "$selected" -lt 1 ] || [ "$selected" -gt "${#filtered_modules[@]}" ]; then
        echo
        echo "Invalid selection: $selected. Exiting without changes."
    else
        idx=$((selected-1))
        toggle_module_status "$idx"
    fi
done

# After toggling the status, display and log the final status
echo
display_modules_status 2>&1 | tee $general_data_dir/$general_git_logs_branch/$general_module_toggler_log_file
echo

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
