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

########## FUNCTIONS ##########

process_git_directory() {
    local target_dir="$1"
    local timestamp=$(date +"%a %Y-%m-%d %T %Z")
    echo "Processing: $target_dir"
    cd "$target_dir" || return 1

    local failed_on_push=0

    git add .
    git commit -m "$timestamp" || true

    # Check for unpushed commits
    unpushed_commits=$(git log --reverse --format="%H" --branches --not --remotes)

    if [[ -n "$unpushed_commits" ]]; then
        echo "Found unpushed commit(s)."
        branch_name=$(git rev-parse --abbrev-ref HEAD)
        for commit in $unpushed_commits; do
            if  GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git push --no-verify origin "$commit:refs/heads/$branch_name"; then
                echo "Successfully pushed: $commit"
            else
                echo "Failed to push: $commit"
                failed_on_push=1
                break
            fi
        done
    fi

    return $failed_on_push

}

##########  BODY  ##########

# Read directories line-by-line into an array
readarray -t dir_array <<< "$git_push_directories"

ssh-keygen -R $lora_radio_lora_gateway_ip

for dir in "${dir_array[@]}"; do
    # copy files to experiment directory
    dir="${dir%/}"  # Normalize path
    dir_basename="${dir##*/}"
    exp_dir="/data/exp-${dir_basename}"  # Ensure correct absolute path
    rsync -a --delete --exclude='.git' "$dir/" "$exp_dir/"

    # Stage and commit any new changes
    echo "========Primary directory========"
    if ! process_git_directory "$dir"; then
        echo "Primary directory $dir failed but continuing with experimental directory."
    fi
    echo "========Primary directory end========"
    # push the experiment dir
    echo "========Experiemental directory========"
    if ! process_git_directory "$exp_dir"; then
        echo "Experimental directory $exp_dir failed."
    fi
    echo "========Experiemental directory end========"

done

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
