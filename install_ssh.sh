#!/bin/bash

#title           :install_ssh.sh
#description     :This script installs ssh client and generate rsa key.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash install_ssh.sh
#notes           :

function install_client {
	sudo apt install -y openssh-client
	 #Generate rsa keys for
	 ssh-keygen -t rsa -f server_`whoami`

	 # To move ssh public key to distant server (~/.ssh/authorized_keys)
	 echo 'ssh-copy-id -i ~/.ssh/server_`whoami`.pub -p <num_port> "<username>@<ipaddress>"'
}

install_client
