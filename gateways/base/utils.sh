#!/bin/bash

set -e

########## LOAD CONFIGURATIONS ##########

config_file=/home/ubuntu/miscellaneous/gateways/config-files/config.yml

# General
export general_log_file=$(yq e '.general.log_file' $config_file)
export general_gateway_name=$(yq e '.general.gateway_name' $config_file)
export general_gateway_location=$(yq e '.general.gateway_location' $config_file) 
export general_gateway_power_mode=$(yq e '.general.gateway_power_mode' $config_file)
export general_data_dir=$(yq e '.general.data_dir' $config_file)
export general_apps_dir=$(yq e '.general.apps_dir' $config_file)
export general_datalogger_data_dir=$(yq e '.general.datalogger_data_dir' $config_file)
export general_git_repo=$(yq e '.general.git_repo' $config_file)
export general_git_data_branch=$(yq e '.general.git_data_branch' $config_file)
export general_git_logs_branch=$(yq e '.general.git_logs_branch' $config_file)
export general_module_toggler_log_file=$(yq e '.general.module_toggler_log_file' $config_file)

# Scheduler
export shutdown_scheduler_is_enabled=$(yq e '.shutdown_scheduler.is_enabled' $config_file)
export shutdown_scheduler_log_file=$(yq e '.shutdown_scheduler.log_file' $config_file)
export shutdown_scheduler_post_reboot_delay_minutes=$(yq e '.shutdown_scheduler.post_reboot_delay_minutes' $config_file)
export shutdown_scheduler_shutdown_time=$(yq e '.shutdown_scheduler.shutdown_time' $config_file)

# Startup Notifier
export startup_notifier_is_enabled=$(yq e '.startup_notifier.is_enabled' $config_file)
export startup_notifier_log_file=$(yq e '.startup_notifier.log_file' $config_file)
export startup_notifier_local_repo_dir=$(yq e '.startup_notifier.local_repo_dir' $config_file)
export startup_notifier_git_repo=$(yq e '.startup_notifier.git_repo' $config_file)
export startup_notifier_git_branch=$(yq e '.startup_notifier.git_branch' $config_file)

# Status Monitor  
export status_monitor_is_enabled=$(yq e '.status_monitor.is_enabled' $config_file)
export status_monitor_log_file=$(yq e '.status_monitor.log_file' $config_file)

# Git Push
export git_push_is_enabled=$(yq e '.git_push.is_enabled' $config_file)
export git_push_log_file=$(yq e '.git_push.log_file' $config_file)
export git_push_directories=$(yq e '.git_push.directories[]' $config_file)

# Git Garbage Collector
export git_garbage_collector_is_enabled=$(yq e '.git_garbage_collector.is_enabled' $config_file) 
export git_garbage_collector_log_file=$(yq e '.git_garbage_collector.log_file' $config_file)
export git_garbage_collector_directories=$(yq e '.git_garbage_collector.directories[]' $config_file)

# Health Checks IO
export health_checks_io_is_enabled=$(yq e '.health_checks_io.is_enabled' $config_file)
export health_checks_io_log_file=$(yq e '.health_checks_io.log_file' $config_file)
export health_checks_io_ping_url=$(yq e '.health_checks_io.ping_url' $config_file)
export health_checks_io_max_time=$(yq e '.health_checks_io.max_time' $config_file)
export health_checks_io_retry=$(yq e '.health_checks_io.retry' $config_file)

# Reverse SSH
export reverse_ssh_is_enabled=$(yq e '.reverse_ssh.is_enabled' $config_file)
export reverse_ssh_log_file=$(yq e '.reverse_ssh.log_file' $config_file)
export reverse_ssh_autossh_log_file=$(yq e '.reverse_ssh.autossh_log_file' $config_file)
export reverse_ssh_local_port=$(yq e '.reverse_ssh.local_port' $config_file)
export reverse_ssh_base_port=$(yq e '.reverse_ssh.base_port' $config_file)
export reverse_ssh_remote_port=$(yq e '.reverse_ssh.remote_port' $config_file)
export reverse_ssh_localhost=$(yq e '.reverse_ssh.localhost' $config_file) 
export reverse_ssh_server=$(yq e '.reverse_ssh.server' $config_file)
export reverse_ssh_user=$(yq e '.reverse_ssh.user' $config_file)
export reverse_ssh_ServerAliveInterval=$(yq e '.reverse_ssh.ServerAliveInterval' $config_file)
export reverse_ssh_ServerAliveCountMax=$(yq e '.reverse_ssh.ServerAliveCountMax' $config_file)

