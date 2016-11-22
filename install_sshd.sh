#/bin/bash

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