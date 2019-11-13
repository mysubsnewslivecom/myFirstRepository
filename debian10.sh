#!/bin/bash
#################################################
#Script for new debian 10 setup			#
#################################################


user=`whoami`
scriptname=`basename $0`
scriptlog=/tmp/$scriptname.log

infoLog(){
        logtime=`date "+%Y%m%d %H:%M:%S"`
        message="$1"
        printf "\033[1;92m%s\033[0m\n" "[$logtime #INFO] $message "|tee -a $scriptlog
}

updateApt(){

	infoLog "creating backup of /etc/apt/sources.list"
	cp -iv /etc/apt/sources.list /etc/apt/sources.list_bckup 

    cat /dev/null > /etc/apt/sources.list

	infoLog "Adding /etc/apt/sources.list"

    echo "deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list

    echo "deb http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list


    echo "deb http://deb.debian.org/debian buster main" >> /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list

    echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
    echo "deb http://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

	infoLog "/etc/apt/sources.list Updated!!!"
}

update(){
	
	infoLog "Update & Upgrade of apps"
	apt-get -y update && apt-get -y upgrade
	infoLog "Update & Upgrade of apps complete!!!"

}

installEssential(){

	infoLog "Installing vim dkms build-essential module-assistant dos2unix etc"
	apt-get -y install wget vim dkms build-essential module-assistant dos2unix net-tools git wireless-tools linux-headers-$(uname -r)
	infoLog "Installing vim dkms build-essential module-assistant dos2unix complete!!!"

}

updateMOTD(){

	infoLog "Updating /etc/motd to $(hostname)"
	echo `hostname -f` > /etc/motd 

}

sudo groupadd common
sudo usermod -G common,sudo ${user}

updateApt
update
installEssential
#updateMOTD





