#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

# create sandbox
vagrant up

# cleanup
if [[ -e $DIR/.vpnkeys/test ]]; then
rm -rf $DIR/.vpnkeys/test
fi

# run playbook in vagrant sandbox
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml
# TODO FIXME openvpn service not starting until reboot
ssh -o StrictHostKeyChecking=no vagrant@$vmbox1 "bash -c 'sleep 2; sudo reboot' &"
sleep 20

# expect vpn keys downloaded
# see openvpn_clients_active in environments/test/group_vars/openvpn.yaml
for vpnusername in vpnhost_static vpnuser_laptop
do
  vpn_key_zip=$DIR/../.vpnkeys/test/${vpnusername}.zip
  if [[ ! -f $vpn_key_zip ]]; then
      echo "FAILED: not found $vpn_key_zip"
      exit 1
  fi
done

# deploy vpn keys
ansible-playbook -i environments/test/inventory playbooks/openvpn-client.yml


# check
# wait network bootstrap
sleep 3
ssh -o StrictHostKeyChecking=no vagrant@$vmbox2 "ping -c 3 -w 3 10.3.0.1"
if [ $? -ne 0 ]; then
    echo 'FAILED ping vpnhost_static -> vpnserver'
    exit 1
fi

ssh -o StrictHostKeyChecking=no vagrant@$vmbox1 "ping -c 3 -w 3 10.3.0.2"
if [ $? -ne 0 ]; then
    echo 'FAILED ping vpnserver -> vpnhost_static'
    exit 1
fi
