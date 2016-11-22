 #/bin/bash

function install_client {
	sudo apt install -y openssh-client
	 #Generate rsa keys for 
	 ssh-keygen -t rsa -f server_`whoami`

	 # To move ssh public key to distant server (~/.ssh/authorized_keys)
	 echo 'ssh-copy-id -i ~/.ssh/server_`whoami`.pub -p <num_port> "<username>@<ipaddress>"'
}

install_client
