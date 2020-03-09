#!/usr/bin/env bash

set -e
set -u

echo $GOOGLE_APPLICATION_CREDENTIALS
cat $GOOGLE_APPLICATION_CREDENTIALS

PROJECT=terraform-test-261120
CLUSTER_NAME=tf-${BRANCH_NAME}-${BUILD_NUMBER}
CLUSTER_NAME=$( echo ${CLUSTER_NAME} | tr  '[:upper:]' '[:lower:]')
PARENT_DOMAIN="${CLUSTER_NAME}.jenkins-x-test.test"
VARS="-var gcp_project=${PROJECT} -var zone=europe-west1-b -var cluster_name=${CLUSTER_NAME} -var parent_domain=${PARENT_DOMAIN}"

function cleanup()
{
	echo "Cleanup..."
	terraform destroy $VARS -auto-approve
}

trap cleanup EXIT

echo "Generating Plan..."
terraform plan $VARS -no-color

echo "Creating cluster ${CLUSTER_NAME} in project ${PROJECT}..."
terraform apply $VARS -auto-approve

echo "Logging generated jx-requirements.yaml..."
cat jx-requirements.yaml

echo "Installing shellspec"
pushd /var/tmp
git clone https://github.com/shellspec/shellspec.git
export PATH=/var/tmp/shellspec/bin:${PATH}
popd

echo "Running shellspec tests..."
# waiting some time to let verything propagate, otherwise tests like workload identity verification can fail
sleep 60 
make test
