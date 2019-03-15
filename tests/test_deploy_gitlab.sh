#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

function wait_service()
{
    local timeout=30
    local url=$1
    local reply_keyword=$2
    while [[ $timeout -gt 0 ]]; do
        local response=$(curl -s -XGET "$url" | grep "$reply_keyword")
        if [ ! -z "$response" ]
        then
            echo FOUND $url
            return 0
        fi
        sleep 3
        (( timeout-- ))
        echo wait_service $url $timeout sec..
    done
    echo ERROR: $url is not responding
    return 1
}

# create
vagrant up

# deploy
ansible-playbook -i environments/test/inventory playbooks/gitlab-server.yml -l gitlab

# check
wait_service "http://$vmbox1/explore" GitLab

# TODO: fix wait long start gitlab first time (ruby,webpack,js..)
# ansible-playbook -i environments/test/inventory playbooks/gitlab-runner.yml -l gitlab-runner1
