#!/bin/sh

# Set Path
SNAPSHOT_DIR=/log_data/apache/dump
NETSTAT_SNAPSHOT_FILE="${SNAPSHOT_DIR}/netstat_$(hostname)_$(date +'%Y%m%d_%H%M%S').log"

# Create the snapshot directory
mkdir -p "${SNAPSHOT_DIR}"
 
# Logging Netstat Snapshot 25 times every 3 sec.
for i in $(seq 1 25)
do
    {
        echo "###################################################"
        echo "COUNT : $i"
        echo "DATE : $(date +'%Y%m%d_%H%M%S')"
        echo "###################################################"
        netstat -an
        echo
    } >> "${NETSTAT_SNAPSHOT_FILE}"

    echo "$i times done."
    sleep 3
done

echo "Check netstat snapshot file: ${NETSTAT_SNAPSHOT_FILE}"
