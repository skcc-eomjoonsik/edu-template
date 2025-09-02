#!/bin/bash

SERVER_NAME=template

/software/apache/bin/apachectl -f /software/apache/servers/${SERVER_NAME}/conf/httpd.conf -k stop
