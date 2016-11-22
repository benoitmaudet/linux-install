#/bin/bash

function install_deluged {
	sudo apt install -y deluge deluge-webui

	#Creates deluge service user
	sudo adduser --system --gecos "Deluge Service" --disabled-password --group --home /var/lib/deluge deluge

	#Adds current user to deluge group 
	sudo adduser `whoami` deluge

	#Cleans init or upstart (used by old version of ubuntu)
	sudo /etc/init.d/deluge-daemon stop
	sudo rm /etc/init.d/deluge-daemon
	sudo update-rc.d deluge-daemon remove 
	sudo stop deluged
	sudo stop deluge-web
	sudo rm /etc/init/deluge-web.conf
	sudo rm /etc/init/deluged.conf

	#Create logs directory
	sudo mkdir -p /var/log/deluge
	sudo chown -R deluge:deluge /var/log/deluge
	sudo chmod -R 750 /var/log/deluge

	#Create service file: /etc/systemd/system/deluged.service
	sudo sh -c 'echo "[Unit]" > /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "Description=Deluge Bittorrent Client Daemon" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "After=network-online.target" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "[Service]"" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "Type=simple" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "User=deluge" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "Group=deluge" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "UMask=007" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "ExecStart=/usr/bin/deluged -d -l /var/log/deluge/daemon.log -L warning" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "Restart=on-failure" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "# Configures the time to wait before service is stopped forcefully." >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "TimeoutStopSec=300" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "[Install]" >> /etc/systemd/system/deluged.service'
	sudo sh -c 'echo "WantedBy=multi-user.target" >> /etc/systemd/system/deluged.service'

	#Start the service and set auto start 
	sudo systemctl enable /etc/systemd/system/deluged.service
	sudo systemctl start deluged
	sudo systemctl status deluged

	#Create web service file: /etc/systemd/system/deluge-web.service
	sudo sh -c 'echo "[Unit]" > /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "Description=Deluge Bittorrent Client Web Interface" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "After=network-online.target" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "[Service]" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "Type=simple" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "User=deluge" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "Group=deluge" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "UMask=027" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "ExecStart=/usr/bin/deluge-web -p 9092 -l /var/log/deluge/web.log -L warning" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "Restart=on-failure" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "[Install]" >> /etc/systemd/system/deluge-web.service'
	sudo sh -c 'echo "WantedBy=multi-user.target" >> /etc/systemd/system/deluge-web.service'

	#Start the service and set auto start 
	sudo systemctl enable /etc/systemd/system/deluge-web.service
	sudo systemctl start deluge-web
	sudo systemctl status deluge-web

	#Set log rotation
	sudo sh -c 'echo "/var/log/deluge/*.log " > /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        rotate 4" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        weekly" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        missingok" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        notifempty" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        compress" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        delaycompress" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        sharedscripts" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        postrotate" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "                systemctl restart deluged >/dev/null 2>&1 || true" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "                systemctl restart deluge-web >/dev/null 2>&1 || true" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "        endscript" >> /etc/logrotate.d/deluge'
	sudo sh -c 'echo "}" >> /etc/logrotate.d/deluge'

	#Configure firewall
	sudo iptables -A INPUT -p tcp --dport 9092 -j ACCEPT
	sudo iptables -A OUTPUT -p tcp --dport 9093

	echo 'Change deluge-webui password'
	echo 'Change deluged password'

}

install_deluged
