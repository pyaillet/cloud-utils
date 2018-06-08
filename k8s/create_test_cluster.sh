#!/bin/sh

gcloud container clusters create \
	--preemptible \
	--max-nodes 1 \
	--zone europe-west1-d \
	devoxx-lab 
