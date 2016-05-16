#!/bin/bash

NGINX_VERSION='1.10.0'
PCRE_VERSION='8.38'

cd $OPENSHIFT_TMP_DIR

wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar xzf nginx-${NGINX_VERSION}.tar.gz
wget http://exim.mirror.fr/pcre/pcre-${PCRE_VERSION}.tar.gz
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
wget --no-check-certificate https://raw.githubusercontent.com/tcpit/openshift-nginx-proxy/master/start
chmod 755 start
cd ${OPENSHIFT_REPO_DIR}.openshift/cron/minutely
rm -rf restart.sh
wget --no-check-certificate https://raw.githubusercontent.com/tcpit/openshift-nginx-proxy/master/restart.sh
chmod 755 restart.sh
touch nohup.out
chmod 755 nohup.out
rm -rf delete_log.sh
wget --no-check-certificate https://raw.githubusercontent.com/tcpit/openshift-nginx-proxy/master/delete_log.sh
chmod 755 delete_log.sh
gear stop
gear start
