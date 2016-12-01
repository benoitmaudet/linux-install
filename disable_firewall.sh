#!/bin/bash

#title           :disable_firewall.sh
#description     :This script disables iptables.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash disable_firewall.sh
#notes           :

fw='sudo iptables'

function flush_firewall {
	#Flush all
	$fw -F
    $fw -X
    $fw -t nat -F
    $fw -t nat -X
    $fw -t mangle -F
    $fw -t mangle -X
    if [ $? -eq 0 ] ;then
        echo -e "  \033[1;32m+\033[1;37m Clear rules.\033[0m"
    else
        echo -e "  \033[1;31m-\033[1;37m Clear rules failed.\033[0m"
    fi
}

function disable_firewall {
    flush_firewall

    # Allow ALL
    $fw -P INPUT ACCEPT
    $fw -P OUTPUT ACCEPT
    $fw -P FORWARD ACCEPT
    $fw -t nat -P PREROUTING ACCEPT
    $fw -t nat -P POSTROUTING ACCEPT
    $fw -t nat -P OUTPUT ACCEPT
    $fw -t mangle -P PREROUTING ACCEPT
    $fw -t mangle -P POSTROUTING ACCEPT
    $fw -t mangle -P INPUT ACCEPT
    $fw -t mangle -P OUTPUT ACCEPT
    $fw -t mangle -P FORWARD ACCEPT
}

echo -e "\033[1;32mDisabling firewall...\033[0m"
disable_firewall
if [ $? -eq 0 ] ;then
    echo -e "\033[1;32mDone.\033[0m"
else
    echo -e "\033[1;31mFail.\033[0m"
fi
