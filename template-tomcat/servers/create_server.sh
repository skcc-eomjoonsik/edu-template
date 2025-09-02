#!/bin/bash

# Check parameter
if [ $# -ne 1 ]; then
   echo "Usage> create_server.sh \"SERVER_NAME\""
   exit 1;
fi

# ENV
SERVER_NAME=$1
CATALINA_HOME=/software/tomcat
LOG_HOME=/log_data/tomcat/${SERVER_NAME}
AUTO_RESTART_HOME=/log_data/auto_restart/${SERVER_NAME}

##############################
# Create Server Directory
##############################
_create_server()
{
    cd "${CATALINA_HOME}/servers" || exit
    if [ ! -d "${SERVER_NAME}" ]; then
        # Create server dir
        cp -Rp template "${SERVER_NAME}"

        # create log dir & link
        mkdir -p ${LOG_HOME}/{gclog,heapdump,temp}
        ln -s "${LOG_HOME}" "${CATALINA_HOME}/servers/${SERVER_NAME}/logs"

        # make auto_restart dir
        mkdir -p ${AUTO_RESTART_HOME}
        chmod 770 ${AUTO_RESTART_HOME}

        # modify ${SERVER_NAME} in tomcat.env
        perl -pi -e "s/template/${SERVER_NAME}/g" ${CATALINA_HOME}/servers/${SERVER_NAME}/shl/tomcat.env
    else
        echo "The server specified is already exists"
        exit 1;
    fi
}

##############################
# Add new server in scripts 
##############################
_add_script()
{
    # log_del.sh auto_restart.sh
    for script in log_del.sh auto_restart.sh; do
        SVRS=$(grep ^SERVERS ${CATALINA_HOME}/shl/${script} | cut -d'"' -f2)
        perl -pi -e "s/SERVERS=\"${SVRS}/SERVERS=\"${SVRS}${SERVER_NAME} /g" ${CATALINA_HOME}/shl/${script}
    done

    # logrotate.cfg
    NEWLINE=$(awk '/{/{print NR; exit}' ${CATALINA_HOME}/shl/logrotate.cfg)
    awk -v newline=${NEWLINE} -v servername=${SERVER_NAME} 'NR==newline{print "/log_data/tomcat/"servername"/catalina.out"}1' ${CATALINA_HOME}/shl/logrotate.cfg > ${CATALINA_HOME}/shl/logrotate.cfg.new
    mv ${CATALINA_HOME}/shl/logrotate.cfg.new ${CATALINA_HOME}/shl/logrotate.cfg

    # tomcat_start.sh tomcat_restart.sh
    for script in tomcat_start.sh tomcat_restart.sh; do
        NEWLINE=$(awk '/### check_web/{print NR; exit}' ${CATALINA_HOME}/shl/${script})
        awk -v newline=${NEWLINE} -v servername=${SERVER_NAME} 'NR==newline{print ""}1' ${CATALINA_HOME}/shl/${script} > ${CATALINA_HOME}/shl/${script}.new
        mv ${CATALINA_HOME}/shl/${script}.new ${CATALINA_HOME}/shl/${script}
        
        awk -v newline=${NEWLINE} -v servername=${SERVER_NAME} 'NR==newline{print "/software/tomcat/servers/"servername"/shl/start.sh; sleep 3;"}1' ${CATALINA_HOME}/shl/${script} > ${CATALINA_HOME}/shl/${script}.new
        mv ${CATALINA_HOME}/shl/${script}.new ${CATALINA_HOME}/shl/${script}
    done

    # tomcat_stop.sh
    echo "/software/tomcat/servers/${SERVER_NAME}/shl/stop.sh; sleep 3;" >> ${CATALINA_HOME}/shl/tomcat_stop.sh
    echo ""                                                              >> ${CATALINA_HOME}/shl/tomcat_stop.sh
}

##############################
# Add Crontab
##############################
_add_crontab() {
    add_cron_entry() {
        local entry=$1
        local description=$2
        local command=$3
        if ! crontab -l | grep -v "^#" | grep -q "${command}"; then
            (crontab -l; echo ""; echo "################################################################"; echo "# ${description}"; echo "################################################################"; echo "${entry}") | crontab -
        fi
    }

    add_cron_entry "0 0 * * * /software/tomcat/shl/log_del.sh 1>/dev/null 2>&1"                           "Tomcat Daily Log Delete"  "/log_del.sh"
    add_cron_entry "0 0 * * * /usr/sbin/logrotate -f /software/tomcat/shl/logrotate.cfg 1>/dev/null 2>&1" "Tomcat Daily Log Rotate"  "/logrotate "
    add_cron_entry "1-59/3 * * * * /home/webwas/shl/mon/web_mon_cron.sh 1>/dev/null 2>&1"                 "Apache/Tomcat Monitoring" "/web_mon_cron.sh"
}

##############################
# Add New Server in Alias
##############################
_add_alias() {
    SVR_CNT=$(grep ^#SERVER_CNT ${CATALINA_HOME}/shl/alias.tomcat | cut -d'=' -f2)
    NEW_CNT=$((SVR_CNT + 1))

    perl -pi -e "s/SERVER_CNT=${SVR_CNT}/SERVER_CNT=${NEW_CNT}/g" ${CATALINA_HOME}/shl/alias.tomcat

    cat <<EOF >> ${CATALINA_HOME}/shl/alias.tomcat

alias  tcfg${NEW_CNT}='cd /software/tomcat/servers/${SERVER_NAME}/conf;                    ls -l'
alias  tdep${NEW_CNT}='cd /software/tomcat/servers/${SERVER_NAME}/conf/Catalina/localhost; ls -l'
alias  tshl${NEW_CNT}='cd /software/tomcat/servers/${SERVER_NAME}/shl;                     ls -l'
alias  tlog${NEW_CNT}='cd /log_data/tomcat/${SERVER_NAME};                                 ls -lart | tail -30'
alias talog${NEW_CNT}='tail -30f /log_data/tomcat/${SERVER_NAME}/localhost_access.\$(date +%Y-%m-%d).log'
alias telog${NEW_CNT}='tail -30f /log_data/tomcat/${SERVER_NAME}/localhost.\$(date +%Y-%m-%d).log'
alias tclog${NEW_CNT}='tail -30f /log_data/tomcat/${SERVER_NAME}/catalina.out'
EOF

    grep -v "^#" ${CATALINA_HOME}/shl/alias.tomcat >> ${HOME}/.bash_profile
    perl -pi -e "s/^alias/#alias/g" ${CATALINA_HOME}/shl/alias.tomcat
    bash --init-file ${HOME}/.bash_profile
}

##############################
# main
##############################
main()
{
    _create_server
    _add_script
    #_add_crontab
    _add_alias
}

main
