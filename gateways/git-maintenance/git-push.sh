#!/bin/bash

# Git Push Module
# Executd from the Gateways
# Adds the new changes to Git, commits them locally, and pushes them to the Git remote
# Usage: Run when new data or logs are available on the gateway, a few times per day, for instance.

########## HEADER ##########

module_name=git_push

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Read directories line-by-line into an array
readarray -t dir_array <<< "$git_push_directories"

for dir in "${dir_array[@]}"; do
    timestamp=$(date +"%a %Y-%m-%d %T %Z")
    echo "Processing: $dir"
    cd "$dir" || continue

    # Stage and commit any new changes
    git add .
    git commit -m "$timestamp" || true

    # Check for unpushed commits
    unpushed_commits=$(git log --reverse --format="%H" --branches --not --remotes)

    if [[ -n "$unpushed_commits" ]]; then
        echo "Found unpushed commit(s)."
        branch_name=$(git rev-parse --abbrev-ref HEAD)
        for commit in $unpushed_commits; do
            git push --no-verify origin "$commit:refs/heads/$branch_name" || {
                echo "Failed to push commit: $commit"
                continue
            }
        done
    fi
done

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
