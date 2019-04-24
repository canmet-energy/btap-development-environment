#!/bin/bash
os_version=2.8.0
image=canmet/btap-development-environment:$os_version
canmet_server_folder=//s-bcc-nas2/Groups/Common\ Projects/HB/dockerhub_images/
x_folder=nothing

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${machine}


if [ $machine == "MinGw" ]
then
	if [ -d "/c/Program Files/Xming/" ]
	then
		x_folder='/c/Program Files/Xming/'
	elif [ -d "/c/Program Files (x86)/Xming/" ]
	then
		x_folder="/c/Program Files (x86)/Xming/"
	else
		echo "Could not find Xming installed on your system either /c/Program Files/Xming or /c/Program Files (x86)/Xming  . Please install Xming, ideally the donation version in the default location." 
		exit
	fi
	
	#Check if X server is running. 
	if [ "`ps | grep Xming`" == "" ]
	then
		"${x_folder}"Xming.exe -ac -multiwindow -clipboard  -dpi 108 &
	fi
	#find candidate Ip addresses for X server. 
	host_name=$(ipconfig //all | grep -m 1 "Host Name" | awk '{print $NF}')
	domain=$(ipconfig //all | grep -m 1 "Primary Dns Suffix" | awk '{print $NF}')
	host_name_domain=$host_name.$domain:0.0
	host_ip_1=$(wmic NICCONFIG WHERE DHCPEnabled=true Get IPAddress | gawk 'match($0,  /^{"(.*)",.*"}/, a) { print a[1] }' |  sed -n 1p):0.0
	host_ip_2=$(wmic NICCONFIG WHERE DHCPEnabled=true Get IPAddress | gawk 'match($0,  /^{"(.*)",.*"}/, a) { print a[1] }' |  sed -n 2p):0.0
	DISPLAY=$host_name_domain "${x_folder}"xset.exe q
	if [ $? -eq 0 ]
	then
		echo "Found Suitable IP address for Xserver and Docker $host_name_domain"
		x_display=$host_name_domain
	else
		DISPLAY=$host_ip_1 "${x_folder}"xset.exe q
		if [ $? -eq 0 ]
		then
			echo "Found Suitable IP address for Xserver and Docker $host_ip_1"
			x_display=$host_ip_1
		else
			DISPLAY=$host_ip_2 "${x_folder}"xset.exe q
			if [ $? -eq 0 ]
			then
				echo "Found Suitable IP address for Xserver and Docker $host_ip_2"
				x_display=$host_ip_2
			fi
		fi
	fi
	if [ -z "$x_display" ] 
	then 
		echo "Could not determine suitable Xserver...X will not be availble for the container on this system."
	fi
	

	#set your DISPLAY to what it should be
	export DISPLAY=$x_display
elif [ $machine == "Linux" ]
	then
	if [[ -z "${DISPLAY}" ]] 
	then
		echo "DISPLAY env variable is not set up for your linux environment. X may not be availble"
	else
		x_display=$DISPLAY
	fi
	if [ -n "$SSH_CLIENT" ]
	then
		echo found logging in through ssh. Will need to pass SSH client IP instead. 
		x_display=$(echo $SSH_CLIENT | awk '{ print $1}'):0
	fi
fi
linux_home_folder=/home/osdev

if [ "`whoami | grep +`" == "" ]
then
    win_user=$(whoami)
else
    # Specific case for Jeff's machine (whoami = W-BSC-A107313+jeffblake)!
	win_user=jeffblake
    x_display=$(ipconfig | grep -m 3 "IPv4" | tail -1 | awk '{print $NF}')
	export DISPLAY=$x_display:0.0
fi

echo "Windows User: $win_user"
echo "host_ip: $host_ip"
echo "Windows Hostname: $host_name"
echo "windows domain name: $domain"
echo "X server IP: $x_display"
echo "image name: $image"


