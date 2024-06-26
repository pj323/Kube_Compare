#!/bin/bash

# Define input file names
FILE_A="cache-prod-edcr-instance-data.json"
FILE_B="cache-prod-edco-instance-data.json"

# Use jq to safely compare files and find differences
jq --slurpfile a $FILE_A --slurpfile b $FILE_B -n '
{
  in_a_not_in_b: [
    $a[0].items[] | select(.metadata.labels["app.kubernetes.io/name"]? as $name_a | 
      $b[0].items[] | map(.metadata.labels["app.kubernetes.io/name"]?) | index($name_a) | not)
  ],
  in_b_not_in_a: [
    $b[0].items[] | select(.metadata.labels["app.kubernetes.io/name"]? as $name_b | 
      $a[0].items[] | map(.metadata.labels["app.kubernetes.io/name"]?) | index($name_b) | not)
  ],
  diff_replicas: [
    $a[0].items[] | . as $aItem | 
    $b[0].items[] | select(.metadata.labels["app.kubernetes.io/name"]? == $aItem.metadata.labels["app.kubernetes.io/name"]? and 
                           .spec?.replicas != $aItem.spec?.replicas) | 
    {name: .metadata.labels["app.kubernetes.io/name"]?, a_replicas: $aItem.spec?.replicas, b_replicas: .spec?.replicas}
  ],
  resource_differences: [
    $a[0].items[] | . as $aItem | 
    $b[0].items[] | select(.metadata.labels["app.kubernetes.io/name"]? == $aItem.metadata.labels["app.kubernetes.io/name"]?) | 
    .spec.template.spec.containers[]? as $bContainer | 
    $aItem.spec.template.spec.containers[]? | 
    select(.name? == $bContainer.name?) | {
      container_name: .name?,
      cpu_request_diff: (if .resources?.requests?.cpu != $bContainer.resources?.requests?.cpu then {a: .resources?.requests?.cpu, b: $bContainer.resources?.requests?.cpu} else empty end),
      memory_request_diff: (if .resources?.requests?.memory != $bContainer.resources?.requests?.memory then {a: .resources?.requests?.memory, b: $bContainer.resources?.requests?.memory} else empty end),
      cpu_limit_diff: (if .resources?.limits?.cpu != $bContainer.resources?.limits?.cpu then {a: .resources?.limits?.cpu, b: $bContainer.resources?.limits?.cpu} else empty end),
      memory_limit_diff: (if .resources?.limits?.memory != $bContainer.resources?.limits?.memory then {a: .resources?.limits?.memory, b: $bContainer.resources?.limits?.memory} else empty end)
    }
  ]
}
' > differences.json

# Print differences to console
cat differences.json

|
      jq --argfile a ${CLUSTER_A}_${NAMESPACE}.json --argfile b ${CLUSTER_B}_${NAMESPACE}.json -n '
      ($a.items[] | {name: .metadata.name, replicas: .spec.replicas}) as $itemsA
      | ($b.items[] | {name: .metadata.name, replicas: .spec.replicas}) as $itemsB
      | if $itemsA.name == $itemsB.name and $itemsA.replicas != $itemsB.replicas 
        then {name: $itemsA.name, A_replicas: $itemsA.replicas, B_replicas: $itemsB.replicas}
        else empty
      end' > differences.json



- |
      jq --argfile a data_${CLUSTER_A_CONTEXT}_${NAMESPACE}.json --argfile b data_${CLUSTER_B_CONTEXT}_${NAMESPACE}.json -n '
      ($a.items[] | {name: .metadata.name, replicas: .spec.replicas, resources: .spec.template.spec.containers[0].resources}) as $itemsA
      | ($b.items[] | {name: .metadata.name, replicas: .spec.replicas, resources: .spec.template.spec.containers[0].resources}) as $itemsB
      | if $itemsA.name == $itemsB.name then 
        {
          name: $itemsA.name,
          differences: 
          {
            replica_differences: (if $itemsA.replicas != $itemsB.replicas then {A_replicas: $itemsA.replicas, B_replicas: $itemsB.replicas} else empty end),
            cpu_limits: (if $itemsA.resources.limits.cpu != $itemsB.resources.limits.cpu then {A_cpu_limits: $itemsA.resources.limits.cpu, B_cpu_limits: $itemsB.resources.limits.cpu} else empty end),
            memory_limits: (if $itemsA.resources.limits.memory != $itemsB.resources.limits.memory then {A_memory_limits: $itemsA.resources.limits.memory, B_memory_limits: $itemsB.resources.limits.memory} else empty end),
            storage_limits: (if $itemsA.resources.limits["ephemeral-storage"] != $itemsB.resources.limits["ephemeral-storage"] then {A_storage_limits: $itemsA.resources.limits["ephemeral-storage"], B_storage_limits: $itemsB.resources.limits["ephemeral-storage"]} else empty end),
            cpu_requests: (if $itemsA.resources.requests.cpu != $itemsB.resources.requests.cpu then {A_cpu_requests: $itemsA.resources.requests.cpu, B_cpu_requests: $itemsB.resources.requests.cpu} else empty end),
            memory_requests: (if $itemsA.resources.requests.memory != $itemsB.resources.requests.memory then {A_memory_requests: $itemsA.resources.requests.memory, B_memory_requests: $itemsB.resources.requests.memory} else empty end),
            storage_requests: (if $itemsA.resources.requests["ephemeral-storage"] != $itemsB.resources.requests["ephemeral-storage"] then {A_storage_requests: $itemsA.resources.requests["ephemeral-storage"], B_storage_requests: $itemsB.resources.requests["ephemeral-storage"]} else empty end)
          }
        }
        else empty
      end' > differences.json
