#!/bin/bash

# Check parameter
if [ $# -ne 1 ]; then
   echo "Usage> create_server.sh \"SERVER_NAME\""
   exit 1;
fi

# ENV
SERVER_NAME=$1
APACHE_HOME=/software/apache
LOG_HOME=/log_data/apache/${SERVER_NAME}

##############################
# Create Server Directory
##############################
_create_server()
{
    cd "${APACHE_HOME}/servers" || exit
    if [ ! -d "${SERVER_NAME}" ]; then
        # Create server dir
        cp -Rp template "${SERVER_NAME}"

        # Create log dir & link
        mkdir -p "${LOG_HOME}"
        ln -s "${LOG_HOME}" "${APACHE_HOME}/servers/${SERVER_NAME}/logs"

        # Modify server name in configuration files
        for file in conf/httpd.conf conf/extra/httpd-jk.conf conf/extra/httpd-mpm.conf conf/extra/httpd-ssl.conf shl/start.sh shl/stop.sh; do
            perl -pi -e "s/template/${SERVER_NAME}/g" "${APACHE_HOME}/servers/${SERVER_NAME}/${file}"
        done
    else
        echo "The server specified already exists"
        exit 1
    fi
}

##############################
# Add New Server in log_del.sh & logrotate.cfg & start/stop/restart all script
##############################
_add_script()
{
    # log_del.sh
    perl -pi -e "s/(SERVERS=\")([^\"]*)\"/\1\2${SERVER_NAME} \"/" "${APACHE_HOME}/shl/log_del.sh"

    # log_del.sh
    SVRS=`grep ^SERVERS ${APACHE_HOME}/shl/log_del.sh | cut -d'"' -f2`
    perl -pi -e "s/SERVERS=\"${SVRS}/SERVERS=\"${SVRS}${SERVER_NAME} /g" ${APACHE_HOME}/shl/log_del.sh

    # apache_start.sh
    NEWLINE=`cat -n ${APACHE_HOME}/shl/apache_start.sh | grep "### check_web" | awk '{print $1}'`
    awk -v newline=${NEWLINE} -v servername=${SERVER_NAME} '{ if (NR==newline) print ""; print $0}' ${APACHE_HOME}/shl/apache_start.sh > ${APACHE_HOME}/shl/apache_start.sh.new
    awk -v newline=${NEWLINE} -v servername=${SERVER_NAME} '{ if (NR==newline) print "/software/apache/servers/"servername"/shl/start.sh; sleep 5;"; print $0}' ${APACHE_HOME}/shl/apache_start.sh.new \
    > ${APACHE_HOME}/shl/apache_start.sh; \rm ${APACHE_HOME}/shl/apache_start.sh.new

    # apache_restart.sh
    NEWLINE=`cat -n ${APACHE_HOME}/shl/apache_restart.sh | grep "### check_web" | awk '{print $1}'`
    awk -v newline=${NEWLINE} -v servername=${SERVER_NAME} '{ if (NR==newline) print ""; print $0}' ${APACHE_HOME}/shl/apache_restart.sh > ${APACHE_HOME}/shl/apache_restart.sh.new
    awk -v newline=${NEWLINE} -v servername=${SERVER_NAME} '{ if (NR==newline) print "/software/apache/servers/"servername"/shl/start.sh; sleep 5;"; print $0}' ${APACHE_HOME}/shl/apache_restart.sh.new \
    > ${APACHE_HOME}/shl/apache_restart.sh
    awk -v newline=${NEWLINE} -v servername=${SERVER_NAME} '{ if (NR==newline) print "/software/apache/servers/"servername"/shl/stop.sh;  sleep 5;"; print $0}' ${APACHE_HOME}/shl/apache_restart.sh \
    > ${APACHE_HOME}/shl/apache_restart.sh.new; mv ${APACHE_HOME}/shl/apache_restart.sh.new ${APACHE_HOME}/shl/apache_restart.sh

    # apache_stop.sh
    echo "/software/apache/servers/${SERVER_NAME}/shl/stop.sh;  sleep 5;" >> ${APACHE_HOME}/shl/apache_stop.sh
    echo ""                                                               >> ${APACHE_HOME}/shl/apache_stop.sh
}

##############################
# Add Crontab
##############################
_add_crontab()
{
    add_cron_entry() {
        local entry=$1
        local description=$2
        local command=$3
        if ! crontab -l | grep -v "^#" | grep -q "${command}"; then
            (crontab -l; echo ""; echo "################################################################"; echo "# ${description}"; echo "################################################################"; echo "${entry}") | crontab -
        fi
    }

    add_cron_entry "0 0 * * * /software/apache/shl/log_del.sh 1>/dev/null 2>&1"                           "Apache Daily Log Delete"  "/log_del.sh"
    add_cron_entry "1-59/3 * * * * /home/webwas/shl/mon/web_mon_cron.sh 1>/dev/null 2>&1"                 "Apache/Tomcat Monitoring" "/web_mon_cron.sh"
}

##############################
# Add New Server in Alias
##############################
_add_alias()
{   
    SVR_CNT=$(grep ^#SERVER_CNT ${APACHE_HOME}/shl/alias.apache | cut -d'=' -f2)
    NEW_CNT=$((SVR_CNT + 1))

    perl -pi -e "s/SERVER_CNT=${SVR_CNT}/SERVER_CNT=${NEW_CNT}/g" ${APACHE_HOME}/shl/alias.apache

    cat <<EOF >> ${APACHE_HOME}/shl/alias.apache

alias  acfg${NEW_CNT}='cd /software/apache/servers/${SERVER_NAME}/conf; ls -l'
alias  ashl${NEW_CNT}='cd /software/apache/servers/${SERVER_NAME}/shl;  ls -l'
alias  alog${NEW_CNT}='cd /log_data/apache/${SERVER_NAME};              ls -lart | tail -30'
alias aalog${NEW_CNT}='tail -30f /log_data/apache/${SERVER_NAME}/access.log.\$(date +%Y%m%d)'
alias aelog${NEW_CNT}='tail -30f /log_data/apache/${SERVER_NAME}/error.log.\$(date +%Y%m%d)'
alias  mlog${NEW_CNT}='tail -30f /log_data/apache/${SERVER_NAME}/mod_jk.log.\$(date +%Y%m%d)'
alias salog${NEW_CNT}='tail -30f /log_data/apache/${SERVER_NAME}/ssl_access.log.\$(date +%Y%m%d)'
alias selog${NEW_CNT}='tail -30f /log_data/apache/${SERVER_NAME}/ssl_error.log.\$(date +%Y%m%d)'
EOF

    grep -v "^#" ${APACHE_HOME}/shl/alias.apache >> ${HOME}/.bash_profile
    perl -pi -e "s/^alias/#alias/g" ${APACHE_HOME}/shl/alias.apache
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
