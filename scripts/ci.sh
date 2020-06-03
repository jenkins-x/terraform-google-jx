#!/usr/bin/env bash

set -e
set -u

PROJECT=terraform-test-261120
ZONE=europe-west1-b
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
gcloud config set compute/zone ${ZONE}

echo "Creating cluster ${CLUSTER_NAME} in project ${PROJECT}..."
echo "gcp_project             = \"${PROJECT}\"" >> terraform.tfvars
echo "cluster_location        = \"${ZONE}\"" >> terraform.tfvars
echo "cluster_name            = \"${CLUSTER_NAME}\"" >> terraform.tfvars
echo "parent_domain           = \"${PARENT_DOMAIN}\"" >> terraform.tfvars
echo "resource_labels         = {powered-by = \"jenkins-x\"}" >> terraform.tfvars
echo "lets_encrypt_production = false" >> terraform.tfvars
echo "force_destroy           = true" >> terraform.tfvars
echo "enable_backup           = true" >> terraform.tfvars
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
