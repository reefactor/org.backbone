#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

# create
vagrant up

ansible-playbook -i environments/test/inventory playbooks/gitlab-server.yml

wait_service "http://$vmbox1/explore" GitLab

ansible-playbook -i environments/test/inventory playbooks/gitlab-runner.yml
