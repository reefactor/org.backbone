# Environment Varibles
CONTAINER = monitoring_hub

.PHONY: up

prep :
	mkdir -p \
		data/whisper \
		data/grafana \
		log/graphite \
		log/graphite/webapp

build :
	docker-compose build

up : prep build
	docker-compose up -d

down :
	docker-compose down

shell :
	docker exec -ti $(CONTAINER) /bin/bash

tail :
	docker logs -f $(CONTAINER)
