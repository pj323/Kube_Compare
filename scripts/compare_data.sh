#!/bin/bash

# Define input file names
FILE_A="cache-prod-edcr-instance-data.json"
FILE_B="cache-prod-edco-instance-data.json"

# Use jq to compare files and find differences
jq --slurpfile a $FILE_A --slurpfile b $FILE_B -n '
{
  in_a_not_in_b: [
    $a[0].items[] | select(.metadata.labels["app.kubernetes.io/name"] as $name_a | 
      none($b[0].items[] | .metadata.labels["app.kubernetes.io/name"] == $name_a))
  ],
  in_b_not_in_a: [
    $b[0].items[] | select(.metadata.labels["app.kubernetes.io/name"] as $name_b | 
      none($a[0].items[] | .metadata.labels["app.kubernetes.io/name"] == $name_b))
  ],
  diff_replicas: [
    $a[0].items[] | . as $aItem | 
    $b[0].items[] | select(.metadata.labels["app.kubernetes.io/name"] == $aItem.metadata.labels["app.kubernetes.io/name"] and 
                           .spec.replicas != $aItem.spec.replicas) | 
    {name: .metadata.labels["app.kubernetes.io/name"], a_replicas: $aItem.spec.replicas, b_replicas: .spec.replicas}
  ],
  resource_differences: [
    $a[0].items[] | . as $aItem | 
    $b[0].items[] | select(.metadata.labels["app.kubernetes.io/name"] == $aItem.metadata.labels["app.kubernetes.io/name"]) | 
    .spec.template.spec.containers[] as $bContainer | 
    $aItem.spec.template.spec.containers[] | 
    select(.name == $bContainer.name) | {
      container_name: .name,
      cpu_request_diff: (if .resources.requests.cpu != $bContainer.resources.requests.cpu then {a: .resources.requests.cpu, b: $bContainer.resources.requests.cpu} else empty end),
      memory_request_diff: (if .resources.requests.memory != $bContainer.resources.requests.memory then {a: .resources.requests.memory, b: $bContainer.resources.requests.memory} else empty end),
      cpu_limit_diff: (if .resources.limits.cpu != $bContainer.resources.limits.cpu then {a: .resources.limits.cpu, b: $bContainer.resources.limits.cpu} else empty end),
      memory_limit_diff: (if .resources.limits.memory != $bContainer.resources.limits.memory then {a: .resources.limits.memory, b: $bContainer.resources.limits.memory} else empty end)
    }
  ]
}
' > differences.json

# Print differences to console
cat differences.json
