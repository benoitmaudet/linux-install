#!/bin/bash

#title           :reset_permissions.sh
#description     :This script resets directories permissions.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash reset_permissions.sh
#notes           :

function reset_permissions {
	sudo chown root:root -R /opt
	sudo chmod -R og-w /opt

	sudo chown root:root -R /root
	sudo chmod -R og-rwx /root
}

reset_permissions
