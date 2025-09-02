#!/bin/sh
##############################################
# instance    : template
# description : instance start script
# date        : 2015-05-23
##############################################
ABSOLUTE_PATH="$(cd $(dirname "$0") && pwd -P)"
PROFILE_PATH="${ABSOLUTE_PATH%/*}"
DIR_NAME="${PROFILE_PATH##*/}"

. $ABSOLUTE_PATH/tomcat.env

if [ -z "$SERVER_NAME" ]
then
	echo "WARNING : tomcat.env is not configured."
	echo "WARNING : Program Exit."
	exit 1
fi

if [ "$DIR_NAME" != "$SERVER_NAME" ]
then
	echo "WARNING : DIRECTORY and SERVER_NAME are not same"
	echo "WARNING : Program Exit."
	exit 1
fi

if [ $TOMCAT_USER != $UNAME ]
then
	echo "WARNING : Current User is [$UNAME]. MUST run to [$TOMCAT_USER]."
	echo "WARNING : Program Exit."
	exit 1
fi

case $1 in
    start|run)
	#RESULT=`$CATALINA_HOME/bin/catalina.sh configtest > /dev/null 2>&1`
	RESULT=`$CATALINA_HOME/bin/catalina.sh configtest`

	if [ $? -ne 0 ]
	then
	        echo "WARNING : server.xml configuration error. Program Exit."
	        exit 1
	else
	        $CATALINA_HOME/bin/catalina.sh $@
	fi
        ;;
    *)
	$CATALINA_HOME/bin/catalina.sh $@
esac
exit 0

# EOF
