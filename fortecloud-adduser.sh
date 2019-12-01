#!/bin/bash

#Script is designed to create a user, add their SSH key and provide SUDO permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "Type the username of the user that will be added, followed by an ENTER:"
read username 
echo "Copy and paste the SSH Key of the user, followed by an ENTER:"
read sshKey
echo "Will the user require sudo permission? 'true' or 'false' ONLY, followed by an ENTER:"
read sudo

OS=$(awk '/ID=/' /etc/*-release | sed 's/ID=//' | tr '[:upper:]' '[:lower:]' | grep -v 'version\|distrib')
#Verifies all fields are populated

if [[ -z "$username" || -z "$sshKey" || -z "$sudo" ]]; then
   echo "The username, sshKey or Sudo  fields may not be empty, format ./sshscript username sshKey sudo"
   exit 1
fi



#Check to verify if OS version is Ubuntu, if it is Ubuntu it runs a --force-badname and --gecos to turn off interactive mode of the adduser script. If it is Amazon Linux
if [[ $OS == *"ubuntu" ]]
	then
		adduser  --force-badname --gecos "" $username
	else	
		adduser $username

fi

mkdir -m 700 /home/$username/.ssh && chown $username:$username /home/$username/.ssh
printf "$sshKey" > /home/$username/.ssh/authorized_keys && chmod 600 /home/$username/.ssh/authorized_keys && chown $username:$username /home/$username/.ssh/authorized_keys
if [[ $sudo == "true" ]]; then
		printf "$username ALL = NOPASSWD: ALL\n# User rules for $username \n$username ALL=(ALL) NOPASSWD:ALL\n" | sudo tee /etc/sudoers.d/$username > /dev/null && sudo chmod 440 /etc/sudoers.d/$username
	else
		echo "The user will not be granted sudo permissions" 
fi


