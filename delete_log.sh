#!/bin/bash

export TZ="Asia/Shanghai"

# 每天 00:30 06:30 12:30 18:30 删除一次网站日志
hour="`date +%H%M`"
if [ "$hour" = "0030" -o "$hour" = "0630" -o "$hour" = "1230" -o "$hour" = "1830" ]
then
  echo "Scheduled delete at $(date) ..." >&2
  (
  sleep 1
  cd ${OPENSHIFT_LOG_DIR}
  rm -rf *
  echo "delete OPENSHIFT_LOG at $(date) ..." >&2
  sleep 1
  cd ${OPENSHIFT_DATA_DIR}/logs
  rm -rf *.log
  echo "delete nginx logs at $(date) ..." >&2
  sleep 1
  cd ${OPENSHIFT_DATA_DIR}/var/log
  rm -rf *.log
  echo "delete php-fpm logs at $(date) ..." >&2
  ) &
  exit
fi
