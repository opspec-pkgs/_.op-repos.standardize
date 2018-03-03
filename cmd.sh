#!/bin/sh

set -e

echo 'starting docker daemon as background process'
nohup dockerd \
--host=unix:///var/run/docker.sock \
--host=tcp://0.0.0.0:2375 \
--storage-driver=overlay2 &

# poll for docker daemon up
max_retries=2
n=0
until [ $n -ge $max_retries ]
do
  docker ps > /dev/null 2>&1 && break
  n=$((n+1))
  sleep 3
done

if [ "$n" -eq "$max_retries" ]; then
  # assume failed
  cat nohup.out
  exit 1
fi

apk add -U jq

jq -r -c '.[]' /repoNames | while read i; do
  [ "$i" == "project" ] && continue

  export repoName="$i"
  echo $i
  mkdir -p /srcDir/$i
  cd /srcDir/$i
  opctl run /standardize-repo || true
done