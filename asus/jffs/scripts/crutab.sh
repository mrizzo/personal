#!/bin/sh

cru a "throttle" "0 22 * * 0-5 /jffs/scripts/enable_qos.sh 1"
cru a "unthrottle" "0 6 * * * /jffs/scripts/enable_qos.sh 0"
