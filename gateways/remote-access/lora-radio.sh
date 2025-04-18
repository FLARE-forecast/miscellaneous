#!/bin/bash

# LoRa Radio Module
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

module_name=lora_radio

# Load utility functions and configurations for gateways
source /home/ubuntu/miscellaneous/gateways/base/utils.sh

# Check if the module is enabled
check_if_enabled "$module_name"

# Redirect all output of this module to log_to_file function
exec > >(while IFS= read -r line; do log_to_file "$module_name" "$line"; echo "$line"; done) 2>&1

echo "########## START ##########"

##########  BODY  ##########

# Bring lora interface down and up
sudo /usr/bin/killall tncattach || true
sleep 1

case $lora_radio_mode in
    "pendant")
        sudo /usr/local/bin/tncattach /dev/$lora_radio_serial_interface $lora_radio_baud_rate -d -e -n -m $lora_radio_mtu -i "$lora_radio_node_ip""$lora_radio_node_netmask"
        sudo /usr/sbin/tc qdisc add dev $lora_radio_lora_interface root tbf rate "$lora_radio_rate"kbit burst "$lora_radio_burst"kbit latency "$lora_radio_latency"ms
        if ip route | grep -q default; then
            sudo /usr/sbin/ip route delete default
        fi
        sudo /usr/sbin/ip route add default via $lora_radio_lora_gateway_ip
        ;;

    "noevio")
        sudo /usr/local/bin/tncattach /dev/$lora_radio_serial_interface $lora_radio_baud_rate -d -e -n -m $lora_radio_mtu -i "$lora_radio_node_ip""$lora_radio_node_netmask"
        sudo /usr/sbin/tc qdisc add dev $lora_radio_lora_interface root tbf rate "$lora_radio_rate"kbit burst "$lora_radio_burst"kbit latency "$lora_radio_latency"ms
        ;;

    "noevio-nat")
        sudo /usr/local/bin/tncattach /dev/$lora_radio_serial_interface $lora_radio_baud_rate -d -e -n -m $lora_radio_mtu -i "$lora_radio_node_ip""$lora_radio_node_netmask"
        sudo /usr/sbin/tc qdisc add dev $lora_radio_lora_interface root tbf rate "$lora_radio_rate"kbit burst "$lora_radio_burst"kbit latency "$lora_radio_latency"ms

        # Enable IP forwarding
        echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

        # Clean old broad NAT rule (if exists)
        sudo iptables -t nat -D POSTROUTING -o $lora_radio_uplink_interface -j MASQUERADE || true

        # Add NAT rule: only NAT traffic from subnet
        sudo iptables -t nat -C POSTROUTING -s $lora_radio_subnet -o $lora_radio_uplink_interface -j MASQUERADE || \
        sudo iptables -t nat -A POSTROUTING -s $lora_radio_subnet -o $lora_radio_uplink_interface -j MASQUERADE

        # Accept only reply traffic from lora_radio_uplink_interface → lora_radio_lora_interface
        sudo iptables -C FORWARD -i $lora_radio_uplink_interface -o $lora_radio_lora_interface -m state --state ESTABLISHED,RELATED -j ACCEPT || \
        sudo iptables -A FORWARD -i $lora_radio_uplink_interface -o $lora_radio_lora_interface -m state --state ESTABLISHED,RELATED -j ACCEPT

        # Drop unsolicited traffic from lora_radio_uplink_interface → lora_radio_lora_interface
        sudo iptables -C FORWARD -i $lora_radio_uplink_interface -o $lora_radio_lora_interface -j DROP || \
        sudo iptables -A FORWARD -i $lora_radio_uplink_interface -o $lora_radio_lora_interface -j DROP
        ;;

    "evio")
        sudo /usr/local/bin/tncattach /dev/$lora_radio_serial_interface $lora_radio_baud_rate -d -e -n -m $lora_radio_mtu
        sudo /usr/bin/docker exec -it evio-node ovs-vsctl add-port $lora_radio_evio_interface $lora_radio_lora_interface
        sudo /usr/bin/docker exec -it evio-node ovs-vsctl set interface $lora_radio_lora_radio_interface ingress_policing_rate=$lora_radio_ingress_policing_rate
        sudo /usr/bin/docker exec -it evio-node ovs-vsctl set interface $lora_radio_lora_interface ingress_policing_burst=$lora_radio_ingress_policing_burst
        sudo /usr/sbin/tc qdisc add dev $lora_radio_lora_interface root tbf rate "$lora_radio_rate"kbit burst "$lora_radio_burst"kbit latency "$lora_radio_latency"ms
        sudo /usr/sbin/sysctl -w net.ipv4.ip_forward=1
        sudo /usr/sbin/iptables -t nat -A POSTROUTING -s $lora_radio_node_ip -j MASQUERADE
        ;;

    *)
        echo "Invalid mode: $lora_radio_mode. Exiting."
        exit 1
        ;;
esac

# Print rules for verification
echo "=== Current iptables NAT Rules ==="
sudo /usr/sbin/iptables -t nat -L -v -n

echo "=== Current iptables FORWARD Rules ==="
sudo /usr/sbin/iptables -L FORWARD -v -n

########## FOOTER ##########

echo "##########  END  ##########"

# Close stdout and stderr
exec >&- 2>&-
# Wait for all background processes to complete
wait
