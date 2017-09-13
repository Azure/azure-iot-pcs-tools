#!/bin/bash

set -x

DEST="/app"
START="${DEST}/start.sh"
STOP="${DEST}/stop.sh"
UPDATE="${DEST}/update.sh"
LOGS="${DEST}/logs.sh"
SIMULATE="${DEST}/simulate.sh"

CERTS="${DEST}/certs"
CERT="${CERTS}/tls.crt"
PKEY="${CERTS}/tls.key"

export HOST_NAME="${1:-localhost}"
export APP_RUNTIME="${3:-dotnet}"
export PCS_AUTH_AAD_GLOBAL_TENANTID="$5"
export PCS_AUTH_AAD_GLOBAL_CLIENTID="$6"
export PCS_AUTH_AAD_GLOBAL_LOGINURI="$7"
export PCS_IOTHUB_CONNSTRING="$8"
export PCS_STORAGEADAPTER_DOCUMENTDB_CONNSTRING="$9"
export PCS_DEVICETELEMETRY_DOCUMENTDB_CONNSTRING="$9"
export PCS_STREAMANALYTICS_DOCUMENTDB_CONNSTRING="$9"
export PCS_IOTHUBREACT_ACCESS_CONNSTRING="$8"
export PCS_IOTHUBREACT_HUB_NAME="${10}"
export PCS_IOTHUBREACT_HUB_ENDPOINT="${11}"
export PCS_IOTHUBREACT_HUB_PARTITIONS="${12}"
export PCS_IOTHUBREACT_AZUREBLOB_ACCOUNT="${13}"
export PCS_IOTHUBREACT_AZUREBLOB_KEY="${14}"
export PCS_CERTIFICATE="${15}"
export PCS_CERTIFICATE_KEY="${16}"

# ========================================================================

# Install Docker engine based on host name if it is not installed.
function install_docker() {
    set +e
    local host_name=$1

    TEST=$(which docker)
    if [[ ! -z "$TEST" ]]; then
        return;
    fi

    if [[ $host_name =~ ..*cn ]]; then
        # If the host name has .cn suffix, dockerhub in China will be used to avoid slow network traffic failure.
        echo "Install Docker engine with China mirror option"
        curl -ksSL https://get.docker.com/ | sh -s -- --mirror AzureChinaCloud
        # Setup China docker hub registry mirrors and restart docker engine service
        local daemon_file='/etc/docker/daemon.json'
        echo "{\"registry-mirrors\": [\"https://registry.docker-cn.com\"]}" > ${daemon_file}
        service docker restart
    else
        echo "Install Docker engine from official website"
        curl -ksSL https://get.docker.com/ | sh -s
    fi
    set -e
}

install_docker $HOST_NAME

COMPOSEFILE="https://raw.githubusercontent.com/Azure/azure-iot-pcs-tools/master/remote-monitoring/docker-compose.${APP_RUNTIME}.yml"

# ========================================================================

mkdir -p ${DEST}
cd ${DEST}
touch ${START} && chmod 750 ${START}
touch ${STOP} && chmod 750 ${STOP}
touch ${UPDATE} && chmod 750 ${UPDATE}
touch ${LOGS} && chmod 750 ${LOGS}
touch ${SIMULATE} && chmod 750 ${SIMULATE}
wget $COMPOSEFILE -O ${DEST}/docker-compose.yml

mkdir -p ${CERTS}
touch ${CERT} && chmod 550 ${CERT}
touch ${PKEY} && chmod 550 ${PKEY}
# ========================================================================

# Always have quotes around the certificate and key value to preserve the formatting
echo "${PCS_CERTIFICATE}"                                                                                  >> ${CERT}
echo "${PCS_CERTIFICATE_KEY}"                                                                              >> ${PKEY}

# ========================================================================

