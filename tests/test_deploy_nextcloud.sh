#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

vagrant up

ansible-playbook -i environments/test/inventory playbooks/nextcloud.yml -l nextcloud_host

wait_service "http://$vmbox1:8088/" nextcloud
