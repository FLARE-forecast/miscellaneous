#!/bin/bash

# LoRa Module
# This module sets up and configures the LoRa interface, applies traffic control, configures IP layer as NAT in "noevio" mode, and configures IP layer to route through the gateway it connects to in "pendant" mode.

# mode: evio (if the fitlet2 serves as an EdgeVPN (evio) switch)
# When fitlet2 gateway is connected to a LoRa radio but not a cell link (e.g. at the FCR Weir)
# It configures the LoRa tnc0 interface, applies traffic control, and configures IP layer to route through the gateway it connects to
# this assumes the evio docker container is already running
# docker run -d -v /home/$USER/.evio/config.json:/etc/opt/evio/config.json -v /var/log/evio/:/var/log/evio/ --restart always --privileged --name evio-node --network host edgevpnio/evio-node:latest

# mode: noevio (if the fitlet2 is not running as an EdgeVPN (evio) switch to the other node)
# When fitlet2 gateway is connected to a LoRa radio and a cell link (e.g. at the FCR Catwalk)

# mode: pendant
# When fitlet2 gateway is connected to a LoRa radio but not a cell link (e.g. at the FCR Weir)

# Usage: Run after reboot and periodically, every hour, for instance.

########## HEADER ##########

module_name=lora

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Bring lora interface down and up
/usr/bin/killall tncattach || true

sleep 5

case $lora_mode in
    "pendant")
        /usr/local/bin/tncattach /dev/$lora_serial_interface $lora_baud_rate -d -e -n -m $lora_mtu -i $lora_node_ip
        /usr/sbin/tc qdisc add dev $lora_lora_interface root tbf rate "$lora_rate"kbit burst "$lora_burst"kbit latency "$lora_latency"ms
        /usr/sbin/ip route delete default
        /usr/sbin/ip route add default via $lora_switch_ip
        ;;

    "noevio")
        /usr/local/bin/tncattach /dev/$lora_serial_interface $lora_baud_rate -d -e -n -m $lora_mtu -i $lora_node_ip
        /usr/sbin/tc qdisc add dev $lora_lora_interface root tbf rate "$lora_rate"kbit burst "$lora_burst"kbit latency "$lora_latency"ms
        echo 1 > /proc/sys/net/ipv4/ip_forward
        /sbin/iptables -t nat -A POSTROUTING -o $lora_switch_interface -j MASQUERADE
        /sbin/iptables -A FORWARD -i $lora_switch_interface -o $lora_lora_interface -m state --state RELATED,ESTABLISHED -j ACCEPT
        /sbin/iptables -A FORWARD -i $lora_lora_interface -o $lora_switch_interface -j ACCEPT
        ;;

    "evio")
        /usr/local/bin/tncattach /dev/$lora_serial_interface $lora_baud_rate -d -e -n -m $lora_mtu
        /usr/bin/docker exec -it evio-node ovs-vsctl add-port $lora_evio_interface $lora_lora_interface
        /usr/bin/docker exec -it evio-node ovs-vsctl set interface $lora_lora_interface ingress_policing_rate=$lora_ingress_policing_rate
        /usr/bin/docker exec -it evio-node ovs-vsctl set interface $lora_lora_interface ingress_policing_burst=$lora_ingress_policing_burst
        /usr/sbin/tc qdisc add dev $lora_lora_interface root tbf rate "$lora_rate"kbit burst "$lora_burst"kbit latency "$lora_latency"ms
        /usr/sbin/sysctl -w net.ipv4.ip_forward=1
        /usr/sbin/iptables -t nat -A POSTROUTING -s $lora_node_ip -j MASQUERADE
        ;;

    *)
        echo "Invalid mode: $lora_mode. Exiting."
        exit 1
        ;;
esac

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
