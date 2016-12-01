#!/bin/bash

#title           :create_root_ssl_certificate.sh
#description     :This script creates SSL root certificate.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash create_root_ssl_certificate.sh <rootCertificateFileName>
#notes           :

function create_root_certificate {
	#Create root cert and self-sign it
	openssl genrsa -des3 -out $1.key 2048
	openssl req -x509 -new -nodes -key $1.key -sha256 -days 1024 -out $1.pem
}

if [ "$#" -ne 2 ]
then
    echo -e ""
    echo -e "\033[0;32mThis script automaticatlly create a new root certificate\033[0m"
    echo -e ""
    echo -e "Usage : ./create_root_ssl_certificate.sh <rootCertificateFileName>"
    exit 1
fi

echo -e "\033[1;37m The CA file is: \033[1;32m$1\033[1;37m.\033[0m"

create_root_certificate $1
