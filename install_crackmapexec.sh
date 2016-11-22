#!/bin/bash
function install {
	sudo apt install -y python-cffi python-enum libssl-dev libffi-dev python-dev build-essential --force-yes
	sudo pip install cffi --upgrade
	sudo pip install crackmapexec
}

install
