#!/usr/bin/env bash

set -e
set -u

PROJECT=terraform-test-261120
ZONE=europe-west1-b
CLUSTER_NAME=tf-${BRANCH_NAME}-${BUILD_NUMBER}
CLUSTER_NAME=$( echo ${CLUSTER_NAME} | tr  '[:upper:]' '[:lower:]')
APEX_DOMAIN="${CLUSTER_NAME}.jenkins-x-test.test"

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

cat <<EOF > terraform.tfvars
gcp_project             = "${PROJECT}" 
cluster_location        = "${ZONE}" 
cluster_name            = "${CLUSTER_NAME}" 
apex_domain             = "${APEX_DOMAIN}" 
resource_labels         = {powered-by = "jenkins-x"}
lets_encrypt_production = false
force_destroy           = true 
enable_backup           = true
create_ui_sa            = true
EOF

make plan
make show-plan
make apply

gcloud container clusters get-credentials ${CLUSTER_NAME} --zone=${ZONE} --project=${PROJECT}

echo "Logging generated jx-requirements.yml..."
terraform output jx_requirements > jx-requirements.yml

echo "Installing shellspec"
pushd /var/tmp
git clone https://github.com/shellspec/shellspec.git
export PATH=/var/tmp/shellspec/bin:${PATH}
popd

echo "Running shellspec tests..."
# waiting some time to let verything propagate, otherwise tests like workload identity verification can fail
sleep 60 
make test
