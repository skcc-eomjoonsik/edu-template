#!/bin/bash

### crontab example ###########################################
# * * * * * /software/tomcat/shl/auto_restart.sh 1>/dev/null 2>&1
###############################################################

. ~/.bash_profile
DATE=`date +%Y%m%d.%H%M%S`
SMS_LOG=/tmp/mw.log

SERVERS=""

# print msg & write to ${SMS_LOG}
print_msg()
{
    printf "[%s - %s] %-20s : %-10s - %-10s %-10s %-10s %-10s %-10s\n" $1 $2 $3 $4 $5 $6 $7 $8 $9 | sed -e 's/ *$/ /g' >> ${SMS_LOG}
}

# tomcat downtime check.
TOMCAT_DOWNTIME_CHECK()
{
    CON_NAME=$1
    CON_DOWNTIME_FILE=/tmp/tomcat.downtime.check.${CON_NAME}
    touch ${CON_DOWNTIME_FILE}

    CON_DOWNTIME=`cat ${CON_DOWNTIME_FILE}`
    if [ "${CON_DOWNTIME}" == "" ]; then
        echo 0 > ${CON_DOWNTIME_FILE}
    else
        if [ -f /software/tomcat/servers/${CON_NAME}/catalina.pid ]; then
            if [ -s /software/tomcat/servers/${CON_NAME}/catalina.pid ]; then
                kill -0 `cat /software/tomcat/servers/${CON_NAME}/catalina.pid` >/dev/null 2>&1
                if [ $? -gt 0 ]; then
                    CON_DOWNTIME=`expr ${CON_DOWNTIME} + 1`
                    if [ ${CON_DOWNTIME} -gt 9 ]; then
                        print_msg ${DATE} ${USER} ${FUNCNAME[0]} "NOT.OK" "[${CON_NAME}_downed_over_10min.]"
                    else
                        echo ${CON_DOWNTIME} > ${CON_DOWNTIME_FILE}
                    fi
                else
                    echo 0 > ${CON_DOWNTIME_FILE}
                fi
            #else
            #    echo "PID file is empty and has been ignored."
            fi
        else
            CON_DOWNTIME=`expr ${CON_DOWNTIME} + 1`
            if [ ${CON_DOWNTIME} -gt 9 ]; then
                print_msg ${DATE} ${USER} ${FUNCNAME[0]} "NOT.OK" "[${CON_NAME}_downed_over_10min.]"
            else
                echo ${CON_DOWNTIME} > ${CON_DOWNTIME_FILE}
            fi
        fi
    fi
}

# auto_restart.sh duplicate execution check.
PS_INFO=/tmp/auto_restart.sh.ps_info.${RANDOM}
ps -ef | grep "auto_restart.sh" > ${PS_INFO}
PROCESS_CHK=`cat ${PS_INFO} | egrep -vw "grep|vi|/bin/sh -c" | wc -l`

# auto restart
if [ ${PROCESS_CHK} -eq 1 ]; then
    for CON in ${SERVERS}
    do

        TOMCAT_DOWNTIME_CHECK ${CON}

        LOG_DIR=/log_data/auto_restart
        RESTART_SEED=${LOG_DIR}/${CON}/seed
        LOG_FILE=${LOG_DIR}/${CON}_restart.log
        LOCK_SEED=${LOG_DIR}/${CON}_restart.lck
        LOCKCHK=`ls -al ${LOCK_SEED}     2> /dev/null | wc -l`
        FILECHK=`ls -al ${RESTART_SEED}  2> /dev/null | wc -l`

        if [ ${FILECHK} -eq 1 ] && [ ${LOCKCHK} -eq 0 ] ; then
            echo "" > ${LOG_FILE}
            mv ${RESTART_SEED} ${LOCK_SEED}

            echo "[`date +%Y%m%d.%H%M%S`] ${CON} - Seed File is Resolved and Restart Tomcat Instance." | tee -a ${LOG_FILE}

            # if web_mon_cron.sh crontab is setting, then change SMS_LOG=/tmp/mw.log to SMS_LOG=/tmp/mw_work.log
            CHK_WEB_MON=`crontab -l | grep "^[0-9*]" | grep web_mon_cron.sh | wc -l`
            if [ ${CHK_WEB_MON} -gt 0 ]; then
                /software/tomcat/shl/stopsms.sh; sleep 1;
            fi

            /software/tomcat/servers/${CON}/shl/stop.sh; sleep 3;

            /software/tomcat/servers/${CON}/shl/start.sh
            START_RST=$?
            if [ ${START_RST} -ne 0 ]; then
                echo "[`date +%Y%m%d.%H%M%S`] ${CON} - Start Failed. Check catalina.out log!!"         | tee -a ${LOG_FILE}
            fi
            \rm -rf ${LOCK_SEED}

            # if web_mon_cron.sh crontab is setting, then change SMS_LOG=/tmp/mw_work.log to SMS_LOG=/tmp/mw.log
            CHK_WEB_MON=`crontab -l | grep "^[0-9*]" | grep web_mon_cron.sh | wc -l`
            if [ ${CHK_WEB_MON} -gt 0 ]; then
                /software/tomcat/shl/startsms.sh; sleep 1;
            fi
        else
            #echo "[`date +%Y%m%d.%H%M%S`] ${CON} - no seed file or lock file exist" | tee -a /tmp/mw.log
            echo "[`date +%Y%m%d.%H%M%S`] ${CON} - no seed file or lock file exist"
        fi
    done
else
    #echo "[`date +%Y%m%d.%H%M%S`] - auto_restart.sh is running or terminated. auto_restart.sh process count is ${PROCESS_CHK}, not 1." | tee -a /tmp/mw.log
    echo "[`date +%Y%m%d.%H%M%S`] - auto_restart.sh is running or terminated. auto_restart.sh process count is ${PROCESS_CHK}, not 1."
fi

rm $PS_INFO

exit 0

