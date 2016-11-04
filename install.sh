#!/bin/bash
function install_firewall {
	sudo apt-get install -y ufw gufw

	sudo ufw default deny incoming
	sudo ufw default deny forwarding
	sudo ufw default deny outgoing

	#MAIL IMAP
	sudo ufw allow in 993/tcp
	#HTTP, HTTPS
	sudo ufw allow out 80/tcp
	sudo ufw allow out 8080
	sudo ufw allow out 443/tcp
	#DNS/WHOIS
	sudo ufw allow out 53
	#SAMBA
	sudo ufw allow out 445
	#JABBER, XMPP
	sudo ufw allow out 5222
	sudo ufw allow out 8010
	#FTP
	sudo ufw allow out 21
	#SSH
	sudo ufw allow out 22
	#RDP
	sudo ufw allow out 3389/tcp
	#MAIL SMTP, IMAP
	sudo ufw allow out 587/tcp
	sudo ufw allow out 993/tcp

	sudo ufw enable
}

function install_firefox {
	sudo apt-get install -y firefox
	#firebug
	wget https://addons.mozilla.org/firefox/downloads/latest/firebug/addon-1843-latest.xpi
	sudo firefox -install-global-extension addon-1843-latest.xpi
	#Adblock plus
	wget https://addons.mozilla.org/firefox/downloads/latest/adblock-plus/addon-1865-latest.xpi
	sudo firefox -install-global-extension addon-1865-latest.xpi
	#MM3-proxySwich
	wget https://addons.mozilla.org/firefox/downloads/latest/mm3-proxyswitch/addon-2648-latest.xpi
	sudo firefox -install-global-extension addon-2648-latest.xpi
}

function install_desktop_home {
	#Home directories
	mkdir ~/securityDB
	mkdir ~/tools
	mkdir ~/vm
	mkdir ~/captures
	mkdir ~/.i3/
	mkdir ~/.config/
	mkdir ~/.config/terminator/

	#Configs
	cp .config/terminator/config ~/.config/terminator/config
}

function install_git_projects {
	git clone https://github.com/royhills/ike-scan.git -C /opt
	git clone https://github.com/secforce/sparta.git -C /opt
	git clone https://github.com/adaptivethreat/BloodHound.git -C /opt
	git clone https://github.com/PowerShellMafia/PowerSploit.git -C /opt
	git clone https://github.com/adaptivethreat/Empire.git -C /opt
	git clone https://github.com/samratashok/nishang.git -C /opt
	git clone https://github.com/sqlmapproject/sqlmap.git -C /opt
	git clone https://github.com/wpscanteam/wpscan.git -C /opt
	git clone https://github.com/maurosoria/dirsearch.git -C /opt
	git clone https://github.com/SpiderLabs/Responder.git -C /opt
	git clone git://git.kali.org/packages/fierce.git -C /opt
	git clone https://github.com/derv82/wifite.git -C /opt
	git clone https://github.com/robertdavidgraham/masscan.git -C /opt
}

function install_metasploit {
	sudo apt-get install build-essential libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev openjdk-7-jre git-core autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev curl zlib1g-dev

	curl -L https://get.rvm.io | bash -s stable
	source ~/.rvm/scripts/rvm
	echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
	source ~/.bashrc
	rvm install 2.1.9
	rvm use 2.1.9 --default
	ruby -v

	sudo -su postgres
	createuser msf -P -S -R -D
	createdb -O msf msf
	exit

	cd /opt
	sudo git clone https://github.com/rapid7/metasploit-framework.git
	sudo chown -R `whoami` /opt/metasploit-framework
	cd metasploit-framework
	# If using RVM set the default gem set that is create when you navigate in to the folder
	rvm --default use ruby-2.1.6@metasploit-framework
	gem install bundler
	bundle install
}

function install_graphic_interface {
	#i3
	sudo apt-get install -y i3 i3lock
	sudo apt-get install -y xinit
	#TODO: copy i3 conf
	echo -e "\033[1;31mCopy i3 configuration files to home directory\033[0m"

	#terminator
	sudo apt-get install -y terminator
	
	#fonts
	sudo apt-get install -y fonts-font-awesome 
	wget https://github.com/hbin/top-programming-fonts/raw/master/Menlo-Regular.ttf -P ~/.fonts/

	#fish
	sudo apt-get install -y fish
	curl -L http://get.oh-my.fish | fish
	omf install agnoster

	#Graphical system tools
	sudo apt-get install -y nautilus scrot nm-applet
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
}

function update_system {
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get dist-upgrade
	sudo apt-get autoremove
	sudo apt-get autoclean
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
    --virtual)
    VIRTUAL=YES
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
    echo "Usage : ./install.sh [--help] [--server] [--virtual]"
    echo -e "\t --server\t server install mode (without graphical interfaces)"
    echo -e "\t --virtual\t install 'open-vm-tools' package"
    echo -e "\t --help \t display this help"
    exit
fi

update_system

if [[ -z ${SERVER} ]]; then
    echo -e "\033[0;33mNo [--server] specified. Desktop installation will be processed.\033[0m"

    install_graphic_interface

    #Install graphical softwares
    sudo apt-get install -y wireshark redshift sublime-text virtualbox pidgin

    #KeePass
	sudo apt-get install -y keepass2 

	#Sublime-text
	echo -e "\033[1;31mTo install Sublime-text: firefox http://www.sublimetext.com/3\033[0m"

	#Wallpaper: copy and set
	echo -e "\033[1;31mCopy and set Wallpapers\033[0m"

	install_firefox

	install_desktop_home

	install_git_projects

	install_metasploit

	sudo apt-get install -y wireless-tools
fi

if [[ -z ${VIRTUAL} ]]; then
    echo -e "\033[0;33mNo [--virtual] specified. Package 'open-vm-tools' will not be installed.\033[0m"

    sudo apt-get install -y open-vm-tools
fi

install_firewall

sudo apt-get install -y ipcalc aha nmap openssl openjdk-8-jdk john aircrack-ng

#Sudoers
echo -e "\033[1;31m Configure Sudoers \033[0m"

#chkrootkit, rkhunter, lynis
 sudo apt-get install rkhunter 
 sudo rkhunter --update
 sudo apt-get install chkrootkit
 sudo apt-get install lynis
 sudo lynis --check-update

#Copy bashrc
echo -e "\033[1;31m Copy .bashrc file \033[0m"

update_system
