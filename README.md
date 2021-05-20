# org.backbone

Collection of [ansible](https://www.ansible.com/) playbooks for most popular IT infastructure tools
ready for [deploy and maintainance](https://en.wikipedia.org/wiki/Infrastructure_as_code).

Bootstrap from zero to playground in 30 minutes with automated [vagrant tests](tests).

Build your own team IT infrastructure with ~blackjack~ encrypted private cloud, messenger, VPN and GitLab.


### Features

##### Collaboration

* Encrypted file storage, sharing, mobile app, messenger powered by [nextcloud](https://nextcloud.com/)
* [GitLab CE](tests/test_deploy_gitlab.sh) on docker based on [sameersbn's pack](https://github.com/sameersbn/docker-gitlab)
* Continuous integration with [gitlab-runner](roles/gitlab-runner/tasks/main.yml)

##### Infrastructure

* Software distribution server [storage and docker registry](roles/distribution_hub) based on [Nexus Repository Manager 3](https://github.com/sonatype/docker-nexus3)
behind [nginx for SSL termination](roles/nginx)
* Media [server](playbooks/openmediavault.yml) from [openmediavault.org](https://www.openmediavault.org)
* [Infrastructure monitoring & alerting](tests/test_deploy_monitoring.sh) with [Grafana + Prometheus](roles/monitoring_hub/files) and [collectd](roles/collectd_beacon) 
based on [dockprom](https://github.com/stefanprodan/dockprom)
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

#### VPN
```bash
ansible-playbook playbooks/openvpn-server.yml
```

##### Add user key to VPN

See example test [test_deploy_openvpn.sh](tests/test_deploy_openvpn.sh)

1. Add `username` entry into list of **openvpn_clients_active** in [environments/test/group_vars/openvpn](environments/test/group_vars/openvpn).
Client may reserve static VPN IP or dynamic otherwise.


2. Generate OpenVPN server keys for client:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-server.yml
```
VPN keys are now downloaded to local dir `./.vpnkeys/test`.

Encrypt zip with strong key and send username.7z and the password via separate channels.
```bash
ls -l ./.vpnkeys/test/
7za a -p${ATLEAST16SYMBOLS_PASSWORD} -mhe=on vpnkeys/username.7z vpnkeys/username.zip
```

3. Deploy client keys (add host to VPN network)

Add target host VM to **openvpn_clients_group**, tag it with `openvpn_client_name=username` variable and run playbook:
```bash
ansible-playbook -i environments/test/inventory playbooks/openvpn-client.yml
```

##### Revoke VPN key
1. Add client's name into `openvpn_clients_revoke` blacklist of [environments/test/inventory](environments/test/inventory).
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


#### Monitoring

1. Deploy example in vagrant vbox with [tests/test_deploy_monitoring.sh](tests/test_deploy_monitoring.sh)

2. Open Grafana UI in [http://192.168.10.101:3000](http://192.168.10.101:3000/) with login *admin* and password *admin* configured in [docker-compose.yml](roles/monitoring_hub/files/dockprom/docker-compose.yml)


#### DNS

```bash
ansible-playbook -i environments/test/inventory playbooks/dns.yml -l dns
```

1. Deploy example in vagrant vbox with [test_deploy_dns.sh](tests/test_deploy_dns.sh)

2. Open Webmin UI in [https://192.168.10.101:10000](https://192.168.10.101:10000/) with *root* password *secretpassword* configured in [docker-compose.yml](roles/dns/files/docker-compose.yml)


### Roadmap

* Provisioning with Terraform in addition to Vagrant
* Errors tracking with [Sentry](https://sentry.io/) 
* Automate SSL certs with certbot (with https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx)


#### Tools

##### TCP tunnel with docker and socat

Use cases:
* Expose port from docker internal network via additional docker container with [sockat](https://wiki.ipfire.org/addons/socat) tunnel.
* tcp port forwarding from local to remote host

0.0.0.0:$HOSTPORT -> $TARGET_HOST:$TARGET_PORT (via socat on port 12345 in docker container named socat-tunnel)

* trivial command-line: [docat-tunnel/docker-run-socat.sh](./socat-tunnel/docker-run-socat.sh)
* convinient compose config: [socat-tunnel/docker-compose.yml](./socat-tunnel/docker-run-socat.sh)
