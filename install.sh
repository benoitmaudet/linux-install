#!/bin/bash

#title           :install.sh
#description     :This script automatically installs my ubuntu system.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash install.sh
#notes           :

function check_internet {
	echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo -e '\033[0;32m[OK] You are online\033[0m'
	else
		echo -e '\033[0;33m[KO] You seem offline, please check your internet connection\033[0m' && sleep 4
	fi
}

function install_firefox {
	sudo apt install -y firefox >> install.log 2>&1
	#firebug
	wget https://addons.mozilla.org/firefox/downloads/latest/firebug/addon-1843-latest.xpi >> install.log 2>&1
	sudo firefox -install-global-extension addon-1843-latest.xpi >> install.log 2>&1 &
	#Adblock plus
	wget https://addons.mozilla.org/firefox/downloads/latest/adblock-plus/addon-1865-latest.xpi >> install.log 2>&1
	sudo firefox -install-global-extension addon-1865-latest.xpi >> install.log 2>&1 &
	#MM3-proxySwich
	wget https://addons.mozilla.org/firefox/downloads/latest/mm3-proxyswitch/addon-2648-latest.xpi >> install.log 2>&1
	sudo firefox -install-global-extension addon-2648-latest.xpi >> install.log 2>&1 &

	sudo rm addon-*.xpi
}

function install_desktop_home {
	#Home directories
	mkdir /home/`whoami`/securityDB
	mkdir /home/`whoami`/tools
	mkdir /home/`whoami`/vm
	mkdir /home/`whoami`/captures
	mkdir /home/`whoami`/.i3/
	mkdir /home/`whoami`/.config/
	mkdir /home/`whoami`/.config/terminator/

	#Configs
	cp .config/terminator/config /home/`whoami`/.config/terminator/config
}

function configure_sudoers {
	sudo echo -e "\n# Added by linux-install script" | sudo EDITOR="tee -a" visudo
	#Allow user to update and shutdown
	sudo echo "`whoami` ALL=/usr/bin/apt,/sbin/shutdown" | sudo EDITOR="tee -a" visudo
	#Reset environement on sudo and set timeout to 10 min
	sudo echo "Defaults env_reset,timestamp_timeout=10" | sudo EDITOR="tee -a" visudo
}

function install_git_projects {
	sudo git -C /opt clone https://github.com/royhills/ike-scan.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/secforce/sparta.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/adaptivethreat/BloodHound.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/PowerShellMafia/PowerSploit.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/adaptivethreat/Empire.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/samratashok/nishang.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/sqlmapproject/sqlmap.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/wpscanteam/wpscan.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/maurosoria/dirsearch.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/SpiderLabs/Responder.git >> install.log 2>&1 &
	sudo git -C /opt clone git://git.kali.org/packages/fierce.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/derv82/wifite.git >> install.log 2>&1 &
	sudo apt install -y apt install tshark reaver pyrit
	sudo git -C /opt clone https://github.com/robertdavidgraham/masscan.git >> install.log 2>&1 &
	sudo git -C /opt clone https://github.com/benoitmaudet/development_templates.git >> install.log 2>&1 &
}

