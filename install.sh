#!/bin/bash
function install_firewall {

	#Flush all
	sudo iptables -F INPUT
	sudo iptables -F OUTPUT
	sudo iptables -F FORWARD

	#Default policy
	sudo iptables -P INPUT DROP
	sudo iptables -P OUTPUT DROP
	sudo iptables -P FORWARD DROP

	#MAIL IMAP
	sudo iptables -A INPUT -p tcp --dport 993 -j ACCEPT
	#HTTP, HTTPS
	sudo iptables -A OUTPUT -p tcp --dport 80
	sudo iptables -A OUTPUT -p tcp --dport 8080
	sudo iptables -A OUTPUT -p tcp --dport 443
	#DNS/WHOIS
	sudo iptables -A OUTPUT -p tcp --dport 53
	#SAMBA
	sudo iptables -A OUTPUT -p tcp --dport 445
	#JABBER, XMPP
	sudo iptables -A OUTPUT -p tcp --dport 5222
	sudo iptables -A OUTPUT -p tcp --dport 8010
	#FTP
	sudo iptables -A OUTPUT -p tcp --dport 21
	#SSH
	sudo iptables -A OUTPUT -p tcp --dport 22
	#RDP
	sudo iptables -A OUTPUT -p tcp --dport 3389
	#MAIL SMTP, IMAP
	sudo iptables -A OUTPUT -p tcp --dport 587
	sudo iptables -A OUTPUT -p tcp --dport 993
}

