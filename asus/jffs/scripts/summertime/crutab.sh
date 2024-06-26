#!/bin/sh

cru a "throttle_250" "0 22 * * 0-4 /jffs/scripts/enable_qos.sh 1 '1C:3B:F3:37:8A:D9' $((1024*250))"
cru a "throttle_100" "0 23 * * 0-4 /jffs/scripts/enable_qos.sh 1 '1C:3B:F3:37:8A:D9' $((1024*100))"
cru a "throttle_50" "30 23 * * 0-4 /jffs/scripts/enable_qos.sh 1 '1C:3B:F3:37:8A:D9' $((1024*50))"
cru a "throttle-1" "0 0 * * * /jffs/scripts/enable_qos.sh 1 '1C:3B:F3:37:8A:D9' 1024"
cru a "unthrottle" "0 6 * * * /jffs/scripts/enable_qos.sh 0"
