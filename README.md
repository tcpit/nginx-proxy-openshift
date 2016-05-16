# nginx-proxy-openshift
1. Add a new application (Do-It-Yourself 0.1 Cartridge)
2. `cd /tmp`
3. `wget https://raw.githubusercontent.com/tcpit/openshift-nginx-proxy/master/autoinstall.sh`
4. `chmod 755 autoinstall.sh`
5. open autoinstall.sh and change 
`NGINX_VERSION='1.10.0'
PCRE_VERSION='8.38'`
6. `./autoinstall.sh`
The script may run for a while, just keep the ssh connection alive (300s is the default timeout on openshift).
When the script ends running, find the `OPENSHIFT_DIY_IP` of the application via the command `export`.
7. `cd app-root/data/conf`
8. `rm -rf nginx.conf`
9. `wget https://raw.githubusercontent.com/tcpit/openshift-nginx-proxy/master/nginx.conf`
10. Replace the `OPENSHIFT_DIY_IP` in `nginx.conf`
11. Replace the `xxx-xxx.rhcloud.com` to your application domain (xxx-xxx.rhcloud.com) in `nginx.conf` 
12. `gear restart`
