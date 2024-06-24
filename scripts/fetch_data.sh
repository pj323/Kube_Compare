#!/bin/bash

# Command line arguments for namespace, cluster identifier, and Kubernetes context
NAMESPACE=$1
CLUSTER=$2


# Output file name based on cluster and namespace
FILE_NAME="${CLUSTER}-${NAMESPACE}.json"

# Fetch stateful set data using kubectl with the specified context
echo "Fetching stateful sets from $CLUSTER using context $CONTEXT..."
kubectl get sts --namespace $NAMESPACE -o json > $FILE_NAME

echo "Data successfully written to $FILE_NAME"

