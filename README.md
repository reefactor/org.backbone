# org.backbone

Build your own team IT infrastructure with blackjack OpenVPN and GitLab CI.

Deploy and maintain [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code) 
in [ansible](https://www.ansible.com/) playbooks.

 
### Features
* **Privacy:** [OpenVPN](roles/openvpn-base/tasks/main.yml) and [keys management](environments/test/group_vars/openvpn-server) based on [Stouts.openvpn ansible role](https://github.com/Stouts/Stouts.openvpn/)
* **Security:** [SSH users ACL and management](roles/users/tasks/main.yml) via pub ssh keys and common sudoer user
* **Collaboration:** [GitLab CE](roles/gitlab-server/templates/docker-compose.yml.j2) on docker based on [sameersbn's pack](https://github.com/sameersbn/docker-gitlab)
* **Continuous integration:** [gitlab-runner](roles/gitlab-runner/tasks/main.yml) for GitLab CI
* **Monitoring & alerting:** [Infrastructure monitoring](roles/monitoring_hub) with [collectd collector](roles/collectd_beacon), [Graphite storage and Grafana viz UI](roles/monitoring_hub/files/docker-grafana-graphite/README.md) based on [kamon](https://github.com/kamon-io/docker-grafana-graphite)
* **Frontend:** [to public web via TLS termination proxy based on nginx](roles/nginx)
* **Distribution server:** [storage for build artifacts and docker registry](roles/distribution_hub) based on [Nexus Repository Manager 3](https://github.com/sonatype/docker-nexus3)
* **DNS server**. BIND DNS server bundled with the Webmin UI based on [sameersbn's docker-bind](https://github.com/sameersbn/docker-bind)
* .. and many more in the [roadmap](#roadmap)


### Prerequisites

* Python to run ansible playbooks
* Vagrant with Virtualbox for automated testing sandbox
```bash
pip install -r requirements.txt
ansible-galaxy install -r requirements.yml
curl -O https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.deb
dpkg -i vagrant_2.2.4_x86_64.deb
apt install virtualbox
```

### HOW-TO
_From zero to production in 30 minutes or less_

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


#### Users how to
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


### Tests

See [vagrant tests](tests) of example use cases


### Roadmap

* Provisioning with Terraform in addition to Vagrant
* Errors tracking with [Sentry](https://sentry.io/) 
* Logging & analytics with Elastic & Kibana
* Automate SSL certs with certbot (with https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx)
* Scheduled backup jobs
* Replace Graphite with M3DB
* Team messenger (alerts sink from grafana)
* Update Stouts.openvpn 2.4.0 -> 2.4.1
* Upgrade ansible 2.3.0 -> latest
* Upgrade iptables_raw
