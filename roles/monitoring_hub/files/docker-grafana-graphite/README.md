Based on [https://github.com/kamon-io/docker-grafana-graphite](https://github.com/kamon-io/docker-grafana-graphite)


This image contains a sensible default configuration of StatsD, Graphite and Grafana
Based on (apache 2) [Kamon's repository on the Docker Hub](https://hub.docker.com/u/kamon/)

### Update graphite whisper storage retention

##### update config (will be applied to a new sources)

```
docker exec -it monitoring_hub vi /opt/graphite/conf/storage-schemas.conf
```
Read about `retentions` docs in https://graphite.readthedocs.io/en/latest/config-carbon.html)  

#### resize existing log data (optional)

```
docker exec -it monitoring_hub bash
find /opt/graphite/storage/whisper -type f -name '*.wsp' -exec whisper-resize.py --nobackup {} 10s:7d 5m:30d 15m:1y \;
```

See other examples at https://gist.github.com/kirbysayshi/1389254


### Build docker ###


- `80`: the Grafana web UI.
- `81`: the Graphite web UI
- `2003`: the Graphite data port
- `8125`: the StatsD port.
- `8126`: the StatsD administrative port.

To start a container with this image you just need to run the following command:

```bash
$ make up
```

To stop the container
```bash
$ make down
```

To run container's shell
```bash
$ make shell
```

To view the container log
```bash
$ make tail
```

If you already have services running on your host that are using any of these ports, you may wish to map the container
ports to whatever you want by changing left side number in the `--publish` parameters. You can omit ports you do not plan to use. Find more details about mapping ports in the Docker documentation on [Binding container ports to the host](https://docs.docker.com/engine/userguide/networking/default_network/binding/) and [Legacy container links](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/).

### Persisted Data ###

When running `make up`, directories are created on your host and mounted into the Docker container, allowing graphite and grafana to persist data and settings between runs of the container.
