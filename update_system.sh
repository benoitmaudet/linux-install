#!/bin/bash

#title           :update_system.sh
#description     :This script updates my ubuntu system.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash update_system.sh
#notes           :

function update_system {
	#Ubuntu updates
	sudo apt update -y > /dev/null 2>&1
	if [ $? -eq 0 ] ;then
        echo -e "  \033[1;32m+\033[1;37m apt update succeed.\033[0m"
    else
        echo -e "  \033[1;31m-\033[1;37m apt update failed.\033[0m"
    fi

	sudo apt upgrade -y > /dev/null 2>&1
	if [ $? -eq 0 ] ;then
        echo -e "  \033[1;32m+\033[1;37m apt upgrade succeed.\033[0m"
    else
        echo -e "  \033[1;31m-\033[1;37m apt upgrade failed.\033[0m"
    fi
	sudo apt dist-upgrade -y > /dev/null 2>&1
	if [ $? -eq 0 ] ;then
        echo -e "  \033[1;32m+\033[1;37m apt dist-upgrade succeed.\033[0m"
    else
        echo -e "  \033[1;31m-\033[1;37m apt dist-upgrade failed.\033[0m"
    fi
	sudo apt autoremove -y > /dev/null 2>&1
	sudo apt autoclean -y > /dev/null 2>&1

	#Pip update
	echo -e "  \033[1;32m+\033[1;37m Updating pip...\033[0m"
	pip install --upgrade pip > /dev/null 2>&1

	#Github projects update
	echo -e "  \033[1;32m+\033[1;37m Updating github projects...\033[0m"
	for REPO in `find /opt -type d -name ".git" 2>&1 | grep -Ev "(Permission denied)|(metasploit)" | sed "s/.git/ /g"`; do (cd "$REPO"; git pull); done;
}

echo -e "\033[1;32mUpdating the system...\033[0m"
update_system
echo -e "\033[1;32mDone.\033[0m"
