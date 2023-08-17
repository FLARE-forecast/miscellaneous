#!/bin/bash

# Datalogger Mock Data Generator Module
# Executd from the Gateways
# Generates random data mocking the output of dataloggers for test and development purposes
# Usage: Run periodically, every 10 minutes, for instance.

########## HEADER ##########

module_name=datalogger_mock_data_generator

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

datalogger_mock_data_generator_data_file_path=$general_data_dir/$general_git_data_branch/$datalogger_mock_data_generator_data_file

echo -e "\n############################ $general_gateway_name - $timestamp ############################\n" 2>&1 | tee -a "$datalogger_mock_data_generator_log_file_path"

# Function to generate random values
generate_random_value() {
  local min="$1"
  local max="$2"

  if ! [[ "$min" =~ ^[0-9]+(\.[0-9]+)?$ ]] || ! [[ "$max" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    log_to_file "$module_name" "Error: Minimum and maximum values must be numeric."
    return 1
  fi

  if (( $(awk "BEGIN { print $min > $max }") )); then
    log_to_file "$module_name" "Error: Minimum value cannot be larger than maximum value."
    return 1
  fi

  local scaled_min=$(awk "BEGIN { print int($min * 1000000) }")
  local scaled_max=$(awk "BEGIN { print int($max * 1000000) }")
  local random_scaled=$(shuf -i "$scaled_min-$scaled_max" -n 1)
  local random_float=$(awk "BEGIN { printf \"%.6f\", $random_scaled / 1000000 }")
  echo "$random_float"
}

# Check if the file is empty
if [ ! -s "$datalogger_mock_data_generator_data_file_path" ]; then
  # Print CSV header
  echo "TIMESTAMP,RECORD,BattV,PTemp_C,PAR_Den_Avg,PAR_Tot_Tot,BP_kPa_Avg,AirTC_Avg,RH,Rain_mm_Tot,WS_ms_Avg,WindDir,SR01Up_Avg,SR01Dn_Avg,IR01UpCo_Avg,IR01DnCo_Avg,NR01TK_Avg,Albedo_Avg" > "$datalogger_mock_data_generator_data_file_path"

  # Set record number to 1
  record=1

  # Set current timestamp
  current_timestamp=$(date +'%Y-%m-%d %H:%M:00')

  # Print initial row to CSV
  echo "\"$current_timestamp\",$record,$(generate_random_value 12.0 12.5),$(generate_random_value 12.0 13.0),$(generate_random_value 0.1 1.0),$(generate_random_value 0.01 0.1),$(generate_random_value 100.0 105.0),$(generate_random_value 10.0 15.0),$(generate_random_value 50 70),$(generate_random_value 0.0 5.0),$(generate_random_value 1.0 5.0),$(generate_random_value 0 360),$(generate_random_value 200.0 500.0),$(generate_random_value 200.0 500.0),$(generate_random_value 200.0 500.0),$(generate_random_value 200.0 500.0),$(generate_random_value 280.0 300.0),$(generate_random_value 0.0 0.5)" >> "$datalogger_mock_data_generator_data_file_path"
else
  # Get the last recorded record number from the CSV file
  last_record_number=$(tail -n 1 "$datalogger_mock_data_generator_data_file_path" | cut -d',' -f2 | sed 's/"//g')

  # Set record number for missed intervals
  record=$((last_record_number + 1))
fi

# Get the last recorded timestamp from the CSV file
last_timestamp=$(tail -n 1 "$datalogger_mock_data_generator_data_file_path" | cut -d',' -f1 | sed 's/"//g')

# Calculate the current timestamp
current_timestamp=$(date +'%Y-%m-%d %H:%M:00')

# Calculate the number of missed 10 minute intervals
missed_intervals=$(( ($(date -d "$current_timestamp" +%s) - $(date -d "$last_timestamp" +%s)) / (60 * "$datalogger_mock_data_generator_interval") ))

# Generate missed data for each interval
for ((i=1; i<=missed_intervals; i++)); do
  # Calculate the timestamp for the missed interval
  missed_timestamp=$(date -d@"$(( $(date -d "$last_timestamp" +%s) + (i * (60 * "$datalogger_mock_data_generator_interval")) ))" +'%Y-%m-%d %H:%M:00')

  # Generate random values for each field
  battv=$(generate_random_value 12.0 12.5)
  ptemp_c=$(generate_random_value 12.0 13.0)
  par_den_avg=$(generate_random_value 0.1 1.0)
  par_tot_tot=$(generate_random_value 0.01 0.1)
  bp_kpa_avg=$(generate_random_value 100.0 105.0)
  airtc_avg=$(generate_random_value 10.0 15.0)
  rh=$(generate_random_value 50 70)
  rain_mm_tot=$(generate_random_value 0.0 5.0)
  ws_ms_avg=$(generate_random_value 1.0 5.0)
  wind_dir=$(generate_random_value 0 360)
  sr01up_avg=$(generate_random_value 200.0 500.0)
  sr01dn_avg=$(generate_random_value 200.0 500.0)
  ir01upco_avg=$(generate_random_value 200.0 500.0)
  ir01dnco_avg=$(generate_random_value 200.0 500.0)
  nr01tk_avg=$(generate_random_value 280.0 300.0)
  albedo_avg=$(generate_random_value 0.0 0.5)

  # Print the row to CSV
  echo "\"$missed_timestamp\",$record,$battv,$ptemp_c,$par_den_avg,$par_tot_tot,$bp_kpa_avg,$airtc_avg,$rh,$rain_mm_tot,$ws_ms_avg,$wind_dir,$sr01up_avg,$sr01dn_avg,$ir01upco_avg,$ir01dnco_avg,$nr01tk_avg,$albedo_avg" >> "$datalogger_mock_data_generator_data_file_path"

  # Increment the record number
  record=$((record + 1))
done

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
