#!/bin/bash
source ./env.sh

docker build --build-arg DISPLAY=$x_display:0.0 -t $image .
if test -d //s-bcc-nas2/groups/Common\ Projects/HB/dockerhub_images/ ;
then
    echo "Found Canmet folder."
    echo "Saving Image to Canmet folder $canmet_server_folder"
	docker save -o //s-bcc-nas2/groups/Common\ Projects/HB/dockerhub_images/BTAP-DE_$os_version.img $image
fi

