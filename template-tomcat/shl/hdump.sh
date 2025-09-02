#!/bin/bash

. ~/.bash_profile > /dev/null
. $HOME/shl/mon/web_mon_cron.env

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
# HEAPDUMP Directory, Filename Setting
###################################################
DUMP_EXIST_CHK_DIR=$CATALINA_HOME/servers/$SERVER_NAME/logs/heapdump
DUMP_NAME_TYPE=java_pid${PID}.hprof

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

###################################################
# Check HEAPDUMP Exist
###################################################
_Dump_Exist_Chk()
{
        TMP=${DUMP_DIR}/heap_dump_exist_chk.tmp
        touch -t `TZ=KST-8 date +%m%d%H%M` ${TMP}
        if [ "`find $DUMP_EXIST_CHK_DIR -type f -name "$DUMP_NAME_TYPE" -newer ${TMP}`" ] ; then
                echo "heap dump file exist"
                find $DUMP_EXIST_CHK_DIR -type f -name "$DUMP_NAME_TYPE" -newer ${TMP} -exec ls -al {} \;
                find ${DUMP_DIR} -type f -name "heap_dump_exist_chk.tmp" -exec rm {} \; 
                exit
        fi
        find ${DUMP_DIR} -type f -name "heap_dump_exist_chk.tmp" -exec rm {} \;
} 

Heap_Dump()
{
        _Process_Exist_Chk
        _Dump_Exist_Chk
        HDUMP_FILE="${DUMP_DIR}/hd_`hostname`_${SERVER_NAME}_`date +'%Y%m%d_%H%M%S'`.hprof"
        jmap -dump:live,format=b,file=${HDUMP_FILE} ${PID}
        echo "check heap dump file ${HDUMP_FILE}"
}
 
Heap_Dump
