#!/bin/bash

set -e
set -u

echo "Generating Plan..."
PLAN=$(terraform plan -no-color)

echo "Logging Plan..."
jx step pr comment --code --comment="${PLAN}"

PROJECT_NAME=terraform-${BRANCH_NAME}-${BUILD_NUMBER}
PROJECT_NAME=$( echo $PROJECT_NAME | tr  '[:upper:]' '[:lower:]')
FOLDER=xxx

echo "Creating project ${PROJECT_NAME} under folder ${FOLDER}..."

echo "Enabling API(s)..."

echo "Applying Terraform..."

echo "Test???"

echo "Cleanup..."

echo "Delete Project..."
