#!/bin/bash

NGINX_VERSION='1.11.5'
PCRE_VERSION='8.39'

cd $OPENSHIFT_TMP_DIR

wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar xzf nginx-${NGINX_VERSION}.tar.gz
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
#http://exim.mirror.fr/pcre/pcre-${PCRE_VERSION}.tar.gz
tar xzf pcre-${PCRE_VERSION}.tar.gz
git clone https://github.com/FRiCKLE/ngx_cache_purge.git
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
cd ${OPENSHIFT_TMP_DIR}nginx-${NGINX_VERSION}
./configure --prefix=$OPENSHIFT_DATA_DIR --with-pcre=${OPENSHIFT_TMP_DIR}pcre-${PCRE_VERSION} --with-pcre-jit --with-threads --with-http_realip_module --with-http_sub_module --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_geoip_module --with-http_secure_link_module --without-mail_pop3_module
--without-mail_imap_module --without-mail_smtp_module --add-module=${OPENSHIFT_TMP_DIR}ngx_http_substitutions_filter_module --add-module=${OPENSHIFT_TMP_DIR}ngx_cache_purge
make -j4 && make install
cd /tmp
rm -rf *
cd ${OPENSHIFT_REPO_DIR}.openshift/action_hooks
rm -rf start
cat>start<<EOF
#!/bin/bash
# The logic to start up your application should be put in this
# script. The application will work only if it binds to
# \$OPENSHIFT_DIY_IP:8080
#nohup \$OPENSHIFT_REPO_DIR/diy/testrubyserver.rb \$OPENSHIFT_DIY_IP \$OPENSHIFT_REPO_DIR/diy |& /usr/bin/logshifter -tag diy &
nohup \$OPENSHIFT_DATA_DIR/sbin/nginx > \$OPENSHIFT_LOG_DIR/server.log 2>&1 &
EOF
chmod 755 start
cd ${OPENSHIFT_REPO_DIR}.openshift/cron/minutely
rm -rf restart.sh
cat>restart.sh<<EOF
#!/bin/bash
export TZ='Asia/Shanghai'

curl -I \${OPENSHIFT_APP_DNS} 2> /dev/null | head -1 | grep -q '200\|301\|302\|404\|403'

s=\$?

if [ \$s != 0 ];
	then
		echo "`date +"%Y-%m-%d %H:%M:%S"` down" >> \${OPENSHIFT_LOG_DIR}web_error.log
		echo "`date +"%Y-%m-%d %H:%M:%S"` restarting..." >> \${OPENSHIFT_LOG_DIR}web_error.log
		killall nginx
		nohup \${OPENSHIFT_DATA_DIR}/sbin/nginx > \${OPENSHIFT_LOG_DIR}/server.log 2>&1 &
		#/usr/bin/gear start 2>&1 /dev/null
		echo "`date +"%Y-%m-%d %H:%M:%S"` restarted!!!" >> \${OPENSHIFT_LOG_DIR}web_error.log		
else
	echo "`date +"%Y-%m-%d %H:%M:%S"` is ok" > \${OPENSHIFT_LOG_DIR}web_run.log
fi
EOF
chmod 755 restart.sh
touch nohup.out
chmod 755 nohup.out
rm -rf delete_log.sh
cat>delete_log.sh<<EOF
#!/bin/bash
export TZ="Asia/Shanghai"

# 每天 00:30 06:30 12:30 18:30 删除一次网站日志
hour="`date +%H%M`"
if [ "\$hour" = "0030" -o "\$hour" = "0630" -o "\$hour" = "1230" -o "\$hour" = "1830" ]
then
  echo "Scheduled delete at \$(date) ..." >&2
  (
  sleep 1
  cd \${OPENSHIFT_LOG_DIR}
  rm -rf *
  echo "delete OPENSHIFT_LOG at \$(date) ..." >&2
  sleep 1
  cd \${OPENSHIFT_DATA_DIR}/logs
  rm -rf *.log
  echo "delete nginx logs at \$(date) ..." >&2
  ) &
  exit
fi
EOF
chmod 755 delete_log.sh

cd $OPENSHIFT_DATA_DIR/conf
rm nginx.conf
wget --no-check-certificate https://github.com/tcpit/openshift-nginx-proxy/raw/master/nginx.conf
sed -i "s/OPENSHIFT_DIY_IP/$OPENSHIFT_DIY_IP/g" nginx.conf
sed -i "s/xxx-xxx.rhcloud.com/$OPENSHIFT_APP_DNS/g" nginx.conf
gear stop
gear start
