#!/usr/bin/env bash

set -e
set -u

echo $GOOGLE_APPLICATION_CREDENTIALS
cat $GOOGLE_APPLICATION_CREDENTIALS

PROJECT=terraform-test-261120
CLUSTER_NAME=tf-${BRANCH_NAME}-${BUILD_NUMBER}
CLUSTER_NAME=$( echo ${CLUSTER_NAME} | tr  '[:upper:]' '[:lower:]')
PARENT_DOMAIN="${CLUSTER_NAME}.jenkins-x-test.test"

function cleanup()
{
	echo "Cleanup..."
	make destroy
}

trap cleanup EXIT

gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
gcloud auth list
gcloud config set project $PROJECT

echo "Creating cluster ${CLUSTER_NAME} in project ${PROJECT}..."
echo "gcp_project   = \"${PROJECT}\"" >> terraform.tfvars
echo "zone          = \"europe-west1-b\"" >> terraform.tfvars
echo "cluster_name  = \"${CLUSTER_NAME}\"" >> terraform.tfvars
echo "parent_domain = \"${PARENT_DOMAIN}\"" >> terraform.tfvars
echo "force_destroy = true" >> terraform.tfvars
echo "" >> terraform.tfvars
make plan
make apply

echo "Logging generated jx-requirements.yml..."
cat jx-requirements.yml

echo "Installing shellspec"
pushd /var/tmp
git clone https://github.com/shellspec/shellspec.git
export PATH=/var/tmp/shellspec/bin:${PATH}
popd

echo "Running shellspec tests..."
# waiting some time to let verything propagate, otherwise tests like workload identity verification can fail
sleep 60 
make test
