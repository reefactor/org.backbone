#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh


# run playbook in vagrant sandbox
vagrant up
ansible-playbook -i environments/test/inventory playbooks/users.yml

username=$(ssh -o StrictHostKeyChecking=no den@$vmbox1 whoami)
if [ $username != den ]; then
    echo "FAILED $username username check"
    exit 1
fi
