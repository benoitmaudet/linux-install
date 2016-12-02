#!/bin/bash

#title           :install_crackmapexec.sh
#description     :This script installs crackmapexec.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash install_crackmapexec.sh
#notes           :

function install {
	sudo apt install -y python-cffi python-enum libssl-dev libffi-dev python-dev build-essential --force-yes
	sudo pip install cffi --upgrade
	sudo pip install crackmapexec
}

install
