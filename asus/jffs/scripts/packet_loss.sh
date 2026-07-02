#!/bin/sh
# packet_loss.sh — introduce random packet loss for a single LAN device.
#
# Why not just a bandwidth cap? A hard cap reads as "the wifi is throttled,
# switch to cellular." Random drops feel like a flaky connection instead, so it
# degrades things without an obvious cause to route around.
#
# Usage:
#   packet_loss.sh <enable 1|0> [MAC] [PROBABILITY 0.0-1.0] [IP]
# Examples:
#   packet_loss.sh 1 1C:3B:F3:37:8A:D9 0.30   # drop ~30% of that device's packets
#   packet_loss.sh 0                           # turn it off
#
# NOTE: a firewall restart flushes these rules (and `enable_qos.sh` calls
# `service restart_firewall`). Re-apply from /jffs/scripts/firewall-start if you
# want it to survive restarts — see the notes at the bottom.

ENABLE=${1:-0}
MAC=${2:-"1C:3B:F3:37:8A:D9"}
PROB=${3:-0.30}
IP=${4:-""}
CHAIN="KIDLOSS"
# Persisted so firewall-start can restore the current level after a firewall
# flush / reboot. Lives on /jffs so it survives reboots.
STATE_FILE="/jffs/scripts/.packet_loss.state"

# Auto-detect the device IP from DHCP leases if not supplied. Needed to also
# drop inbound (download) packets, which arrive with the ISP gateway's MAC, not
# the device's — so MAC matching alone only catches outbound traffic.
if [ -z "$IP" ]; then
    IP=$(grep -i "$MAC" /var/lib/misc/dnsmasq.leases 2>/dev/null | awk '{print $3}' | head -n1)
fi

# Tear down any existing setup first, so re-running is safe (idempotent).
while iptables -D FORWARD -j "$CHAIN" 2>/dev/null; do :; done
iptables -F "$CHAIN" 2>/dev/null
iptables -X "$CHAIN" 2>/dev/null

if [ "$ENABLE" -gt 0 ]; then
    iptables -N "$CHAIN"

    # Outbound: packets FROM the device (match by source MAC).
    iptables -A "$CHAIN" -m mac --mac-source "$MAC" \
        -m statistic --mode random --probability "$PROB" -j DROP

    # Inbound: packets TO the device (match by dest IP).
    if [ -n "$IP" ]; then
        iptables -A "$CHAIN" -d "$IP" \
            -m statistic --mode random --probability "$PROB" -j DROP
    fi

    # Route forwarded traffic through the chain; non-matching packets RETURN.
    iptables -I FORWARD -j "$CHAIN"

    # DROP (not REJECT) on purpose: silent loss looks like a weak signal,
    # whereas REJECT sends ICMP that apps can detect.

    # Record the current level (MAC + probability) so firewall-start can restore
    # it after the firewall flushes our chain. IP is re-detected on restore, so
    # it stays correct even if the DHCP lease changed.
    echo "$MAC $PROB" > "$STATE_FILE"

    echo "packet loss ON: $MAC${IP:+ / $IP} @ probability $PROB"
else
    rm -f "$STATE_FILE"
    echo "packet loss OFF"
fi
