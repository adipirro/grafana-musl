VERSION = v3.1.0-beta1
STATIC = true

all: clean build extract

build: builder
	$(info ==> Building Grafana. Distribution will be in /dist directory of grafana-musl-$(VERSION) container)
	docker run -i -t --name grafana-musl-$(VERSION) -e GRAFANA_VERSION=$(VERSION) -e STATIC=$(STATIC) grafana-musl-builder

builder:
	$(info ==> Making builder image)
	docker build -q --force-rm --tag grafana-musl-builder .

extract:
	$(info ==> Extracting grafana distribution to local filesystem)
	docker cp grafana-musl-$(VERSION):/dist ./dist

clean: clean-dangling
	$(info ==> Removing build containers and builder image)
	$(eval BUILDS := $(shell docker ps -a -q -f "name=grafana-musl-*"))
	$(if $(BUILDS), docker rm -f $(BUILDS))
	$(eval BUILDER := $(shell docker images -q grafana-musl-builder))
	$(if $(BUILDER), docker rmi -f $(BUILDER))
	rm -rf dist

clean-dangling:
	$(info ==> Removing dangling images)
	$(eval DANGLING := $(shell docker images -q -f dangling=true))
	$(if $(DANGLING), docker rmi $(DANGLING))

.PHONY: all build builder clean clean-dangling extract
