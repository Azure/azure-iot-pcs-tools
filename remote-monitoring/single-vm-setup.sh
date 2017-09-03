#!/bin/bash

set -x

DEST="/app"

mkdir -p ${DEST}
cd ${DEST}

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

wget $COMPOSEFILE -O ${DEST}/docker-compose.yml

touch ${DEST}/run.sh
chmod 755 ${DEST}/run.sh

echo "export HOST_NAME=\"${HOST_NAME}\""                                                                 >> ${DEST}/run.sh
echo "export APP_RUNTIME=\"${APP_RUNTIME}\""                                                             >> ${DEST}/run.sh
echo "export PCS_AUTH_AAD_GLOBAL_TENANTID=\"${PCS_AUTH_AAD_GLOBAL_TENANTID}\""                           >> ${DEST}/run.sh
echo "export PCS_AUTH_AAD_GLOBAL_CLIENTID=\"${PCS_AUTH_AAD_GLOBAL_CLIENTID}\""                           >> ${DEST}/run.sh
echo "export PCS_AUTH_AAD_GLOBAL_LOGINURI=\"${PCS_AUTH_AAD_GLOBAL_LOGINURI}\""                           >> ${DEST}/run.sh
echo "export PCS_IOTHUB_CONNSTRING=\"${PCS_IOTHUB_CONNSTRING}\""                                         >> ${DEST}/run.sh
echo "export PCS_STORAGEADAPTER_DOCUMENTDB_CONNSTRING=\"${PCS_STORAGEADAPTER_DOCUMENTDB_CONNSTRING}\""   >> ${DEST}/run.sh
echo "export PCS_DEVICETELEMETRY_DOCUMENTDB_CONNSTRING=\"${PCS_DEVICETELEMETRY_DOCUMENTDB_CONNSTRING}\"" >> ${DEST}/run.sh
echo "export PCS_STREAMANALYTICS_DOCUMENTDB_CONNSTRING=\"${PCS_STREAMANALYTICS_DOCUMENTDB_CONNSTRING}\"" >> ${DEST}/run.sh
echo "export PCS_IOTHUBREACT_ACCESS_CONNSTRING=\"${PCS_IOTHUBREACT_ACCESS_CONNSTRING}\""                 >> ${DEST}/run.sh
echo "export PCS_IOTHUBREACT_HUB_NAME=\"${PCS_IOTHUBREACT_HUB_NAME}\""                                   >> ${DEST}/run.sh
echo "export PCS_IOTHUBREACT_HUB_ENDPOINT=\"${PCS_IOTHUBREACT_HUB_ENDPOINT}\""                           >> ${DEST}/run.sh
echo "export PCS_IOTHUBREACT_HUB_PARTITIONS=\"${PCS_IOTHUBREACT_HUB_PARTITIONS}\""                       >> ${DEST}/run.sh
echo "export PCS_IOTHUBREACT_AZUREBLOB_ACCOUNT=\"${PCS_IOTHUBREACT_AZUREBLOB_ACCOUNT}\""                 >> ${DEST}/run.sh
echo "export PCS_IOTHUBREACT_AZUREBLOB_KEY=\"${PCS_IOTHUBREACT_AZUREBLOB_KEY}\""                         >> ${DEST}/run.sh
echo                             >> ${DEST}/run.sh
echo "cd ${DEST}"                >> ${DEST}/run.sh
echo "nohup docker-compose up &" >> ${DEST}/run.sh

nohup ${DEST}/run.sh &
