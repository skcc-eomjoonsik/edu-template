#!/bin/bash

## ENV
ABSOLUTE_PATH="$(cd $(dirname "$0") && pwd -P)"
. $ABSOLUTE_PATH/tomcat.env

START_LOG=${CATALINA_BASE}/logs/catalina.out.start
LOCAL_LOG=${CATALINA_BASE}/logs/localhost.`date +'%Y-%m-%d'`.log
LOCAL_LOG_BAK=${CATALINA_BASE}/logs/localhost.`date +'%Y-%m-%d.%H%M%S'`.log

## Check RUNNING / mv localhost log file
_check_pid()
{
    PID_CHK=`ps -fu ${TOMCAT_USER} | grep java | grep "D${SERVER_NAME}" | awk '{print $2}'`
    if [ "${PID_CHK}" != "" ]; then
        echo "Tomcat ${SERVER_NAME} appears to still be running with PID ${PID_CHK}. Start aborted."
        exit 1
    else
        if [ -f ${LOCAL_LOG} ]; then
            mv ${LOCAL_LOG} ${LOCAL_LOG_BAK}
            > /tmp/linecnt.${TOMCAT_USER}.${SERVER_NAME}.localhost
        fi
    fi
}

## make START_LOG
_make_start_log()
{
    \rm ${START_LOG} 2>/dev/null
    touch ${CATALINA_OUT}
    tail -0f ${CATALINA_OUT} > ${START_LOG} &
}

## Start Tomcat instance
_start_tomcat()
{
    # Delete Unpack WAR Dir
    DEPLOY_LIST=`find ${CATALINA_BASE}/conf/Catalina/localhost/ -type f -name "*.xml" -exec basename {} \; | cut -d"." -f1`
    
    for UNPACK_WAR_DIR in ${DEPLOY_LIST}
    do
        if [ -d ${CATALINA_BASE}/webapps/${UNPACK_WAR_DIR} ]; then
            \rm -rf ${CATALINA_BASE}/webapps/${UNPACK_WAR_DIR}
        fi
    done 
 
    # start tomcat
    echo "[`date +%Y%m%d.%H%M%S`] ${SERVER_NAME} - Start Tomcat Instance." | tee -a ${START_STOP_LOG}
    cd ${CATALINA_BASE}/shl
    ./tomcat.sh start &

    # Check running
    RUN_CHECK=0
    while [ ${RUN_CHECK} -ne 1 ] 
    do
        #RUN_CHECK=`grep "Server startup in" ${START_LOG} | wc -l`
        RUN_CHECK=`grep "\[main\] org.apache.catalina.startup.Catalina.start" ${START_LOG} | wc -l`
        sleep 3
    done

    # Check deploy
    DEP_CHECK=`grep "as unavailable" ${LOCAL_LOG} | wc -l`
    if [ ${DEP_CHECK} -gt 0 ]; then
        echo "[`date +%Y%m%d.%H%M%S`] ${SERVER_NAME} - [E] Marked Servlet as Unavailable. Stop Tomcat Instance." | tee -a ${START_STOP_LOG}
        cd ${CATALINA_BASE}/shl
        ./tomcat.sh stop 10 -force
        return 1
    else
        echo "[`date +%Y%m%d.%H%M%S`] ${SERVER_NAME} - Start Tomcat Instance and Deploy Check Complete." | tee -a ${START_STOP_LOG}
        return 0
    fi
}

# kill tail process
_kill_tail_proc()
{
    TAIL_PID=`ps -fu ${TOMCAT_USER} | grep "tail -0f ${CATALINA_OUT}" | grep -v grep | awk '{print $2}'`
    \kill -9 ${TAIL_PID}
}

main()
{
    FAIL_CNT=0
    while [ ${FAIL_CNT} -le ${RETRY_CNT} ]
    do
        _check_pid
        _make_start_log
        _start_tomcat
        RESULT=$?
        if [ "${RESULT}" == 0 ]; then
            _kill_tail_proc
            exit 0
        else
            _kill_tail_proc
            ((FAIL_CNT++))
        fi
    done

    exit 1
}

main
