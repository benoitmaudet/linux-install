#!/bin/bash
function update_system {
	echo -e "\033[0;32mUpdating the system...\033[0m"
	sudo apt update -y > /dev/null 2>&1
	sudo apt upgrade -y > /dev/null 2>&1
	sudo apt dist-upgrade -y > /dev/null 2>&1
	sudo apt autoremove -y > /dev/null 2>&1
	sudo apt autoclean -y > /dev/null 2>&1
	echo -e "\033[0;32mSystem updated.\033[0m"
}

update_system