echo "export HOST_NAME=\"${HOST_NAME}\""                                                                 >> ${START}
echo "export APP_RUNTIME=\"${APP_RUNTIME}\""                                                             >> ${START}
echo "export PCS_AUTH_AAD_GLOBAL_TENANTID=\"${PCS_AUTH_AAD_GLOBAL_TENANTID}\""                           >> ${START}
echo "export PCS_AUTH_AAD_GLOBAL_CLIENTID=\"${PCS_AUTH_AAD_GLOBAL_CLIENTID}\""                           >> ${START}
echo "export PCS_AUTH_AAD_GLOBAL_LOGINURI=\"${PCS_AUTH_AAD_GLOBAL_LOGINURI}\""                           >> ${START}
echo "export PCS_IOTHUB_CONNSTRING=\"${PCS_IOTHUB_CONNSTRING}\""                                         >> ${START}
echo "export PCS_STORAGEADAPTER_DOCUMENTDB_CONNSTRING=\"${PCS_STORAGEADAPTER_DOCUMENTDB_CONNSTRING}\""   >> ${START}
echo "export PCS_DEVICETELEMETRY_DOCUMENTDB_CONNSTRING=\"${PCS_DEVICETELEMETRY_DOCUMENTDB_CONNSTRING}\"" >> ${START}
echo "export PCS_STREAMANALYTICS_DOCUMENTDB_CONNSTRING=\"${PCS_STREAMANALYTICS_DOCUMENTDB_CONNSTRING}\"" >> ${START}
echo "export PCS_IOTHUBREACT_ACCESS_CONNSTRING=\"${PCS_IOTHUBREACT_ACCESS_CONNSTRING}\""                 >> ${START}
echo "export PCS_IOTHUBREACT_HUB_NAME=\"${PCS_IOTHUBREACT_HUB_NAME}\""                                   >> ${START}
echo "export PCS_IOTHUBREACT_HUB_ENDPOINT=\"${PCS_IOTHUBREACT_HUB_ENDPOINT}\""                           >> ${START}
echo "export PCS_IOTHUBREACT_HUB_PARTITIONS=\"${PCS_IOTHUBREACT_HUB_PARTITIONS}\""                       >> ${START}
echo "export PCS_IOTHUBREACT_AZUREBLOB_ACCOUNT=\"${PCS_IOTHUBREACT_AZUREBLOB_ACCOUNT}\""                 >> ${START}
echo "export PCS_IOTHUBREACT_AZUREBLOB_KEY=\"${PCS_IOTHUBREACT_AZUREBLOB_KEY}\""                         >> ${START}
echo                                                                >> ${START}
echo "cd ${DEST}"                                                   >> ${START}
echo                                                                >> ${START}
echo 'list=$(docker ps -aq)'                                        >> ${START}
echo 'if [ -n "$list" ]; then'                                      >> ${START}
echo '    docker rm -f $list'                                       >> ${START}
echo 'fi'                                                           >> ${START}
echo 'rm -f nohup.out'                                              >> ${START}
echo                                                                >> ${START}
echo 'nohup docker-compose up &'                                    >> ${START}
echo                                                                >> ${START}
echo 'ISUP=$(curl -s http://localhost/ | grep -i "html" | wc -l)'   >> ${START}
echo 'while [[ "$ISUP" == "0" ]]; do'                               >> ${START}
echo '  echo "Waiting for web site to start..."'                    >> ${START}
echo '  sleep 3'                                                    >> ${START}
echo '  ISUP=$(curl -s http://localhost/ | grep -i "html" | wc -l)' >> ${START}
echo 'done'                                                         >> ${START}

# ========================================================================

echo 'cd /app'                                                                                                                         >> ${SIMULATE}
echo                                                                                                                                   >> ${SIMULATE}
echo 'echo "Starting simulation..."'                                                                                                   >> ${SIMULATE}
echo 'ISUP=$(curl -s http://localhost/devicesimulation/v1/status | grep "Alive" | wc -l)'                                              >> ${SIMULATE}
echo 'while [[ "$ISUP" == "0" ]]; do'                                                                                                  >> ${SIMULATE}
echo '  echo "Waiting for simulation service to be available..."'                                                                      >> ${SIMULATE}
echo '  sleep 4'                                                                                                                       >> ${SIMULATE}
echo '  ISUP=$(curl -s http://localhost/devicesimulation/v1/status | grep "Alive" | wc -l)'                                            >> ${SIMULATE}
echo 'done'                                                                                                                            >> ${SIMULATE}
echo 'curl -s -X POST "http://localhost/devicesimulation/v1/simulations?template=default" -H "content-type: application/json" -d "{}"' >> ${SIMULATE}
echo 'echo'

# ========================================================================

echo 'list=$(docker ps -aq)'   >> ${STOP}
echo 'if [ -n "$list" ]; then' >> ${STOP}
echo '    docker rm -f $list'  >> ${STOP}
echo 'fi'                      >> ${STOP}

# ========================================================================

echo "cd ${DEST}"                                                 >> ${UPDATE}
echo                                                              >> ${UPDATE}
echo './stop.sh'                                                  >> ${UPDATE}
echo                                                              >> ${UPDATE}
echo 'docker pull azureiotpcs/remote-monitoring-nginx:latest'     >> ${UPDATE}
echo 'docker pull azureiotpcs/pcs-remote-monitoring-webui:latest' >> ${UPDATE}
echo 'docker pull azureiotpcs/device-telemetry-java:latest'       >> ${UPDATE}
echo 'docker pull azureiotpcs/device-telemetry-dotnet:latest'     >> ${UPDATE}
echo 'docker pull azureiotpcs/pcs-storage-adapter-dotnet:latest'  >> ${UPDATE}
echo 'docker pull azureiotpcs/pcs-storage-adapter-java:latest'    >> ${UPDATE}
echo 'docker pull azureiotpcs/pcs-ui-config-dotnet:latest'        >> ${UPDATE}
echo 'docker pull azureiotpcs/pcs-ui-config-java:latest'          >> ${UPDATE}
echo 'docker pull azureiotpcs/iothub-manager-dotnet:latest'       >> ${UPDATE}
echo 'docker pull azureiotpcs/iothub-manager-java:latest'         >> ${UPDATE}
echo 'docker pull azureiotpcs/pcs-auth-dotnet:latest'             >> ${UPDATE}
echo 'docker pull azureiotpcs/iot-stream-analytics-java:latest'   >> ${UPDATE}
echo 'docker pull azureiotpcs/device-simulation-dotnet:latest'    >> ${UPDATE}
echo                                                              >> ${UPDATE}
echo './start.sh'                                                 >> ${UPDATE}

# ========================================================================

echo "cd ${DEST}"          >> ${LOGS}
echo 'docker-compose logs' >> ${LOGS}

# ========================================================================

nohup ${START} &
