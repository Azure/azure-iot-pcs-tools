#!/bin/bash -e

cd /app

echo "Starting simulation..."
ISUP=$(curl -sk https://localhost/devicesimulation/v1/status | grep "Alive" | wc -l)
while [[ "$ISUP" == "0" ]]; do
  echo "Waiting for simulation service to be available..."
  sleep 4
  ISUP=$(curl -sk https://localhost/devicesimulation/v1/status | grep "Alive" | wc -l)
done
curl -sk -X POST "https://localhost/devicesimulation/v1/simulations?template=default" -H "content-type: application/json" -d "{}"
echo
