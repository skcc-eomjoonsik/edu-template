#!/bin/bash

################################
# Tomcat
################################
SERVERS=""

GZP_PERIOD=7
DEL_PERIOD=180

for SERVER_NAME in ${SERVERS}
do
   # gzip apache log over ${GZP_PERIOD} days
   find /log_data/tomcat/${SERVER_NAME} -type f -name "catalina.out-*[0-9]"       -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "catalina.*.log"            -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "localhost_access.*.log"    -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "localhost.*.log"           -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "manager.*.log"             -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "host-manager.*.log"        -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "gc_*.log"                  -mtime +${GZP_PERIOD} -exec gzip -9 {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "gc_*.log.0"                -mtime +${GZP_PERIOD} -exec gzip -9 {} \;

   # del apache log over ${DEL_PERIOD} days
   find /log_data/tomcat/${SERVER_NAME} -type f -name "catalina.out-*[0-9].gz"    -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "localhost_access.*.log.gz" -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "localhost.*.log.gz"        -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "catalina.*.log.gz"         -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "manager.*.log.gz"          -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "host-manager.*.log.gz"     -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "gc_*.log.gz"               -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
   find /log_data/tomcat/${SERVER_NAME} -type f -name "gc_*.log.0.gz"             -mtime +${DEL_PERIOD} -exec rm -rf  {} \;
done

#chmod log dir, files
find /log_data/tomcat -type d -exec chmod 750 {} \;
find /log_data/tomcat -type f -exec chmod 640 {} \;
