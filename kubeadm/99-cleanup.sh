#!/bin/sh

terraform destroy -auto-approve -state=lb.tfstate

terraform destroy -auto-approve -state=machines.tfstate

terraform destroy -auto-approve -state=address.tfstate