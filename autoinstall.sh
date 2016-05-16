#!/bin/bash

NGINX_VERSION='1.10.0'
PHP_VERSION='5.6.21'
cd $OPENSHIFT_TMP_DIR
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar xzf nginx-${NGINX_VERSION}.tar.gz
wget http://exim.mirror.fr/pcre/pcre-8.38.tar.gz
tar xzf pcre-8.38.tar.gz
git clone https://github.com/FRiCKLE/ngx_cache_purge.git
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
cd ${OPENSHIFT_TMP_DIR}nginx-${NGINX_VERSION}
./configure --prefix=$OPENSHIFT_DATA_DIR --with-pcre=${OPENSHIFT_TMP_DIR}pcre-8.38 --with-pcre-jit --with-threads --with-http_realip_module --with-http_sub_module --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_geoip_module --with-http_secure_link_module --with-http_perl_module --without-mail_pop3_module
--without-mail_imap_module --without-mail_smtp_module --add-module=${OPENSHIFT_TMP_DIR}ngx_http_substitutions_filter_module --add-module=${OPENSHIFT_TMP_DIR}ngx_cache_purge
make -j4 && make install
cd /tmp
rm -rf *
wget -O libmcrypt-2.5.8.tar.gz http://downloads.sourceforge.net/mcrypt/libmcrypt-2.5.8.tar.gz?big_mirror=0
tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j && make install
cd libltdl
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local --enable-ltdl-install
make -j && make install
cd ../..
wget -O mhash-0.9.9.9.tar.gz http://downloads.sourceforge.net/mhash/mhash-0.9.9.9.tar.gz?big_mirror=0
tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j && make install
cd ..
wget  --no-check-certificate -O re2c-0.16.tar.gz https://github.com/skvadrik/re2c/releases/download/0.16/re2c-0.16.tar.gz
tar xzf re2c-0.16.tar.gz
cd re2c-0.16
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j4 && make install
cd ..
wget -O mcrypt-2.6.8.tar.gz http://downloads.sourceforge.net/mcrypt/mcrypt-2.6.8.tar.gz?big_mirror=0
tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
export LDFLAGS="-L${OPENSHIFT_DATA_DIR}usr/local/lib -L/usr/lib"
export CFLAGS="-I${OPENSHIFT_DATA_DIR}usr/local/include -I/usr/include"
export LD_LIBRARY_PATH="/usr/lib/:${OPENSHIFT_DATA_DIR}usr/local/lib"
export PATH="/bin:/usr/bin:/usr/sbin:${OPENSHIFT_DATA_DIR}usr/local/bin:${OPENSHIFT_DATA_DIR}bin:${OPENSHIFT_DATA_DIR}sbin"
touch malloc.h
./configure --prefix=${OPENSHIFT_DATA_DIR}usr/local --with-libmcrypt-prefix=${OPENSHIFT_DATA_DIR}usr/local
make -j && make install
cd ..
wget -O php-${PHP_VERSION}.tar.gz http://us3.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror
tar xzf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}
./configure --prefix=$OPENSHIFT_DATA_DIR --with-config-file-path=${OPENSHIFT_DATA_DIR}etc --with-layout=GNU --with-mcrypt=${OPENSHIFT_DATA_DIR}usr/local --with-pear --with-pgsql --with-mysqli --with-pdo-mysql --with-pdo-pgsql --enable-pdo --with-pdo-sqlite --with-sqlite3 --with-openssl --with-zlib-dir --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-bz2 --with-libxml-dir --with-curl --with-gd --with-xsl --with-xmlrpc --with-mhash --with-gettext --with-readline --with-kerberos --with-pcre-regex --enable-json --enable-bcmath --enable-cli --enable-calendar --enable-dba --enable-wddx --enable-inline-optimization --enable-simplexml --enable-filter --enable-ftp --enable-tokenizer --enable-dom --enable-exif --enable-mbregex --enable-fpm --enable-mbstring --enable-gd-native-ttf --enable-xml --enable-xmlwriter --enable-xmlreader --enable-pcntl --enable-zend-multibyte --enable-sockets --enable-zip --enable-soap --enable-shmop --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-intl --enable-maintainer-zts --enable-discard-path --enable-opcache --disable-debug --disable-fileinfo --disable-phar --disable-ipv6 --disable-rpath
make -j4 && make install
cp ${OPENSHIFT_TMP_DIR}php-${PHP_VERSION}/php.ini-development ${OPENSHIFT_DATA_DIR}etc/php.ini
cp ${OPENSHIFT_DATA_DIR}etc/php-fpm.conf.default ${OPENSHIFT_DATA_DIR}etc/php-fpm.conf
echo "<?php phpinfo(); ?>" >> ${OPENSHIFT_DATA_DIR}html/info.php
cd /tmp
wget http://pecl.php.net/get/memcache-3.0.8.tgz
tar xzf memcache-3.0.8.tgz
cd memcache-3.0.8
phpize
./configure --with-php-config=${OPENSHIFT_DATA_DIR}/bin/php-config --enable-memcache
make -j && make install
cd ..
wget http://pecl.php.net/get/geoip-1.0.8.tgz
tar xzf geoip-1.0.8.tgz
cd geoip-1.0.8
phpize
./configure --with-php-config=${OPENSHIFT_DATA_DIR}/bin/php-config --with-geoip
make -j && make install
sed -i "s/default_type  application\/octet-stream;/default_type  application\/octet-stream;\n    port_in_redirect off;\n    server_tokens off;/g" ${OPENSHIFT_DATA_DIR}conf/nginx.conf
sed -i "s/listen       80;/listen       ${OPENSHIFT_DIY_IP}:8080;/g" ${OPENSHIFT_DATA_DIR}conf/nginx.conf
sed -i "s/            index  index.html index.htm;/           index  index.html index.php index.htm;/g" ${OPENSHIFT_DATA_DIR}conf/nginx.conf
sed -i "s/nginx\/\$nginx_version;/nginx;/g" ${OPENSHIFT_DATA_DIR}conf/fastcgi.conf
sed -i "s/# deny access to .htaccess files, if Apache's document root/location ~ \\\.php\$ {\n            root           html;\n            fastcgi_pass   ${OPENSHIFT_DIY_IP}:9000;\n            fastcgi_index  index.php;\n            fastcgi_param   SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;\n            fastcgi_param   SCRIPT_NAME        \$fastcgi_script_name;\n            include        fastcgi_params;\n        }\n\n        # deny access to .htaccess files, if Apache's document root/g" ${OPENSHIFT_DATA_DIR}conf/nginx.conf
sed -i "s/user = nobody/;user = nobody/g" ${OPENSHIFT_DATA_DIR}etc/php-fpm.conf
sed -i "s/group = nobody/;group = nobody/g" ${OPENSHIFT_DATA_DIR}etc/php-fpm.conf
sed -i "s/listen = 127.0.0.1:9000/listen = ${OPENSHIFT_DIY_IP}:9000/g" ${OPENSHIFT_DATA_DIR}etc/php-fpm.conf
sed -i "s/short_open_tag = Off/short_open_tag = On/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 38M/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/max_file_uploads = 20/max_file_uploads = 38/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/post_max_size = 8M/post_max_size = 38M/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/max_input_time = 60/max_input_time = 300/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/default_socket_timeout = 60/default_socket_timeout = 300/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/max_execution_time = 30/max_execution_time = 180/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/;date.timezone =/date.timezone = Asia\/Taipei/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
sed -i "s/; End:/; End:\n\nzend_extension=opcache.so\nextension=memcache.so\nextension=geoip.so\n;extension=pthreads.so\n/g" ${OPENSHIFT_DATA_DIR}etc/php.ini
cd /tmp
rm -rf *
cd ${OPENSHIFT_REPO_DIR}.openshift/action_hooks
rm -rf start
wget --no-check-certificate https://raw.githubusercontent.com/tcpit/nginx-proxy-openshift/master/start
chmod 755 start
cd ${OPENSHIFT_REPO_DIR}.openshift/cron/minutely
rm -rf restart.sh
wget --no-check-certificate https://raw.githubusercontent.com/tcpit/nginx-proxy-openshift/master/restart.sh
chmod 755 restart.sh
touch nohup.out
chmod 755 nohup.out
rm -rf delete_log.sh
wget --no-check-certificate https://raw.githubusercontent.com/tcpit/nginx-proxy-openshift/master/delete_log.sh
chmod 755 delete_log.sh
cd ${OPENSHIFT_DATA_DIR}html
rm -rf index.html
gear stop
gear start

