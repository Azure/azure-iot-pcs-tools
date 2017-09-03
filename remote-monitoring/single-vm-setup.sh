#!/bin/bash

set -x

DEST="/app"
START="${DEST}/start.sh"
STOP="${DEST}/stop.sh"

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

COMPOSEFILE="https://raw.githubusercontent.com/Azure/azure-iot-pcs-tools/master/remote-monitoring/docker-compose.${APP_RUNTIME}.yml"

# ========================================================================

mkdir -p ${DEST}
cd ${DEST}
touch ${START} && chmod 750 ${START}
touch ${STOP} && chmod 750 ${STOP}
wget $COMPOSEFILE -O ${DEST}/docker-compose.yml

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
echo                             >> ${START}
echo "cd ${DEST}"                >> ${START}
echo "nohup docker-compose up &" >> ${START}

# ========================================================================

echo 'list=$(docker ps -aq)'   >> ${STOP}
echo 'if [ -n "$list" ]; then' >> ${STOP}
echo '    docker rm -f $list'  >> ${STOP}
echo 'fi'                      >> ${STOP}

# ========================================================================

nohup ${START} &
