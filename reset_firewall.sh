#!/bin/bash

fw='sudo iptables'
loop_ip='127.0.0.1'
loop_net='127.0.0.0/8'

chains_list=(
    'BLACKLIST_LOGS'
    'BLACKLIST'
    'RATE'
    'BAN'
)

function reset_firewall {
	create_and_configure_logs

	flush_firewall

	 for chain in ${chains_list[@]}; do
        $fw -N $chain
        if [ $? -eq 0 ] ;then
            echo -e "  \033[1;32m+\033[1;37m Chain \033[1;32m$chain\033[1;37m created.\033[0m"
        else
            echo -e "  \033[1;32m+\033[1;37m Chain \033[1;32m$chain\033[1;37m failed.\033[0m"
        fi
    done

    # BLACKLIST
    $fw -A BLACKLIST -m recent --name "BAN" --rcheck --seconds 86400 -j BLACKLIST_LOGS
    $fw -A BLACKLIST -m recent --name "BAN" --remove

    # BAN LOGS
    $fw -A BLACKLIST_LOGS -m limit --limit 3/min --limit-burst 3 -j LOG --log-prefix "[Blacklist]: "
    $fw -A BLACKLIST_LOGS -j DROP

    # BAN
    $fw -A BAN -j LOG --log-prefix "[BAN - DROP]: "
    $fw -A BAN -m recent --name "BAN" --set --rsource -j DROP

    # RATE - DROP
    $fw -A RATE -m recent --name "CHECK" --set --rsource
    $fw -A RATE -m recent --name "CHECK" --update --seconds 120 --hitcount 10 --rsource --rttl -m limit --limit 3/min --limit-burst 3 -j BAN
    $fw -A RATE -j DROP

	#Default policy: DROP
	$fw -P INPUT DROP
	$fw -P OUTPUT DROP
	$fw -P FORWARD DROP

	# Loopback
    $fw -A INPUT -s $loop_ip ! -i lo -j DROP
    $fw -A INPUT -i lo -j ACCEPT
    $fw -A OUTPUT -s $loop_ip ! -o lo -j DROP
    $fw -A OUTPUT -o lo -j ACCEPT

 	# Allow Establish
    $fw -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    #$fw -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    # Allow Input
    $fw -A INPUT -m pkttype --pkt-type broadcast -j DROP
    $fw -A INPUT -m pkttype --pkt-type multicast -j DROP
    $fw -A INPUT -j BLACKLIST
    $fw -A INPUT -p icmp -m comment --comment "ICMP" -j ACCEPT    
  	#$fw -A INPUT -p tcp --dport 4444 -m comment --comment "Reverse TCP Shell" -j ACCEPT
	#$fw -A INPUT -p tcp --dport 9092 -m comment --comment "Deluge web client" -j ACCEPT

    # Allow Output
    $fw -A OUTPUT -p icmp -m comment --comment "ICMP" -j ACCEPT
    $fw -A OUTPUT -p tcp --dport 22 -m comment --comment "SSH TCP" -j ACCEPT
    $fw -A OUTPUT -p tcp --dport 53 -m comment --comment "DNS TCP" -j ACCEPT
    $fw -A OUTPUT -p udp --dport 53 -m comment --comment "DNS UDP" -j ACCEPT
    $fw -A OUTPUT -p udp --dport 5353 -m comment --comment "MULTICAST DNS UDP" -j ACCEPT
    $fw -A OUTPUT -p udp --dport 123 -m comment --comment "NTP" -j ACCEPT
    $fw -A OUTPUT -p tcp -m multiport --dports 80,443,8080 -m comment --comment "HTTP" -j ACCEPT
    $fw -A OUTPUT -p tcp -m multiport --dports 25,465,587,993 -m comment --comment "Mail" -j ACCEPT
    $fw -A OUTPUT -p tcp --dport 445 -m comment --comment "SAMBA" -j ACCEPT
	$fw -A OUTPUT -p tcp --dport 5222 -m comment --comment "JABBER, XMPP" -j ACCEPT
	$fw -A OUTPUT -p tcp --dport 6667 -m comment --comment "IRC" -j ACCEPT
	$fw -A OUTPUT -p tcp --dport 8010 -m comment --comment "" -j ACCEPT
	$fw -A OUTPUT -p tcp --dport 21 -m comment --comment "FTP" -j ACCEPT
	$fw -A OUTPUT -p tcp --dport 3389 -m comment --comment "RDP" -j ACCEPT
	#$fw -A OUTPUT -p tcp --dport 9093 -m comment --comment "Deluged" -j ACCEPT

	# Log DROP OUTPUT
    $fw -A OUTPUT -j LOG --log-prefix "[DROP OUTPUT]: "

    # Allow Other
    $fw -A INPUT -j RATE
}

