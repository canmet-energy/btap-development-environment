#!/bin/bash
source ./env.sh
if [ $machine == "MinGw" ]
then
	echo using  windows X server at this IP $x_display
	echo starting $1
elif [ $machine == "Linux" ]
then
	echo using  linux/macos X server at this IP $x_display
fi
podman start  -ia  $1