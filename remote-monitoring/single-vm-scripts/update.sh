#!/bin/bash -ex

# Where to download scripts from
SCRIPTS_REPO=https://raw.githubusercontent.com/Azure/azure-iot-pcs-tools/master/remote-monitoring/single-vm-scripts/

cd /app

# Stop the services, so Docker images are not in use
./stop.sh

# Update Docker images
docker pull azureiotpcs/device-simulation-dotnet:latest
docker pull azureiotpcs/iothub-manager-dotnet:latest
docker pull azureiotpcs/iothub-manager-java:latest
docker pull azureiotpcs/pcs-auth-dotnet:latest
docker pull azureiotpcs/pcs-config-dotnet:latest
docker pull azureiotpcs/pcs-config-java:latest
docker pull azureiotpcs/pcs-remote-monitoring-webui:latest
docker pull azureiotpcs/pcs-storage-adapter-dotnet:latest
docker pull azureiotpcs/pcs-storage-adapter-java:latest
docker pull azureiotpcs/remote-monitoring-nginx:latest
docker pull azureiotpcs/telemetry-agent-dotnet:latest
docker pull azureiotpcs/telemetry-agent-java:latest
docker pull azureiotpcs/telemetry-dotnet:latest
docker pull azureiotpcs/telemetry-java:latest

# Update scripts
wget $SCRIPTS_REPO/logs.sh     -O /app/logs.sh     && chmod 750 /app/logs.sh
wget $SCRIPTS_REPO/simulate.sh -O /app/simulate.sh && chmod 750 /app/simulate.sh
wget $SCRIPTS_REPO/start.sh    -O /app/start.sh    && chmod 750 /app/start.sh
wget $SCRIPTS_REPO/stop.sh     -O /app/stop.sh     && chmod 750 /app/stop.sh
wget $SCRIPTS_REPO/update.sh   -O /app/update.sh   && chmod 750 /app/update.sh

# Start the services
./start.sh