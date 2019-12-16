#!/bin/bash

set -e
set -u

PROJECT=terraform-test
CLUSTER_NAME=tf-${BRANCH_NAME}-${BUILD_NUMBER}
CLUSTER_NAME=$( echo ${CLUSTER_NAME} | tr  '[:upper:]' '[:lower:]')
VARS="-var gcp_project=terraform-test -var region=europe-west1 -var zone=europe-west1-b -var cluster_name=${CLUSTER_NAME}"

echo "Generating Plan..."
PLAN=$(terraform plan $VARS -no-color)

echo "Logging Plan..."
jx step pr comment --code --comment="${PLAN}"

echo "Creating cluster ${CLUSTER_NAME} in project ${PROJECT}..."

echo "Applying Terraform..."
terrform apply $VARS -auto-approve

echo "Test???"

echo "Cleanup..."
terraform destroy $VARS -auto-approve
