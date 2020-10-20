#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/base.sh

vagrant destroy -f
vagrant up

$DIR/test_deploy_users.sh
$DIR/test_deploy_openvpn.sh
$DIR/test_deploy_dns.sh
$DIR/test_deploy_distribution_hub.sh
$DIR/test_deploy_nextcloud.sh
$DIR/test_deploy_monitoring.sh

# TODO fix build
# ssh -o StrictHostKeyChecking=no vagrant@$vmbox1 "sudo service nginx stop"
# $DIR/test_deploy_gitlab.sh
