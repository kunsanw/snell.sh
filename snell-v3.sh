#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
CONF="/etc/snell/snell-server.conf"
SYSTEMD="/etc/systemd/system/snell.service"
cd ~/
wget --no-check-certificate https://github.com/kunsanw/snell.sh/releases/download/dev/snell-server
 chmod +x snell-server
 mv -f snell-server /usr/local/bin/
 if [ -f ${CONF} ]; then
   echo "Found existing config..."
   else
   if [ -z ${PSK} ]; then
     PSK=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
     echo "Using generated PSK: ${PSK}"
   else
     echo "Using predefined PSK: ${PSK}"
   fi
   mkdir /etc/snell/
   echo "Generating new config..."
   echo "[snell-server]" >>${CONF}
   echo "listen = 0.0.0.0:13254" >>${CONF}
   echo "psk = ${PSK}" >>${CONF}
   echo "obfs = tls" >>${CONF}
 fi
 if [ -f ${SYSTEMD} ]; then
   echo "Found existing service..."
   systemctl daemon-reload
   systemctl restart snell
 else
   echo "Generating new service..."
   echo "[Unit]" >>${SYSTEMD}
   echo "Description=Snell Proxy Service" >>${SYSTEMD}
   echo "After=network.target" >>${SYSTEMD}
   echo "" >>${SYSTEMD}
   echo "[Service]" >>${SYSTEMD}
   echo "Type=simple" >>${SYSTEMD}
   echo "LimitNOFILE=32768" >>${SYSTEMD}
   echo "ExecStart=/usr/local/bin/snell-server -c /etc/snell/snell-server.conf" >>${SYSTEMD}
   echo "" >>${SYSTEMD}
   echo "[Install]" >>${SYSTEMD}
   echo "WantedBy=multi-user.target" >>${SYSTEMD}
   systemctl daemon-reload
   systemctl enable snell
   systemctl start snell
 fi
