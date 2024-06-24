#!/bin/bash

# Define input file names (assumes files are already created by the fetch script)
FILE_A="cache-prod-edcr-instance-data.json"
FILE_B="cache-prod-edco-instance-data.json"

# Use jq to compare files and find differences
jq --argfile a $FILE_A --argfile b $FILE_B -n '
  [($a.items[] | {name: .metadata.name, replicas: .spec.replicas, containers: .spec.template.spec.containers | map({container_name: .name, resources: .resources})})] as $aList |
  [($b.items[] | {name: .metadata.name, replicas: .spec.replicas, containers: .spec.template.spec.containers | map({container_name: .name, resources: .resources})})] as $bList |
  {
    in_a_not_in_b: ($aList | map(.name) - $bList | map(.name)),
    in_b_not_in_a: ($bList | map(.name) - $aList | map(.name)),
    diff_replicas: ($aList[] | . as $aItem | $bList[] | select(.name == $aItem.name and .replicas != $aItem.replicas)),
    resource_differences: ($aList[] | . as $aItem | $bList[] | select(.name == $aItem.name) | .containers[] as $bContainer | $aItem.containers[] | select(.container_name == $bContainer.container_name) | {
      container_name: .container_name,
      cpu_request_diff: (if .resources.requests.cpu != $bContainer.resources.requests.cpu then {a: .resources.requests.cpu, b: $bContainer.resources.requests.cpu} else empty end),
      memory_request_diff: (if .resources.requests.memory != $bContainer.resources.requests.memory then {a: .resources.requests.memory, b: $bContainer.resources.requests.memory} else empty end),
      cpu_limit_diff: (if .resources.limits.cpu != $bContainer.resources.limits.cpu then {a: .resources.limits.cpu, b: $bContainer.resources.limits.cpu} else empty end),
      memory_limit_diff: (if .resources.limits.memory != $bContainer.resources.limits.memory then {a: .resources.limits.memory, b: $bContainer.resources.limits.memory} else empty end)
    })
  }
' > differences.json

# Print differences to console
cat differences.json
