#!/bin/bash
source ./env.sh
container=$1
if [ $machine == "MinGw" ]
then
	echo Windows users $win_user was detected.
	echo using  X server at this IP $x_display .
	echo podman create -ti -e DISPLAY=$x_display -P -v//c/Users/$win_user:$linux_home_folder/windows-host --name $container $image
	podman create -ti -e DISPLAY=$x_display -P -v//c/Users/$win_user:$linux_home_folder/windows-host --name $container $image
elif [ $machine == "Linux" ]
then 
	echo Linux home folder $HOME was detected.
	command="docker create -ti -e DISPLAY=$x_display -v/$HOME:$linux_home_folder/linux-host -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:$linux_home_folder/.Xauthority --net=host --name $container $image"
	echo $command
	$command
	 echo X server DISPLAY is  $x_display

	
fi
echo Container has been deleted if it existed,  and recreated from last image.
