#!/bin/bash

#title           :create_t_ssl_certificate.sh
#description     :This script creates SSL certificate.
#author		 :Benoit MAUDET
#date            :20161201
#version         :0.1
#usage		 :bash create_root_certificate.sh <certificateFileName> <rootCertificateFileName>
#notes           :


function create_certificate {
	#Create and sign certificate with root cert
	openssl genrsa -out $1.key 2048
	openssl req -new -key $1.key -out $1.csr
	#Common Name (eg, YOUR name) []: 10.0.0.1
	openssl x509 -req -in $1.csr -CA $2.pem -CAkey $2.key -CAcreateserial -out $1.crt -days 500 -sha512
}

if [ "$#" -ne 2 ]
then
    echo -e ""
    echo -e "\033[0;32mThis script automaticatlly create a new ssl certificate signed from your CA\033[0m"
    echo -e ""
    echo -e "Usage : ./create_ssl_certificate.sh <certificateFileName> <rootCertificateFileName>"
    exit 1
fi

echo -e "\033[1;37m The certificate will be created in: \033[1;32m$1\033[1;37m.\033[0m"
echo -e "\033[1;37m The CA file is: \033[1;32m$2\033[1;37m.\033[0m"

create_certificate $1 $2
