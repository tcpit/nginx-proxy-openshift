#!/bin/bash

export TZ='Asia/Shanghai'

curl -I ${OPENSHIFT_APP_DNS} 2> /dev/null | head -1 | grep -q '200\|301\|302\|404\|403'

s=$?

if [ $s != 0 ];
	then
		echo "`date +"%Y-%m-%d %H:%M:%S"` down" >> ${OPENSHIFT_LOG_DIR}web_error.log
		echo "`date +"%Y-%m-%d %H:%M:%S"` restarting..." >> ${OPENSHIFT_LOG_DIR}web_error.log
		killall nginx
		nohup ${OPENSHIFT_DATA_DIR}/sbin/nginx > ${OPENSHIFT_LOG_DIR}/server.log 2>&1 &
		killall php-fpm
		nohup ${OPENSHIFT_DATA_DIR}/sbin/php-fpm &
		#/usr/bin/gear start 2>&1 /dev/null
		echo "`date +"%Y-%m-%d %H:%M:%S"` restarted!!!" >> ${OPENSHIFT_LOG_DIR}web_error.log		
else
	echo "`date +"%Y-%m-%d %H:%M:%S"` is ok" > ${OPENSHIFT_LOG_DIR}web_run.log
fi
