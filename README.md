# nginx-proxy-openshift
1. Add a new application (Do-It-Yourself 0.1 Cartridge)
2. `cd /tmp`
3. `wget https://raw.githubusercontent.com/tcpit/nginx-proxy-openshift/master/autoinstall.sh`
4. `chmod 755 autoinstall.sh`
5. open autoinstall.sh and change 
`NGINX_VERSION='1.10.0'
PHP_VERSION='5.6.21'`
6. `./autoinstall.sh`
The script may run for a long time, just keep the ssh connection alive (300s is the default timeout on openshift).
When the script ends running, find the `OPENSHIFT_DIY_IP` of the application via the command `export`.
7. `cd app-root/data/conf`
8. `rm -rf nginx.conf`
9. `wget https://raw.githubusercontent.com/tcpit/nginx-proxy-openshift/master/nginx.conf`
10. Replace the `OPENSHIFT_DIY_IP` in the conf (two places: 1st is in `listen OPENSHIFT_DIY_IP:8080;`, 2nd is in `fastcgi_pass OPENSHIFT_DIY_IP:9000;`)
11. Replace `proxy_cookie_domain google.com xxx-xxx.rhcloud.com` and `server_name xxx-xxx.rhcloud.com;` to your application domain (xxx-xxx.rhcloud.com) in `nginx.conf` 
12. `pkill -9 nginx`
13. `app-root/data/sbin/./nginx`
