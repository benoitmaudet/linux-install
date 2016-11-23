#!/bin/bash
function install_metasploit {
	sudo apt install -y build-essential libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev openjdk-7-jre git-core autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev curl zlib1g-dev >> install.log 2>&1
	sudo apt install -y ruby-dev libpq-dev libpcap-dev >> install.log 2>&1
	sudo apt install -y gnupg2  >> install.log 2>&1

    command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -

	curl -L https://get.rvm.io | bash -s stable
	source ~/.rvm/scripts/rvm
	echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
	source ~/.bashrc
	rvm install 2.1.9
	rvm use 2.1.9 --default
	ruby -v

	sudo -su postgres createuser msf -P -S -R -D
	sudo -su postgres createdb -O msf msf

	cd /opt
	sudo git clone https://github.com/rapid7/metasploit-framework.git
	sudo chown -R `whoami` /opt/metasploit-framework
	cd metasploit-framework
	# If using RVM set the default gem set that is create when you navigate in to the folder
	rvm --default use ruby-2.1.6@metasploit-framework
	sudo gem install bundler
	bundle install
}

install_metasploit
