#!/bin/sh

NB=${1:-1}
MACHINES=$(seq -s ' ' -f "docker-%02g" 2)
echo $MACHINES

gcloud compute instances create $MACHINES \
	--preemptible \
	--zone $ZONE \
	--image-project ubuntu-os-cloud \
	--image-family ubuntu-1804-lts \
	--metadata-from-file startup-script=docker-install.sh

