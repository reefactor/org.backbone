#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

# create sandbox
vagrant up

# run playbook in vagrant sandbox
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml
ansible-playbook -i environments/test/inventory playbooks/openvpn-client.yml

# expect playbooks/openvpn-client.yml to download key files
if [[ ! -f /tmp/testvpnuser.zip ]]; then
    echo 'FAILED: key files not found'
    exit 1
fi
rm -r /tmp/*.zip

# wait network bootstrap
sleep 3

# check
ssh -o StrictHostKeyChecking=no vagrant@$vmbox2 "ping -c 3 -w 3 10.3.0.1"
if [ $? -ne 0 ]; then
    echo 'FAILED ping testvpnuser -> vpnserver'
    exit 1
fi

ssh -o StrictHostKeyChecking=no vagrant@$vmbox1 "ping -c 3 -w 3 10.3.0.2"
if [ $? -ne 0 ]; then
    echo 'FAILED ping vpnserver -> testvpnuser'
    exit 1
fi