function install_firefox {
	sudo apt-get install -y firefox >> install.log 2>&1
	#firebug
	wget https://addons.mozilla.org/firefox/downloads/latest/firebug/addon-1843-latest.xpi
	sudo firefox -install-global-extension addon-1843-latest.xpi &
	#Adblock plus
	wget https://addons.mozilla.org/firefox/downloads/latest/adblock-plus/addon-1865-latest.xpi
	sudo firefox -install-global-extension addon-1865-latest.xpi &
	#MM3-proxySwich
	wget https://addons.mozilla.org/firefox/downloads/latest/mm3-proxyswitch/addon-2648-latest.xpi
	sudo firefox -install-global-extension addon-2648-latest.xpi &
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

function install_git_projects {
	sudo git -C /opt clone https://github.com/royhills/ike-scan.git
	sudo git -C /opt clone https://github.com/secforce/sparta.git
	sudo git -C /opt clone https://github.com/adaptivethreat/BloodHound.git
	sudo git -C /opt clone https://github.com/PowerShellMafia/PowerSploit.git
	sudo git -C /opt clone https://github.com/adaptivethreat/Empire.git
	sudo git -C /opt clone https://github.com/samratashok/nishang.git
	sudo git -C /opt clone https://github.com/sqlmapproject/sqlmap.git
	sudo git -C /opt clone https://github.com/wpscanteam/wpscan.git
	sudo git -C /opt clone https://github.com/maurosoria/dirsearch.git
	sudo git -C /opt clone https://github.com/SpiderLabs/Responder.git
	sudo git -C /opt clone git://git.kali.org/packages/fierce.git
	sudo git -C /opt clone https://github.com/derv82/wifite.git
	sudo git -C /opt clone https://github.com/robertdavidgraham/masscan.git
}

function install_graphic_interface {
	#i3
	sudo apt-get install -y i3 i3lock >> install.log 2>&1
	sudo apt-get install -y xinit >> install.log 2>&1
	#Copy config file
	cp .i3/* ~/.i3/

	#terminator
	sudo apt-get install -y terminator >> install.log 2>&1
	
	#fonts
	sudo apt-get install -y fonts-font-awesome  >> install.log 2>&1
	wget https://github.com/hbin/top-programming-fonts/raw/master/Menlo-Regular.ttf -P ~/.fonts/
	fc-cache -f -v

	#fish
	sudo apt-get install -y fish >> install.log 2>&1
	curl -L http://get.oh-my.fish | fish
	fish -c "omf install agnoster & exit"

	#Set fish as default shell
	sudo chsh `whoami` -s /usr/bin/fish 

	cp .config/fish/functions/nmap.fish /home/`whoami`/.config/fish/functions/

	#Graphical system tools
	sudo apt-get install -y nautilus scrot nm-applet gedit >> install.log 2>&1

	#Install lightdm and gtk greeter
	sudo apt-get install -y lightdm lightdm-gtk-greeter >> install.log 2>&1

	sudo bash -c 'echo "background=/home/`whoami`/wallpapers/autumn_bench-HD.jpg" >> /etc/lightdm/lightdm-gtk-greeter.conf'
	sudo bash -c 'echo "font-name=menlo" >> /etc/lightdm/lightdm-gtk-greeter.conf'

	sudo bash -c 'echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
	sudo bash -c 'echo "allow-guest=false" >> /etc/lightdm/lightdm.conf.d/50-no-guest.conf'

	#Set random wallpaper
	cp wallpapers /home/`whoami`/wallpapers
	bash -c 'crontab -l | { cat; echo "* * * * * feh --bg-scale --randomize /home/`whoami`/wallpapers/*"; } | crontab -'

	#Install video/audio
	sudo apt-get install -y vlc pulseaudio alsa-base alsa-oss >> install.log 2>&1
	sudo useradd `whoami` audio

	#Install notification manager
	sudo apt-get remove -y --purge dunst >> install.log 2>&1
	sudo apt-get install -y notify-osd >> install.log 2>&1

}

function install_network {
	#Install wifi and gnome network manager
	sudo apt-get install -y network-manager-gnome bcmwl-kernel-source >> install.log 2>&1
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
	echo -e "\033[0;32mUpdating the system...\033[0m"
	sudo apt-get update -y >> install.log 2>&1
	sudo apt-get upgrade -y >> install.log 2>&1
	sudo apt-get dist-upgrade -y >> install.log 2>&1
	sudo apt-get autoremove -y >> install.log 2>&1
	sudo apt-get autoclean -y >> install.log 2>&1
	echo -e "\033[0;32mSystem updated.\033[0m"
}

function set_permissions {	
	#Home directory
	sudo chown `whoami`:`whoami` -R /home/`whoami`
	sudo chmod -R 600 /home/`whoami`
	echo -e "\033[1;31mCheck /opt permissions\033[0m"
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

echo "Install started" > install.log

update_system

sudo apt-get install -y curl git-core htop strings >> install.log 2>&1

if [[ -z ${SERVER} ]]; then
    echo -e "\033[0;33mNo [--server] specified. Desktop installation will be processed.\033[0m"

    install_desktop_home

    install_graphic_interface

    #Install graphical softwares
    sudo apt-get install -y wireshark redshift virtualbox pidgin libreoffice >> install.log 2>&1

    #KeePass
	sudo apt-get install -y keepass2 >> install.log 2>&1

	#Sublime-text
	echo -e "\033[1;31mTo install Sublime-text: firefox http://www.sublimetext.com/3\033[0m"

	install_firefox

	install_git_projects

	chmod +x ./install_metasploit
	#./install_metasploit &

	sudo apt-get install -y wireless-tools xbacklight alsa-utils pulseaudio-utils feh >> install.log 2>&1

fi

if [[ -z ${VIRTUAL} ]]; then
    echo -e "\033[0;33mNo [--virtual] specified. Package 'open-vm-tools' will not be installed.\033[0m"

    sudo apt-get install -y open-vm-tools >> install.log 2>&1
fi

install_firewall

sudo apt-get install -y ipcalc aha htop nmap openssl openjdk-8-jdk john aircrack-ng >> install.log 2>&1

#Sudoers
echo -e "\033[1;31m Configure Sudoers \033[0m"

#chkrootkit, rkhunter, lynis
 sudo apt-get install -y rkhunter >> install.log 2>&1
 sudo rkhunter --update
 sudo apt-get install -y chkrootkit >> install.log 2>&1
 sudo apt-get install -y lynis >> install.log 2>&1
 sudo lynis --check-update

#Copy bashrc(s)
sudo cp .bashrc_root /root/.bashrc
sudo cp .bashrc_user /home/`whoami`/.bashrc

update_system

set_permissions

echo "Install finished" >> install.log
