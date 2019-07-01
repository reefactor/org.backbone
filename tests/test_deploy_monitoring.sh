#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

# create
vagrant up

# test playbooks
ansible-playbook -i environments/test/inventory playbooks/monitoring_hub.yml -l eye
ansible-playbook -i environments/test/inventory playbooks/monitoring_node.yml -l monitored

# ensure UI is available
wait_service "http://$vmbox1/login" "Grafana"
wait_service "http://$vmbox1:81" "Graphite Browser"

# TODO ensure graphite to ensure statsd metrics from 'beacon1' monitoring_node are present
