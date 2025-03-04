#!/bin/bash
export TEST_PLATFORM_CONNECTION_PROMETHEUS_URL=none
JAVA_TRUST_STORE=${PWD}/scdf_cf_setup/mycacerts
MAVEN_PROPERTIES="-Dtest.docker.compose.disable.extension=true -Djavax.net.ssl.trustStore=${JAVA_TRUST_STORE} -Djavax.net.ssl.trustStorePassword=changeit"
TESTS_ARG="!DataFlowAT#streamAppCrossVersion,!DataFlowAT#streamPartitioning,!BatchRemotePartitioningAT#runBatchRemotePartitionJobCloudFoundry"
MAVEN_GRP=
if [ "$TESTS" != "" ]; then
  echo "Setting failsafe test filter: $TESTS"
  MAVEN_ARG="-Dit.test=$TESTS"
else
  # -Dit.test=$TESTS_ARG
  MAVEN_ARG="-Dit.test=$TESTS_ARG"
  MAVEN_GRP="-Dgroups=always,smoke"
fi

HTTPS_ENABLED="true"
SERVER_URI="$SPRING_CLOUD_DATAFLOW_CLIENT_SERVER_URI"
SKIP_SSL_VALIDATION="$SPRING_CLOUD_STREAM_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION"
if [[ -z "$SPRING_CLOUD_STREAM_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION" ]]; then
  SKIP_SSL_VALIDATION="false"
fi
set +e
#
set -o pipefail
./mvnw -s .settings.xml \
  -U -B -Dspring.profiles.active=blah \
  "$MAVEN_GRP" "$MAVEN_ARG" -DPLATFORM_TYPE=cloudfoundry \
  -DSKIP_CLOUD_CONFIG=true -Dtest.docker.compose.disable.extension=true -Dspring.cloud.dataflow.client.serverUri=$SERVER_URI \
  -Dspring.cloud.dataflow.client.skipSslValidation=$SKIP_SSL_VALIDATION -Dtest.platform.connection.platformName=default \
  -Dtest.platform.connection.applicationOverHttps=$HTTPS_ENABLED \
  $MAVEN_PROPERTIES clean verify | tee test-output.log
RC=$?
echo "RC=$RC"
if ((RC != 0)); then
  # TODO extract logs from dataflow and skipper and pipe to dataflow.log and skipper.log
  echo "Implement download of skipper logs"
  echo "Implement download of dataflow logs"
fi
exit $RC
