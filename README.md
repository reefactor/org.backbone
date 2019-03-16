# org.backbone

Build your own team IT infrastructure with blackjack OpenVPN and GitLab CI.

Build & maintain [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code) 
in [ansible](https://www.ansible.com/) playbooks.

 
### Features
* [OpenVPN](roles/openvpn-base/tasks/main.yml) and [keys management](environments/test/group_vars/openvpn-server) based on [Stouts.openvpn ansible role](https://github.com/Stouts/Stouts.openvpn/)
* [SSH users ACL and management](roles/users/tasks/main.yml) via pub ssh keys and common sudoer user
* [GitLab CE](roles/gitlab-server/templates/docker-compose.yml.j2) on docker based on [sameersbn's pack](based on https://github.com/sameersbn/docker-gitlab)
* [gitlab-runner](roles/gitlab-runner/tasks/main.yml) for GitLab CI
* TODO: DNS, monitoring and many more in [roadmap](#Roadmap)


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

### Use cases
_From zero to production in 30 minutes or less_

Target OS for deployment - debian based linux.

#### VPN 
##### Setup openvpn server  
```bash
ansible-playbook playbooks/openvpn-server.yml
```

##### Add host to VPN network
1. Add *newhost* into **openvpn_clients** and **openvpn_server_clients** lists of environments/test/group_vars/openvpn-server file.
2. Add *newhost* credentials to the **openvpn-client** group of [environments/test/inventory]() file.
Update OpenVPN server (generate keys for client):
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml
```
3 . Install openvpn client on *newhost*:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-client.yml --limit openvpn-server,newhost
```

##### Add user to VPN network
1. Add *newuser* to openvpn_server_clients list of environments/test/group_vars/openvpn-server file.
2. Update OpenVPN server (generate keys for client) and download:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml
ansible-playbook -i environments/test/inventory playbooks/openvpn-client.yml
ls -l /tmp/newuser.zip
```

##### Revoke VPN access
1. Add *bad_client_name* into openvpn_clients_revoke blacklist of environments/test/group_vars/openvpn-server file.
2. Update OpenVPN server:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml --limit openvpn-server
```


#### Users
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

### Tests

```bash
tests/test_deploy_openvpn.sh
tests/test_deploy_users.sh
tests/test_deploy_gitlab.sh
```

### Roadmap

#### TODO

* DNS
* Monitoring infrastructure with collectd & Graphite, Grafana, Sentry
* Provisioning with Terraform in addition to Vagrant
* Logging & analytics for public services with elastic & kibana
* Artifacts storage with Nexus repository manager 3
* Scheduled backup jobs
* Replace Graphite with M3DB
* Team messenger
* Update Stouts.openvpn 2.4.0 -> 2.4.1
* Upgrade ansible 2.3.0 -> latest
* Upgrade iptables_raw
