#!/bin/bash

# Git Garbage Collector Module
# Executd from the Gateways
# Runs Git Garbage Collector
# Usage: Run at least once every few weeks, recommended after running Git Push Module for quicker runs.

########## HEADER ##########

module_name=git_garbage_collector

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Read directories line-by-line into an array
readarray -t dir_array <<< "$git_garbage_collector_directories"

echo -e "Disk status before Git garbage collection:"
df -h | grep $general_data_dir

for dir in "${dir_array[@]}"; do
    cd $dir || continue
    echo -e "Processing: $(pwd)"
    git gc --prune || continue
    echo -e "Disk status after Git garbage collection:"
    df -h | grep $general_data_dir
done

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
