#!/bin/bash

# Define input file names (assumes files are already created by the fetch script)
FILE_A="cache-prod-edcr-instance-data.json"
FILE_B="cache-prod-edco-instance-data.json"

# Use jq to compare files and find differences
jq --slurpfile a $FILE_A --slurpfile b $FILE_B -n '
  [($a[0].items[] | {
    name: .metadata.labels["app.kubernetes.io/name"],
    replicas: .spec.replicas,
    containers: .spec.template.spec.containers | map({
      container_name: .name,
      cpu_request: .resources.requests.cpu,
      cpu_limit: .resources.limits.cpu,
      memory_request: .resources.requests.memory,
      memory_limit: .resources.limits.memory
    })
  })] as $aList |
  [($b[0].items[] | {
    name: .metadata.labels["app.kubernetes.io/name"],
    replicas: .spec.replicas,
    containers: .spec.template.spec.containers | map({
      container_name: .name,
      cpu_request: .resources.requests.cpu,
      cpu_limit: .resources.limits.cpu,
      memory_request: .resources.requests.memory,
      memory_limit: .resources.limits.memory
    })
  })] as $bList |
  {
    in_a_not_in_b: ($aList | map(.name) - $bList | map(.name)),
    in_b_not_in_a: ($bList | map(.name) - $aList | map(.name)),
    diff_replicas: ($aList[] | . as $aItem | $bList[] | select(.name == $aItem.name and .replicas != $aItem.replicas)),
    resource_differences: ($aList[] | . as $aItem | $bList[] | select(.name == $aItem.name) | .containers[] as $bContainer | $aItem.containers[] | select(.container_name == $bContainer.container_name) | {
      container_name: .container_name,
      cpu_request_diff: (if .cpu_request != $bContainer.cpu_request then {a: .cpu_request, b: $bContainer.cpu_request} else empty end),
      memory_request_diff: (if .memory_request != $bContainer.memory_request then {a: .memory_request, b: $bContainer.memory_request} else empty end),
      cpu_limit_diff: (if .cpu_limit != $bContainer.cpu_limit then {a: .cpu_limit, b: $bContainer.cpu_limit} else empty end),
      memory_limit_diff: (if .memory_limit != $bContainer.memory_limit then {a: .memory_limit, b: $bContainer.memory_limit} else empty end)
    })
  }
' > differences.json

# Print differences to console
cat differences.json
