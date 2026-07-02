#!/bin/sh
# Graduated packet loss through the evening for the kids' phone, ramping the
# drop probability up toward bedtime and clearing it in the morning.
#
# Idempotent: deletes prior entries before re-adding, so running it again (or on
# every boot via services-start) won't stack duplicate cron jobs — unlike the
# QoS crutab.sh, which uses bare `cru a`.

MAC="1C:3B:F3:37:8A:D9"
PL="/jffs/scripts/packet_loss.sh"

for n in pl_15 pl_35 pl_60 pl_85 pl_off; do
    cru d "$n" 2>/dev/null
done

# Sun–Thu evenings (nights before school days). Adjust days/times to taste.
cru a "pl_15"  "0 22 * * 0-4 $PL 1 $MAC 0.15"   # 22:00  ~15% loss (barely noticeable)
cru a "pl_35"  "0 23 * * 0-4 $PL 1 $MAC 0.35"   # 23:00  ~35% (annoying)
cru a "pl_60"  "30 23 * * 0-4 $PL 1 $MAC 0.60"  # 23:30  ~60% (painful)
cru a "pl_85"  "0 0  * * *   $PL 1 $MAC 0.85"   # 00:00  ~85% (basically unusable)
cru a "pl_off" "0 6  * * *   $PL 0"             # 06:00  clear
