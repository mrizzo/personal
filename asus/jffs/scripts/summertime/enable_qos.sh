#!/bin/sh

ENABLE=${1}
MAC_ADDRESS=${2:-"1C:3B:F3:37:8A:D9"}
SPEED_LIMIT=${3:-1024}
if [ $ENABLE -gt 0 ]; then
	nvram set qos_bw_rulelist="1>$MAC_ADDRESS>$SPEED_LIMIT>$SPEED_LIMIT>0"
fi
nvram set qos_enable=${1}
service "restart_qos;restart_firewall"