function install_graphic_interface {
	#i3
	sudo apt install -y i3 i3lock >> install.log 2>&1
	sudo apt install -y xinit >> install.log 2>&1
	#Copy config file
	cp .i3/* ~/.i3/

	#terminator
	sudo apt install -y terminator >> install.log 2>&1

	#fonts
	sudo apt install -y fonts-font-awesome  >> install.log 2>&1
	wget https://github.com/hbin/top-programming-fonts/raw/master/Menlo-Regular.ttf -P ~/.fonts/  >> install.log 2>&1
	cp fonts/* /home/`whoami`/.fonts/
	fc-cache -f -v >> install.log 2>&1

	#fish
	sudo apt install -y fish >> install.log 2>&1
	curl -L http://get.oh-my.fish | fish
	fish -c "omf install agnoster & exit"

	#Set fish as default shell
	sudo chsh `whoami` -s /usr/bin/fish

	cp .config/fish/functions/nmap.fish /home/`whoami`/.config/fish/functions/

	#Graphical system tools
	sudo apt install -y nautilus scrot nm-applet gedit >> install.log 2>&1

	#Install lightdm and gtk greeter
	sudo apt install -y lightdm lightdm-gtk-greeter >> install.log 2>&1

	sudo bash -c 'echo "background=/home/`whoami`/wallpapers/autumn_bench-HD.jpg" >> /etc/lightdm/lightdm-gtk-greeter.conf'
	sudo bash -c 'echo "font-name=menlo" >> /etc/lightdm/lightdm-gtk-greeter.conf'

	sudo bash -c 'echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
	sudo bash -c 'echo "allow-guest=false" >> /etc/lightdm/lightdm.conf.d/50-no-guest.conf'

	#Set random wallpaper
	cp -R wallpapers /home/`whoami`/wallpapers
	feh --bg-scale --randomize /home/benoit/wallpapers/*
	bash -c "crontab -l | { cat; echo \"* * * * * DISPLAY=:0 feh --bg-scale --randomize /home/`whoami`/wallpapers/*\"; } | crontab -"

	#Install video/audio
	sudo apt install -y vlc alsa-utils pulseaudio-utils pulseaudio alsa-base alsa-oss >> install.log 2>&1
	sudo usermod -a -G audio `whoami`

	#Install notification manager
	sudo apt remove -y --purge dunst >> install.log 2>&1
	sudo apt install -y notify-osd >> install.log 2>&1

	#Install image viewer
	sudo apt install -y eog >> install.log 2>&1
}

function install_network {
	#Install wifi and gnome network manager
	sudo apt install -y wpasupplicant wireless-tools network-manager-gnome bcmwl-kernel-source >> install.log 2>&1
}

function configure_network {
	# Ignore ICMP broadcast requests
	sudo echo "# Ignore ICMP broadcast requests" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "" >> /etc/sysctl.d/10-network-security.conf

	# Disable source packet routing
	sudo echo "# Disable source packet routing" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv6.conf.all.accept_source_route = 0 " >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv6.conf.default.accept_source_route = 0" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "" >> /etc/sysctl.d/10-network-security.conf

	# Ignore send redirects
	sudo echo "	# Ignore send redirects" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "" >> /etc/sysctl.d/10-network-security.conf

	# Block SYN attacks
	sudo echo "	# Block SYN attacks" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.tcp_max_syn_backlog = 2048" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.tcp_syn_retries = 5" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "" >> /etc/sysctl.d/10-network-security.conf

	# Log Martians
	sudo echo "	# Log Martians" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "" >> /etc/sysctl.d/10-network-security.conf

	# Ignore ICMP redirects
	sudo echo "	# Ignore ICMP redirects" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.conf.default.accept_redirects = 0 " >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "" >> /etc/sysctl.d/10-network-security.conf

	# Ignore Directed pings
	sudo echo "	# Ignore Directed pings" >> /etc/sysctl.d/10-network-security.conf
	sudo echo "	net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.d/10-network-security.conf

	sudo sysctl -p

	#/etc/host.conf
	sudo echo "order bind,hosts" >> /etc/host.conf
	sudo echo "nospoof on" >> /etc/host.conf

	# Add Google DNS by default
	sudo bash -c 'echo "prepend domain-name-servers 8.8.8.8;" >> /etc/dhcp/dhclient.conf'
}

function set_permissions {
	#Home directory
	sudo chown `whoami`:`whoami` -R /home/`whoami`
	sudo chmod -R 600 /home/`whoami`
	sudo find /home/`whoami` -type d -exec chmod u+x {} \; >> install.log 2>&1

	sudo chown root:root -R /opt
	sudo chmod -R og-w /opt

	sudo chown root:root -R /root
	sudo chmod -R og-rwx /root 
}

function set_cron {
	sudo mkdir /root/scripts

	echo "# mm hh dd MMM DDD task > log" > crontab.tmp
	echo "# 	mm represents minutes (0-59)" >> crontab.tmp
	echo "# 	hh represents the hour (0-23)" >> crontab.tmp
	echo "# 	dd represents the day number of month (1-31)" >> crontab.tmp
	echo "# 	MMM represents the month number (1 to 12) or the abbreviated month name (jan, feb, mar, apr, ...)" >> crontab.tmp
	echo "# 	DDD is the abbreviated name of day or the number corresponding to the day of the week (0 is Sunday, 1 represents Monday, ...)" >> crontab.tmp
	echo "# 	task represents the command or shell script to run" >> crontab.tmp
	echo "# 	log is the name of a file in which to store the log of operations. If the clause >log is not specified, cron will automatically send a confirmation email. To avoid this, simply specify ">/dev/null""  >> crontab.tmp
	echo "" >> crontab.tmp

	echo "#Update every hour" >> crontab.tmp
	echo "0 * * * * * bash /root/scripts/update_system.sh" >> crontab.tmp
        echo "" >> crontab.tmp

	echo "@reboot bash /root/scripts/update_system.sh" >> crontab.tmp
	echo "@reboot bash /root/scripts/reset_firewall.sh" >> crontab.tmp
	echo "@reboot bash /root/scripts/reset_permissions.sh" >> crontab.tmp
	echo "@reboot bash chown `whoami`:`whoami` -R /home/`whoami`" >> crontab.tmp

	sudo cp ./update_system.sh /root/scripts/
	sudo chmod ugo+x /root/scripts/update_system.sh

	sudo cp ./reset_firewall.sh /root/scripts/
	sudo chmod ugo+x /root/scripts/reset_firewall.sh

	sudo cp ./reset_permissions.sh /root/scripts/
	sudo chmod ugo+x /root/scripts/reset_permissions.sh

	#install new cron file
	sudo crontab crontab.tmp
	rm crontab.tmp
}

function clean_groups_and_users {

	#Remove useless users
	sudo userdel backup
	sudo userdel sync
	sudo userdel gnats
	sudo userdel uucp
	sudo userdel lp
	sudo userdel irc
	sudo userdel proxy
	sudo userdel news
	sudo userdel list
	sudo userdel games

	#Remove useless groups
	sudo groupdel backup
	sudo groupdel irc
	sudo groupdel operator
	sudo groupdel gnats
	sudo groupdel staff
	sudo groupdel uucp
	sudo groupdel lp
	sudo groupdel users
	sudo groupdel news
	sudo groupdel src
	sudo groupdel list
	sudo groupdel games
	sudo groupdel www-data
	sudo groupdel proxy
}

for i in "$@"
do
case $i in
    -t=*|--type=*)
    TYPE="${i#*=}"
    ;;
    --server)
    SERVER=YES
    ;;
    --help)
    HELP=YES
    ;;
esac
done

if [[ ${HELP} ]]; then
    echo -e ""
    echo -e "\033[0;32mThis script automaticatlly install your new Ubuntu environment\033[0m"
    echo -e ""
    echo "Usage : ./install.sh [--help] [--server]"
    echo -e "\t --server\t server install mode (without graphical interfaces)"
    echo -e "\t --help \t display this help"
    exit
fi

echo "Install started" > install.log

#Checks if Ubuntu is OS
OS_NAME=`gawk -F= '/^NAME/{print $2}' /etc/os-release |tr -d '"'`
if [ "$OS_NAME" != "Ubuntu" ];
then
	echo "OS: $OS_NAME not compatible"
    exit
fi

check_internet

./update_system.sh

clean_groups_and_users

sudo apt install -y hwinfo curl git-core htop strings >> install.log 2>&1

if [[ -z ${SERVER} ]]; then
    echo -e "\033[0;33mNo [--server] specified. Desktop installation will be processed.\033[0m"

    install_desktop_home

    install_graphic_interface

    #Install graphical softwares
    sudo apt install -y wireshark redshift virtualbox pidgin libreoffice >> install.log 2>&1

    #KeePass
	sudo apt install -y keepass2 >> install.log 2>&1

	#Sublime-text
	echo -e "\033[1;31mTo install Sublime-text: firefox http://www.sublimetext.com/3\033[0m"

	install_firefox

	sudo apt install -y xbacklight feh >> install.log 2>&1

fi

#Detects virtual machine
if grep -iEq "^flags.*hypervior" /proc/cpuinfo ; then
	echo -e "\033[0;33mVirtual machine detected. Package 'open-vm-tools' will be installed.\033[0m"
    sudo apt install -y open-vm-tools >> install.log 2>&1
fi

chmod +x ./reset_firewall.sh
./reset_firewall.sh

sudo apt install -y python-pip ipcalc aha htop nmap openssl openjdk-8-jdk john aircrack-ng >> install.log 2>&1

install_network

#Copy bashrc(s)
sudo cp .bashrc_root /root/.bashrc
sudo cp .bashrc_user /home/`whoami`/.bashrc

chmod +x ./install_metasploit.sh
./install_metasploit.sh

chmod +x ./install_crackmapexec.sh
./install_crackmapexec.sh

install_git_projects

#chkrootkit, rkhunter, lynis
 sudo apt install -y rkhunter >> install.log 2>&1
 sudo rkhunter --update
 sudo apt install -y chkrootkit >> install.log 2>&1
 sudo apt install -y lynis >> install.log 2>&1
 sudo lynis --check-update

#Set hostname
sudo hostname `whoami`-pc

./update_system.sh

set_cron

configure_sudoers

set_permissions

echo "Install finished" >> install.log
