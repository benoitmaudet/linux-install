#!/bin/bash

#title           :deploy_updated_script.sh
#description     :This script deploys linux-install updates.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash deploy_updated_script.sh
#notes           :

sudo cp clean_system.sh /root/scripts/
sudo cp update_system.sh /root/scripts/
sudo cp disable_firewall.sh /root/scripts/
sudo cp reset_firewall.sh /root/scripts/
sudo cp reset_permissions.sh /root/scripts/

sudo chmod 700 /root/scripts/*
