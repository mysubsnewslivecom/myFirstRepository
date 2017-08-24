#!/bin/bash
#################################################
#Script for new debian 9 setup			#
#################################################

scriptname=`basename $0`
scriptlog=/tmp/$scriptname.log

infoLog(){
        logtime=`date "+%Y%m%d %H:%M:%S"`
        message="$1"
        printf "\033[1;92m%s\033[0m\n" "[$logtime #INFO] $message "|tee -a $scriptlog
}


installVBox() {
	
	infoLog "Mounting /media/cdrom"
	mount /dev/cdrom /media/cdrom

	infoLog "creating /common/shared/"	
	mkdir -v /common/shared/ -p

	infoLog "moving to /media/cdrom"
	cd /media/cdrom

	infoLog "Running VBoxLinuxAdditions.run"
	sh VBoxLinuxAdditions.run

	infoLog "Rebooting $(hostname)"
	reboot

}

updateApt(){

	infoLog "creating backup of /etc/apt/sources.list"
	cp -iv /etc/apt/sources.list /etc/apt/sources.list_bckup 

	infoLog "Adding /etc/apt/sources.list"
	echo "deb cdrom:[Debian GNU/Linux 9.0.0 _Stretch_ - Official amd64 DVD Binary-1 20170617-13:08]/ stretch main"  > /etc/apt/sources.list
	echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
	echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
	echo "deb  http://deb.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list
	echo "deb-src  http://deb.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list
	echo "deb  http://deb.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list 
	echo "deb-src  http://deb.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list
	echo "deb http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list
	echo "deb-src http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list
	infoLog "/etc/apt/sources.list Updated!!!"

}

update(){
	
	infoLog "Update & Upgrade of apps"
	apt-get -y update && apt-get -y upgrade
	infoLog "Update & Upgrade of apps complete!!!"

}

installEssential(){

	infoLog "Installing vim dkms build-essential module-assistant dos2unix etc"
	apt-get -y install vim dkms build-essential module-assistant dos2unix net-tools git
	infoLog "Installing vim dkms build-essential module-assistant dos2unix complete!!!"

}

updateMOTD(){

	infoLog "Updating /etc/motd to $(hostname)"
	echo `hostname -f` > /etc/motd 

}

updateApt
update
installEssential
updateMOTD

read -p 'Insert VirtualBox Guest Addins [Y/N]: ' varVBox 

if [ "$varVBox"=="Y" ]; then
	installVBox
else
	infoLog "Please Try Again."
fi


mount -t vboxsf shared /common/shared/ 

