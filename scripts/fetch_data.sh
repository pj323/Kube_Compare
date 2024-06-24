#!/bin/bash

# Define namespaces and output file names
NAMESPACE_A="edcr"
NAMESPACE_B="edco"
FILE_A="cache-prod-${NAMESPACE_A}-instance-data.json"
FILE_B="cache-prod-${NAMESPACE_B}-instance-data.json"

# Fetch stateful set data
kubectl get sts --namespace $NAMESPACE_A -o json > $FILE_A
kubectl get sts --namespace $NAMESPACE_B -o json > $FILE_B
