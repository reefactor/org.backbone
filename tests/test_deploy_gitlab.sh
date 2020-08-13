#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

# create
vagrant up

# deploy
ansible-playbook -i environments/test/inventory playbooks/gitlab-server.yml -l gitlab

# check
wait_service "http://$vmbox1/explore" GitLab

# TODO: fix wait long start gitlab first time (ruby,webpack,js..)
# ansible-playbook -i environments/test/inventory playbooks/gitlab-runner.yml -l gitlab-runner1
