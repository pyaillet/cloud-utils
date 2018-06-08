#!/bin/sh

gcloud container clusters delete \
	--zone europe-west1-d \
	devoxx-lab
