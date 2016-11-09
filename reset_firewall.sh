function reset_firewall {

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

reset_firewall
