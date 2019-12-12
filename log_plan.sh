#!/bin/bash

set -e
set -u

PLAN=$(terraform plan)
jx step pr comment --comment="${PLAN}"
