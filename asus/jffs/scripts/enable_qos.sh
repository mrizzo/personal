#!/bin/sh

nvram set qos_bw_rulelist="1>1C:3B:F3:37:8A:D9>1024>1024>0"
nvram set qos_enable=${1}
service "restart_qos;restart_firewall"
