#!/bin/bash
source ./env.sh
if test -d //s-bcc-nas2/groups/Common\ Projects/HB/dockerhub_images/ ;
then
    echo "Found Canmet folder."
    echo "Saving Image to Canmet folder $canmet_server_folder"
	docker save -o //s-bcc-nas2/groups/Common\ Projects/HB/dockerhub_images/$image.img $image
fi

