#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

export VMBOX_IMAGE=debian/buster64

vagrant up

ansible-playbook -i environments/test/inventory playbooks/openmediavault.yml
