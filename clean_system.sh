#!/bin/bash

function clean_system {
	clean_metasoloit
	clean_sqlmap
	clean_logs
}

function clean_metasploit {
	#TODO: clean DB
}

function clean_sqlmap {
	#TODO: clean logs and retreived data
	#/opt/sqlmap/
}

function clean_logs {
	#TODO: clean web, ssh, auth, apt, deluge, lightdm, postgresql, dpkg, samba
	#TODO: clean /var/log/syslog.*
	#TODO: dirsearch logs
}

clean_system
