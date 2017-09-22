#!/bin/bash -e

cd /app

source "env-vars"

list=$(docker ps -aq)
if [ -n "$list" ]; then
    docker rm -f $list
fi
rm -f nohup.out

nohup docker-compose up &

ISUP=$(curl -ks https://localhost/ | grep -i "html" | wc -l)
while [[ "$ISUP" == "0" ]]; do
  echo "Waiting for web site to start..."
  sleep 3
  ISUP=$(curl -ks https://localhost/ | grep -i "html" | wc -l)
done