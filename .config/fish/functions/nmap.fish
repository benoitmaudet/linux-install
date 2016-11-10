function nmap
	echo -e "\033[0;33m<!>DO NOT FORGET TO DISABLE FIREWALL<!>\033[0m"
        sleep 2
	/usr/bin/nmap $argv
end