function create_and_configure_logs {
	log_dir='/var/log/iptables/'

	input_log=$log_dir'input.log'
	output_log=$log_dir'output.log'
	ban_log=$log_dir'ban.log'
	blacklist_log=$log_dir'blacklist.log'

	sudo mkdir -p $log_dir

	if [ ! -e $input_log ] ; then
		sudo touch $input_log
	fi
	sudo chown syslog:syslog $input_log
	sudo chmod 640 $input_log

	if [ ! -e $output_log ] ; then
		sudo touch $output_log
	fi
	sudo chown syslog:syslog $output_log
	sudo chmod 640 $output_log

	if [ ! -e $ban_log ] ; then
		sudo touch $ban_log
	fi
	sudo chown syslog:syslog $ban_log
	sudo chmod 640 $ban_log

	if [ ! -e $blacklist_log ] ; then
		sudo touch $blacklist_log
	fi
	sudo chown syslog:syslog $blacklist_log
	sudo chmod 640 $blacklist_log

	sudo chown root:syslog $log_dir
	sudo chmod 750 $log_dir

	if [ -z "$(grep iptables /etc/rsyslog.d/10-iptables.conf)" ]; then
		sudo echo ':msg,contains,"[DROP INPUT]: " /var/log/iptables/input.log' > 10-iptables.conf
		sudo echo '& stop' >> 10-iptables.conf
		sudo echo ':msg,contains,"[DROP OUTPUT]: " /var/log/iptables/output.log' >> 10-iptables.conf
		sudo echo '& stop' >> 10-iptables.conf
		sudo echo ':msg,contains,"[BAN - DROP]: " /var/log/iptables/ban.log' >> 10-iptables.conf
		sudo echo '& stop' >> 10-iptables.conf
		sudo echo ':msg,contains,"[Blacklist]: " /var/log/iptables/blacklist.log' >> 10-iptables.conf
		sudo echo '& stop' >> 10-iptables.conf
		sudo mv 10-iptables.conf /etc/rsyslog.d/10-iptables.conf
		sudo systemctl restart rsyslog.service
	fi

	if [ -z "$(grep iptables /etc/logrotate.d/rsyslog)" ]; then
		sudo sed -i '/\/var\/log\/messages/a \/var\/log\/iptables\/input.log' /etc/logrotate.d/rsyslog
		sudo sed -i '/\/var\/log\/messages/a \/var\/log\/iptables\/output.log' /etc/logrotate.d/rsyslog
		sudo sed -i '/\/var\/log\/messages/a \/var\/log\/iptables\/ban.log' /etc/logrotate.d/rsyslog
		sudo sed -i '/\/var\/log\/messages/a \/var\/log\/iptables\/blacklist.log' /etc/logrotate.d/rsyslog
		sudo systemctl restart rsyslog.service
	fi
}

function flush_firewall {
	#Flush all
	$fw -F
    $fw -X
    $fw -t nat -F
    $fw -t nat -X
    $fw -t mangle -F
    $fw -t mangle -X
    if [ $? -eq 0 ] ;then
        echo -e "  \033[1;32m+\033[1;37m Clear rules.\033[0m"
    else
        echo -e "  \033[1;31m-\033[1;37m Clear rules failed.\033[0m"
    fi
}

echo -e "\033[1;32mResetting firewall...\033[0m"
reset_firewall
if [ $? -eq 0 ] ;then
    echo -e "\033[1;32mDone.\033[0m"
else
    echo -e "\033[1;31mFail.\033[0m"
fi
