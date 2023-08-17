#!/bin/bash

# HealthChecks.io Ping Module
# Executd from the Gateways
# Pings HealthChecks.io periodically as a notification of the gateway being awake
# Usage: Run periodically, every minute, for instance.

########## HEADER ##########

module_name=health_checks_io

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

curl -fsS --max-time $health_checks_io_max_time --retry $health_checks_io_retry -o /dev/null $health_checks_io_ping_url

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
