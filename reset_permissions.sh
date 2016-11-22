#!/bin/bash
function reset_permissions {
	sudo chown root:root -R /opt
	sudo chmod -R og-w /opt

	sudo chown root:root -R /root
	sudo chmod -R og-rwx /root 
}

reset_permissions
