#!/bin/bash

# Gateway Initialization Module
# Executd from the Gateways
# Initializes the gateway environment
# Usage: Run once for the first time to initialize the gateway based on the configuration settings

########## HEADER ##########

module_name=initializer

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

##########  BODY  ##########

general_data_dir_path=$general_data_dir/$general_git_data_branch
general_logs_dir_path=$general_data_dir/$general_git_logs_branch

# Change hostname
echo "$general_gateway_name" | sudo tee /etc/hostname
sudo sed -i "s/old_hostname/$general_gateway_name/g" /etc/hosts
sudo hostname $general_gateway_name

# Initialize SSH connection and make sure autossh is not running with old configurations
ssh -p $reverse_ssh_remote_port $reverse_ssh_user@$reverse_ssh_server 'exit'
sudo pkill -f autossh

# Setup datalogger directory symbolic link
if [ ! -L $general_data_dir/$general_datalogger_data_dir ]; then
  echo "Creating datalogger directory symbolic link"
  ln -s $general_git_data_branch $general_data_dir/$general_datalogger_data_dir
else
  echo "Datalogger directory already exists. Recreating it ..."
  ln -sfn $general_git_data_branch $general_data_dir/$general_datalogger_data_dir
fi
git config --global --add safe.directory $general_data_dir/$general_git_data_branch
sudo chown -R ftpuser:ftpuser $general_data_dir/$general_datalogger_data_dir

# Clone the latest commit from the data branch if the directory does not exist
if [ ! -d "$general_data_dir_path" ]; then
  echo "Cloning data branch"
  git clone --depth 1 --branch $general_git_data_branch $general_git_repo $general_data_dir_path
else
  echo "Data directory already exists. Pulling the latest version ..."
  cd $general_data_dir_path
  git pull
fi
sudo chown -R ftpuser:ftpuser $general_data_dir/$general_git_data_branch
sudo chmod -R g+w $general_data_dir/$general_git_data_branch

# Clone the latest commit from the logs branch if the directory does not exist
if [ ! -d "$general_logs_dir_path" ]; then
  echo "Cloning logs branch"
  git clone --depth 1 --branch $general_git_logs_branch $general_git_repo $general_logs_dir_path
else
  echo "Logs directory already exists. Pulling the latest version ..."
  cd $general_logs_dir_path
  git pull
fi

# Clone the latest commit from the startup branch if the directory does not exist
if [ ! -d "$general_apps_dir/$startup_notifier_local_repo_dir/$general_gateway_name" ]; then
  echo "Cloning startup notifier branch"
  git clone --depth 1 --branch $startup_notifier_git_branch $startup_notifier_git_repo $general_apps_dir/$startup_notifier_local_repo_dir/$general_gateway_name
else
  echo "Startup notifier directory already exists. Pulling the latest version ..."
  cd $general_apps_dir/$startup_notifier_local_repo_dir/$general_gateway_name
  git pull
fi

# Create symbolic link for module toggler
if [ ! -f "/usr/local/bin/toggler" ]; then
  # Create symlink
  sudo ln -s "$general_apps_dir/gateways/base/module-toggler.sh" "/usr/local/bin/toggler" 
fi