# Datalogger Mock Data Generator
export datalogger_mock_data_generator_is_enabled=$(yq e '.datalogger_mock_data_generator.is_enabled' $config_file)
export datalogger_mock_data_generator_log_file=$(yq e '.datalogger_mock_data_generator.log_file' $config_file)
export datalogger_mock_data_generator_data_file=$(yq e '.datalogger_mock_data_generator.data_file' $config_file)
export datalogger_mock_data_generator_interval=$(yq e '.datalogger_mock_data_generator.interval' $config_file)

# Network Interface Monitor
export network_interface_monitor_is_enabled=$(yq e '.network_interface_monitor.is_enabled' $config_file)
export network_interface_monitor_log_file=$(yq e '.network_interface_monitor.log_file' $config_file)
export network_interface_monitor_log_rotation_interval=$(yq e '.network_interface_monitor.log_rotation_interval' $config_file)
export network_interface_monitor_interfaces=$(yq e '.network_interface_monitor.interfaces[]' $config_file)

# LED Monitor
export led_monitor_is_enabled=$(yq e '.led_monitor.is_enabled' $config_file)
export led_monitor_log_file=$(yq e '.led_monitor.log_file' $config_file)

# LoRa Radio
export lora_radio_is_enabled=$(yq e '.lora_radio.is_enabled' $config_file)
export lora_radio_log_file=$(yq e '.lora_radio.log_file' $config_file)
export lora_radio_mode=$(yq e '.lora_radio.mode' $config_file)
export lora_radio_serial_interface=$(yq e '.lora_radio.serial_interface' $config_file)
export lora_radio_lora_interface=$(yq e '.lora_radio.lora_interface' $config_file)
export lora_radio_evio_interface=$(yq e '.lora_radio.evio_interface' $config_file)
export lora_radio_uplink_interface=$(yq e '.lora_radio.uplink_interface' $config_file)
export lora_radio_node_ip=$(yq e '.lora_radio.node_ip' $config_file)
export lora_radio_node_netmask=$(yq e '.lora_radio.node_netmask' $config_file)
export lora_radio_lora_gateway_ip=$(yq e '.lora_radio.lora_gateway_ip' $config_file)
export lora_radio_baud_rate=$(yq e '.lora_radio.baud_rate' $config_file)
export lora_radio_mtu=$(yq e '.lora_radio.mtu' $config_file)
export lora_radio_rate=$(yq e '.lora_radio.rate' $config_file)
export lora_radio_burst=$(yq e '.lora_radio.burst' $config_file)
export lora_radio_latency=$(yq e '.lora_radio.latency' $config_file)
export lora_radio_ingress_policing_rate=$(yq e '.lora_radio.ingress_policing_rate' $config_file)
export lora_radio_ingress_policing_burst=$(yq e '.lora_radio.ingress_policing_burst' $config_file)

# Nebula Overlay Network
export nebula_overlay_network_is_enabled=$(yq e '.nebula_overlay_network.is_enabled' $config_file)
export nebula_overlay_network_log_file=$(yq e '.nebula_overlay_network.log_file' $config_file)

# EddyFlux Get Files
export eddyflux_get_files_is_enabled=$(yq e '.eddyflux_get_files.is_enabled' $config_file)
export eddyflux_get_files_log_file=$(yq e '.eddyflux_get_files.log_file' $config_file)
export eddyflux_get_files_ssh_user=$(yq e '.eddyflux_get_files.ssh_user' $config_file)
export eddyflux_get_files_ssh_host=$(yq e '.eddyflux_get_files.ssh_host' $config_file)
export eddyflux_get_files_source_path=$(yq e '.eddyflux_get_files.source_path' $config_file)
export eddyflux_get_files_destination_path=$(yq e '.eddyflux_get_files.destination_path' $config_file)

########## DEFINE FUNCTIONS ##########

# Check if module is is_enabled
check_if_enabled() {
  module_is_enabled_var="${1}_is_enabled"

  if [ "${!module_is_enabled_var}" != "true" ]; then
    echo "Module $1 is not is_enabled. Exiting..." 
    exit 0
  fi
}

# Log message to file
log_to_file() {
  local module=$1
  local message=$2
  local log_file_var_name="${module}_log_file"
  local log_file="${!log_file_var_name}"  # This gets the value of a variable named $log_file_var_name
  
  # Prefix each line of the message with the timestamp
  echo "$message" | while IFS= read -r line; do
    echo "$(date +"%D %T %Z %z") | $line"
  done >> "$general_data_dir/$general_git_logs_branch/$log_file"
}

# Parse config value
get_config_value() {
  local module=$1
  local key=$2

  yq e ".$module.$key" $config_file
}
