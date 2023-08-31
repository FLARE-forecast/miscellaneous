#!/bin/bash

# Startup Notifier Module
# Executd from the Gateways
# Pushes the current system date and time to the default branch (main/master) of the Git repo as a notification of the gateway being awake
# Usage: Run after reboot.

########## HEADER ##########

module_name=startup_notifier

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

cd $general_apps_dir/$startup_notifier_local_repo_dir/$general_gateway_name
date > $general_gateway_name
timestamp=$(date +"%a %Y-%m-%d %T %Z")
git add $general_gateway_name
git commit -m "$timestamp"
git pull --rebase
for commit in $(git log --reverse --format="%H" --branches --not --remotes); do 
    git push --force origin $commit:refs/heads/$(git rev-parse --abbrev-ref HEAD) || continue
done

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
