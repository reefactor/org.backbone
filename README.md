# org.backbone

Collection of [ansible](https://www.ansible.com/) playbooks for most popular IT infastructure tools
ready for [deploy and maintainance](https://en.wikipedia.org/wiki/Infrastructure_as_code).

Bootstrap from zero to playground in 30 minutes with automated [vagrant tests](tests).

Build your own team IT infrastructure with ~blackjack~ encrypted private cloud, messenger, VPN and GitLab.


### Features

##### Collaboration

* Private [team cloud](tests/test_deploy_teamcloud.sh): sharing documents, encrypted file storage, mobile app, messenger powered by [nextcloud](https://nextcloud.com/)
* [GitLab CE](tests/test_deploy_gitlab.sh) on docker based on [sameersbn's pack](https://github.com/sameersbn/docker-gitlab)
* Continuous integration with [gitlab-runner](roles/gitlab-runner/tasks/main.yml)

##### Infrastructure

* Distribution server [storage and docker registry](roles/distribution_hub) based on [Nexus Repository Manager 3](https://github.com/sonatype/docker-nexus3)
behind [nginx for SSL termination](roles/nginx)
* [Infrastructure monitoring & alerting](tests/test_deploy_monitoring.sh) with [collectd collector](roles/collectd_beacon), [Graphite storage and Grafana viz UI](roles/monitoring_hub/files/docker-grafana-graphite/README.md) based on [kamon](https://github.com/kamon-io/docker-grafana-graphite)
* BIND DNS server bundled with the Webmin UI based on [sameersbn's docker-bind](https://github.com/sameersbn/docker-bind)

###### Privacy
* [OpenVPN](tests/test_deploy_openvpn.sh) and [keys management](environments/test/group_vars/openvpn) based on [Stouts.openvpn ansible role](https://github.com/Stouts/Stouts.openvpn/)

###### Security
* [SSH users ACL and management](tests/test_deploy_users.sh) with public ssh keys and common sudoer user

.. and more in the [roadmap](#roadmap)


### Prerequisites

* Python to run ansible playbooks
* Vagrant with Virtualbox is optional for automated testing sandbox
```bash
apt install python3-pip
pip3 install -r requirements.txt
ansible-galaxy install -r requirements.yml
curl -O https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb
dpkg -i vagrant_2.2.9_x86_64.deb
apt install virtualbox
```

### HOW-TO

#### VPN how to 
##### Setup openvpn server  
```bash
ansible-playbook playbooks/openvpn-server.yml
```

##### Add host to VPN network
1. Add *newhost* into list of **openvpn_clients** and **openvpn_server_clients** in [environments/test/group_vars/openvpn-server](environments/test/group_vars/openvpn-server) file
2. Add *newhost* credentials to the **openvpn-client** group of [environments/test/inventory](environments/test/inventory) file.

3. Update OpenVPN server (generate keys for client) and download:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml
```
4. Install openvpn client on *newhost*:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-client.yml --limit openvpn-server,newhost
```

##### Add user to VPN network
1. Add *newuser* to openvpn_server_clients list of environments/test/group_vars/openvpn-server file.
2. Update OpenVPN server (generate keys for client) and download:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml
ansible-playbook -i environments/test/inventory playbooks/openvpn-client.yml
ls -l ./vpnkeys/newuser.zip
```

##### Revoke VPN access
1. Add *bad_client_name* into openvpn_clients_revoke blacklist of environments/test/group_vars/openvpn-server file.
2. Update OpenVPN server:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml --limit openvpn-server
```


##### Add ssh user

* put user's public ssh key into `roles/users/files` (or download via `roles/users/files/update_pub_keys.sh`)
* add pub key file to `Add users` list of `roles/users/tasks/main.yml`
* add to `authorized_key` lists of `roles/users/tasks/main.yml`
* update environment:
```bash
ansible-playbook playbooks/users.yml
```

##### Remove ssh user

* delete user's public ssh key file from `roles/users/files`
* add to blacklist `Delete users` of `roles/users/tasks/main.yml`
* remove from `authorized_key` list
* update environment:
```bash
ansible-playbook playbooks/users.yml
```


#### Monitoring how to

1. Deploy example in vagrant vbox with [test_deploy_monitoring.sh](tests/test_deploy_monitoring.sh)

2. Open Grafana UI in [https://192.168.10.101:82](https://192.168.10.101:82/) with login *admin* and password *admin* configured in [docker-compose.yml](roles/monitoring_hub/files/docker-grafana-graphite/docker-compose.yml)


#### DNS how to

```bash
ansible-playbook -i environments/test/inventory playbooks/dns.yml -l dns
```

1. Deploy example in vagrant vbox with [test_deploy_dns.sh](tests/test_deploy_dns.sh)

2. Open Webmin UI in [https://192.168.10.101:10000](https://192.168.10.101:10000/) with *root* password *secretpassword* configured in [docker-compose.yml](roles/dns/files/docker-compose.yml)


### Roadmap

* Provisioning with Terraform in addition to Vagrant
* Errors tracking with [Sentry](https://sentry.io/) 
* Logging & analytics with Elastic & Kibana
* Automate SSL certs with certbot (with https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx)
* Scheduled backup jobs
* Replace Graphite with M3DB or Prometheus
* Update Stouts.openvpn 2.4.0 -> 2.4.1
* Upgrade iptables_raw
