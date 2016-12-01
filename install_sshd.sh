#!/bin/bash

#title           :install_sshd.sh
#description     :This script installs ssh server.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash install_sshd.sh
#notes           :

function install_server {
	sudo apt install -y openssh-client openssh-server

	# to sshd_config
	echo 'Set the following parameters to /etc/ssh/sshd_config after rsa key creation'
	echo 'PermitRootLogin no'
	echo "PasswordAuthentication no"
	echo "UsePAM no"
	echo "AllowUsers `whoami`"
}

install_server
