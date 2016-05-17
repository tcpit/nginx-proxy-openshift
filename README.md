# openshift-nginx-proxy
1. Add a new application (Do-It-Yourself 0.1 Cartridge)
2. `cd /tmp`
3. `wget https://raw.githubusercontent.com/tcpit/openshift-nginx-proxy/master/autoinstall.sh`
4. `chmod 755 autoinstall.sh`
5. open autoinstall.sh and change 
`NGINX_VERSION='1.10.0'
PCRE_VERSION='8.38'`
6. `./autoinstall.sh`
The script may run for a while, just keep the ssh connection alive (300s is the default timeout on openshift).
