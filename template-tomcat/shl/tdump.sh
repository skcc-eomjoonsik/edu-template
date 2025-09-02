#!/bin/bash

. ~/.bash_profile > /dev/null
. $HOME/mon/web_mon_cron.env

if [ $# -ne 1 ] ; then
    echo "SERVER_NAME is null. Select Number of Server"
    for index in ${!WAS_INST_NAME[@]}
    do
        echo "${index} : ${WAS_INST_NAME[$index]}"
    done
    printf "SERVER_NAME : "
    read INPUT_NUM
    SERVER_NAME=${WAS_INST_NAME[${INPUT_NUM}]}
else
    SERVER_NAME=$1
fi

DUMP_DIR=/home/webwas/dump
PID=`ps -ef | grep java | grep -w "D${SERVER_NAME}" | egrep -vw "vi|vim|grep|cat|more|tail" | awk '{print $2}'`

###################################################
# DUMP Directory Check
###################################################
if [ ! -d ${DUMP_DIR} ]; then
   mkdir -p ${DUMP_DIR}
fi

###################################################
# Process Check
###################################################
_Process_Exist_Chk()
{
        if [ "${PID}" = "" ] ; then
        echo "${SERVER_NAME} process does not exist!"
        exit
 fi
}

Thread_Dump()
{
        _Process_Exist_Chk
        for i in 1 2 3
           do
             TDUMP_FILE="${DUMP_DIR}/td_`hostname`_${SERVER_NAME}_`date +'%Y%m%d_%H%M%S'`.log"
             jstack -l ${PID} > ${TDUMP_FILE}
             echo "check thread dump file ${TDUMP_FILE}"
             sleep 3
           done
}

Thread_Dump
