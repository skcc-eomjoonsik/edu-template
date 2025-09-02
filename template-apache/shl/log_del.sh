#!/bin/bash

################################
# Apache
################################
SERVERS=""

GZP_PERIOD=7
DEL_PERIOD=180

for SERVER_NAME in ${SERVERS}
do
   # gzip apache log over ${GZP_PERIOD} days
   find /log_data/apache/${SERVER_NAME} -type f -name "*access.log.20*[0-9]" -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/apache/${SERVER_NAME} -type f -name "*error.log.20*[0-9]"  -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/apache/${SERVER_NAME} -type f -name "*mod_jk.log.20*[0-9]" -mtime +${GZP_PERIOD} -exec gzip -9 {} \;

   # del apache log over ${DEL_PERIOD} days
   find /log_data/apache/${SERVER_NAME} -type f -name "*access.log.20*.gz"   -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/apache/${SERVER_NAME} -type f -name "*error.log.20*.gz"    -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/apache/${SERVER_NAME} -type f -name "*mod_jk.log.20*.gz"   -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
done
