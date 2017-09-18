#!/bin/bash

set -x

DEST="/app"
START="${DEST}/start.sh"
STOP="${DEST}/stop.sh"
UPDATE="${DEST}/update.sh"
LOGS="${DEST}/logs.sh"
SIMULATE="${DEST}/simulate.sh"
WEBUICONFIG="${DEST}/webui-config.js"

CERTS="${DEST}/certs"
CERT="${CERTS}/tls.crt"
PKEY="${CERTS}/tls.key"

export HOST_NAME="${1:-localhost}"
export APP_RUNTIME="${3:-dotnet}"
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
export PCS_IOTHUBREACT_AZUREBLOB_ENDPOINT_SUFFIX="${15}"
export PCS_CERTIFICATE="${16}"
export PCS_CERTIFICATE_KEY="${17}"
export PCS_BINGMAP_KEY="${18}"
export PCS_AUTH_ISSUER="https://sts.windows.net/${5}/"
export PCS_AUTH_AUDIENCE="$6"
export PCS_WEBUI_AUTH_TYPE="aad"
export PCS_WEBUI_AUTH_AAD_TENANT="$5"
export PCS_WEBUI_AUTH_AAD_APPID="$6"
export PCS_APPLICATION_SECRET=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9-,./;:[]\(\)_=^!~' | fold -w 64 | head -n 1)

# ========================================================================

# Configure Docker registry based on host name.
config_docker() {
    set +e
    local host_name=$1
    if (echo $host_name | grep -c  "\.cn$") ; then
        # If the host name has .cn suffix, dockerhub in China will be used to avoid slow network traffic failure.
        local config_file='/etc/docker/daemon.json'
        echo "{\"registry-mirrors\": [\"https://registry.docker-cn.com\"]}" > ${config_file}
        service docker restart
    fi
    set -e
}

config_docker $HOST_NAME

COMPOSEFILE="https://raw.githubusercontent.com/Azure/azure-iot-pcs-tools/master/remote-monitoring/docker-compose.${APP_RUNTIME}.yml"

# ========================================================================

mkdir -p ${DEST}
cd ${DEST}
touch ${START} && chmod 750 ${START}
touch ${STOP} && chmod 750 ${STOP}
touch ${UPDATE} && chmod 750 ${UPDATE}
touch ${LOGS} && chmod 750 ${LOGS}
touch ${SIMULATE} && chmod 750 ${SIMULATE}
touch ${WEBUICONFIG} && chmod 444 ${WEBUICONFIG}
wget $COMPOSEFILE -O ${DEST}/docker-compose.yml

mkdir -p ${CERTS}
touch ${CERT} && chmod 550 ${CERT}
touch ${PKEY} && chmod 550 ${PKEY}
# ========================================================================

# Always have quotes around the certificate and key value to preserve the formatting
echo "${PCS_CERTIFICATE}"                                                                                  >> ${CERT}
echo "${PCS_CERTIFICATE_KEY}"                                                                              >> ${PKEY}

# ========================================================================

echo "#!/bin/bash"                                                                                       >> ${START}
echo "export HOST_NAME=\"${HOST_NAME}\""                                                                 >> ${START}
echo "export APP_RUNTIME=\"${APP_RUNTIME}\""                                                             >> ${START}
echo "export PCS_AUTH_ISSUER=\"${PCS_AUTH_ISSUER}\""                                                     >> ${START}
echo "export PCS_AUTH_AUDIENCE=\"${PCS_AUTH_AUDIENCE}\""                                                 >> ${START}
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
echo "export PCS_IOTHUBREACT_AZUREBLOB_ENDPOINT_SUFFIX=\"${PCS_IOTHUBREACT_AZUREBLOB_ENDPOINT_SUFFIX}\"" >> ${START}
echo "export PCS_BINGMAP_KEY=\"${PCS_BINGMAP_KEY}\""                                                     >> ${START}
echo "export PCS_APPLICATION_SECRET=\"${PCS_APPLICATION_SECRET}\""                                       >> ${START}
echo                                                                  >> ${START}
echo "cd ${DEST}"                                                     >> ${START}
echo                                                                  >> ${START}
echo 'list=$(docker ps -aq)'                                          >> ${START}
echo 'if [ -n "$list" ]; then'                                        >> ${START}
echo '    docker rm -f $list'                                         >> ${START}
echo 'fi'                                                             >> ${START}
echo 'rm -f nohup.out'                                                >> ${START}
echo                                                                  >> ${START}
echo 'nohup docker-compose up &'                                      >> ${START}
echo                                                                  >> ${START}
echo 'ISUP=$(curl -ks https://localhost/ | grep -i "html" | wc -l)'   >> ${START}
echo 'while [[ "$ISUP" == "0" ]]; do'                                 >> ${START}
echo '  echo "Waiting for web site to start..."'                      >> ${START}
echo '  sleep 3'                                                      >> ${START}
echo '  ISUP=$(curl -ks https://localhost/ | grep -i "html" | wc -l)' >> ${START}
echo 'done'                                                           >> ${START}

# ========================================================================

echo '#!/bin/bash'                                                                                                                       >> ${SIMULATE}
echo 'cd /app'                                                                                                                           >> ${SIMULATE}
echo                                                                                                                                     >> ${SIMULATE}
echo 'echo "Starting simulation..."'                                                                                                     >> ${SIMULATE}
echo 'ISUP=$(curl -sk https://localhost/devicesimulation/v1/status | grep "Alive" | wc -l)'                                              >> ${SIMULATE}
echo 'while [[ "$ISUP" == "0" ]]; do'                                                                                                    >> ${SIMULATE}
echo '  echo "Waiting for simulation service to be available..."'                                                                        >> ${SIMULATE}
echo '  sleep 4'                                                                                                                         >> ${SIMULATE}
echo '  ISUP=$(curl -sk https://localhost/devicesimulation/v1/status | grep "Alive" | wc -l)'                                            >> ${SIMULATE}
echo 'done'                                                                                                                              >> ${SIMULATE}
echo 'curl -sk -X POST "https://localhost/devicesimulation/v1/simulations?template=default" -H "content-type: application/json" -d "{}"' >> ${SIMULATE}
echo 'echo'

# ========================================================================

echo '#!/bin/bash'             >> ${STOP}
echo 'list=$(docker ps -aq)'   >> ${STOP}
echo 'if [ -n "$list" ]; then' >> ${STOP}
echo '    docker rm -f $list'  >> ${STOP}
echo 'fi'                      >> ${STOP}

# ========================================================================

echo '#!/bin/bash'                                                >> ${UPDATE}
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

echo '#!/bin/bash'         >> ${LOGS}
echo "cd ${DEST}"          >> ${LOGS}
echo 'docker-compose logs' >> ${LOGS}

# ========================================================================

echo "var DeploymentConfig = {"                     >> ${WEBUICONFIG}
echo "  authEnabled: false,"                        >> ${WEBUICONFIG}
echo "  authType: '${PCS_WEBUI_AUTH_TYPE}',"        >> ${WEBUICONFIG}
echo "  aad : {"                                    >> ${WEBUICONFIG}
echo "    tenant: '${PCS_WEBUI_AUTH_AAD_TENANT}',"  >> ${WEBUICONFIG}
echo "    appId: '${PCS_WEBUI_AUTH_AAD_APPID}'"     >> ${WEBUICONFIG}
echo "  }"                                          >> ${WEBUICONFIG}
echo "}"                                            >> ${WEBUICONFIG}

# ========================================================================

nohup ${START} &
