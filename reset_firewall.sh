#!/bin/bash
function reset_firewall {

	#Flush all
	sudo iptables -F INPUT
	sudo iptables -F OUTPUT
	sudo iptables -F FORWARD

	#Default policy
	sudo iptables -P INPUT DROP
	sudo iptables -P OUTPUT DROP
	sudo iptables -P FORWARD DROP
	
	#Allow ping
	sudo iptables -A INPUT -p icmp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A OUTPUT -p icmp -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

	#Allow established
	sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

	#Deluge web client and torrent
	#sudo iptables -A INPUT -p tcp --dport 9092 -j ACCEPT
	#sudo iptables -A OUTPUT -p tcp --dport 9093

	#MAIL IMAP
	sudo iptables -A INPUT -m state --state NEW,ESTABLISHED -p tcp --dport 993 -j ACCEPT
	sudo iptables -A INPUT -j LOG --log-prefix "INPUT:DROP:" --log-level 6

#HTTP, HTTPS
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 80 -j ACCEPT
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 8080 -j ACCEPT
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 443 -j ACCEPT
	#DNS/WHOIS
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 53 -j ACCEPT
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p udp --dport 53 -j ACCEPT

	#SAMBA
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 445 -j ACCEPT
	#JABBER, XMPP
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 5222 -j ACCEPT
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 8010 -j ACCEPT
	#FTP
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 21 -j ACCEPT
	#SSH
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 22 -j ACCEPT
	#RDP
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 3389 -j ACCEPT
	#MAIL SMTP, IMAP
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 587 -j ACCEPT
	sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED -p tcp --dport 993 -j ACCEPT
	sudo iptables -A OUTPUT -j LOG --log-prefix "OUTPUT:DROP:" --log-level 6
}

reset_firewall
