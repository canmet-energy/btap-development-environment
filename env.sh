#!/bin/bash
os_version=3.3.0-alpha
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
    x_display='host.docker.internal:0.0'
	if [ -d "/c/Program Files/VcXsrv/" ]
	then
		x_folder='/c/Program Files/VcXsrv/'
	elif [ -d "/c/Program Files (x86)/VcXsrv/" ]
	then
		x_folder="/c/Program Files (x86)/VcXsrv/"
	else
		echo "Could not find VcXsrv installed on your system either /c/Program Files/VcXsrv or /c/Program Files (x86)/VcXsrv  . Please install VcXsrv, ideally the donation version in the default location." 
		exit
	fi
	
	#Check if X server is running. 
	if [ "`ps | grep VcXsrv`" == "" ]
	then
		"${x_folder}"VcXsrv.exe -ac -multiwindow -clipboard  -dpi 108 &
	fi

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
		x_display=$(echo $SSH_CLIENT | awk '{ print $1}'):0.0
	fi
fi
linux_home_folder=/home/osdev

echo "Windows User: $win_user"
echo "host_ip: $host_ip"
echo "Windows Hostname: $host_name"
echo "windows domain name: $domain"
echo "X server IP: $x_display"
echo "image name: $image"


