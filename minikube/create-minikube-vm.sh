#!/bin/sh

gcloud compute instances create minikube \
	--preemptible \
	--zone $ZONE \
	--image-project ubuntu-os-cloud \
	--image-family ubuntu-1804-lts \
	--metadata-from-file startup-script=minikube-install.sh

