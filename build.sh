#!/bin/sh
set -e

echo "==> Initializing variables"
export GRAFANA_VERSION="${GRAFANA_VERSION:=v2.6.0}"
export STATIC="${STATIC:=true}"
export GOPATH="/go"
export PATH="/go/bin:$PATH"

echo "==> Installing build dependencies"
apk add -q --no-cache --virtual=build-deps ca-certificates git go g++ make python nodejs

echo "==> Cloning sources"
git clone -q git://github.com/grafana/grafana.git ${GOPATH}/src/github.com/grafana/grafana
cd ${GOPATH}/src/github.com/grafana/grafana
git checkout -b ${GRAFANA_VERSION} ${GRAFANA_VERSION}

if [ "$STATIC" == "true" ]; then
  echo "==> Setting ldflags for static linking"
  sed -i "s/\"-w\"/\"-w -linkmode external -extldflags '-static'\"/g" build.go
fi

echo "==> Building binaries"
go run build.go setup
godep restore
go run build.go build

echo "==> Building assets"
npm install --no-optional
npm install --no-optional grunt-contrib-compress@1.3.0
$(npm bin)/grunt build build-post-process --force

echo "==> Striping binaries and phantomjs from distribution"
rm -rf tmp/vendor/phantomjs tmp/bin/*.md5
strip tmp/bin/*

echo "==> Building distribution"
$(npm bin)/grunt compress
mv dist /

echo "==> Cleaning up after build"
cd /
rm -rf /go /tmp/*
npm cache clean
apk del -q build-deps

echo "==> Build complete"
