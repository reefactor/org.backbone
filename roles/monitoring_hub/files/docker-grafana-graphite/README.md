Based on [https://github.com/kamon-io/docker-grafana-graphite](https://github.com/kamon-io/docker-grafana-graphite)


This image contains a sensible default configuration of StatsD, Graphite and Grafana
Based on (apache 2) [Kamon's repository on the Docker Hub](https://hub.docker.com/u/kamon/)

#### Update graphite whisper storage retention

##### update config (will be applied to a new sources)

```
docker exec -it monitoring_hub vi /opt/graphite/conf/storage-schemas.conf
```
Read about `retentions` docs in https://graphite.readthedocs.io/en/latest/config-carbon.html)  

##### resize existing log data (optional)

```
docker exec -it monitoring_hub
    find /opt/graphite/storage/whisper -type f -name '*.wsp' -exec whisper-resize.py --nobackup {} 10s:30d 5m:90d 30m:5y \;
```

```bash
docker exec -it monitoring_hub sudo supervisorctl restart carbon-cache
docker exec -it monitoring_hub sudo supervisorctl status 
```

See [other retention update examples](https://gist.github.com/kirbysayshi/1389254)


#### Ports exposed by [docker-compose.yml]() ###


- `80`: the Grafana web UI.
- `81`: the Graphite web UI
- `2003`: the Graphite data port
- `8125`: the StatsD port.
- `8126`: the StatsD administrative port.

