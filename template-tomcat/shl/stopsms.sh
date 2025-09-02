#!/bin/bash

MON_HOME=/home/`whoami`/shl/mon

perl -pi -e "s/SMS_LOG=\/tmp\/mw.log/SMS_LOG=\/tmp\/mw_work.log/g" ${MON_HOME}/web_mon_cron.env

