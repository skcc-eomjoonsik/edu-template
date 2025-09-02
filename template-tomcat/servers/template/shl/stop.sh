#!/bin/bash

## ENV
ABSOLUTE_PATH="$(cd $(dirname "$0") && pwd -P)"
. $ABSOLUTE_PATH/tomcat.env

if [ -f ${CATALINA_PID} ]; then
    if [ -s "${CATALINA_PID}" ]; then
        kill -0 `cat "${CATALINA_PID}"` >/dev/null 2>&1
        if [ $? -gt 0 ]; then
            echo "PID file found but either no matching process was found or the current user does not have permission to stop the process. Stop aborted."
            exit 1
        else
            echo "[`date +%Y%m%d.%H%M%S`] ${SERVER_NAME} - Stop Tomcat Instance." | tee -a ${START_STOP_LOG}
            cd ${CATALINA_BASE}/shl
            ./tomcat.sh stop 10 -force
            exit 0
        fi
    else
        echo "PID file is empty and has been ignored."
    fi
else
    echo "\$CATALINA_PID was set but the specified file does not exist. Is Tomcat running? Stop aborted."
    exit 1
fi
