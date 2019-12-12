#!/bin/bash

set -e
set -u

echo "Generating Plan..."
PLAN=$(terraform plan -no-color)

echo $PLAN

echo "Logging Plan..."
jx step pr comment --comment="${PLAN}"
