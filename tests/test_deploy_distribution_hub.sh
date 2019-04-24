#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

# create
vagrant up

ansible-playbook -i environments/test/inventory playbooks/distribution-hub.yml -l distribution-hub
