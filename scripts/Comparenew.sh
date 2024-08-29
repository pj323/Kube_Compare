compare_resources:
  stage: compare_resources
  image: docker:latest
  script:
    - apk add --no-cache jq
    - |
      echo "Loading JSON files..."
      # Parse JSON files and handle errors if they fail to parse
      cat ${CLUSTER_A}-${NAMESPACE}.json | jq . > /dev/null || echo "Failed to parse JSON from Cluster A"
      cat ${CLUSTER_B}-${NAMESPACE}.json | jq . > /dev/null || echo "Failed to parse JSON from Cluster B"
      cat ${CLUSTER_C}-${NAMESPACE}.json | jq . > /dev/null || echo "Failed to parse JSON from Cluster C"
      
      echo "Performing detailed resource comparison..."
      # Perform the comparison
      jq --argfile a ${CLUSTER_A}-${NAMESPACE}.json --argfile b ${CLUSTER_B}-${NAMESPACE}.json --argfile c ${CLUSTER_C}-${NAMESPACE}.json -n '
        # Define function to extract resource data
        def extract_data(item):
          {
            name: item.metadata.name,
            replicas: item.spec.replicas,
            cpu_limits: item.spec.template.spec.containers[0].resources.limits.cpu,
            memory_limits: item.spec.template.spec.containers[0].resources.limits.memory,
            storage_limits: item.spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
            cpu_requests: item.spec.template.spec.containers[0].resources.requests.cpu,
            memory_requests: item.spec.template.spec.containers[0].resources.requests.memory,
            storage_requests: item.spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
          };
        
        # Extract and compare data
        ($a.items[] | extract_data(.)) as $itemA |
        ($b.items[] | extract_data(.)) as $itemB |
        ($c.items[] | extract_data(.)) as $itemC |
        
        if ($itemA.name == $itemB.name and $itemA.name == $itemC.name) then
          {
            "Name": $itemA.name,
            "Differences": {
              "Replicas": {"A": $itemA.replicas, "B": $itemB.replicas, "C": $itemC.replicas},
              "CPU Limits": {"A": $itemA.cpu_limits, "B": $itemB.cpu_limits, "C": $itemC.cpu_limits},
              "Memory Limits": {"A": $itemA.memory_limits, "B": $itemB.memory_limits, "C": $itemC.memory_limits},
              "Storage Limits": {"A": $itemA.storage_limits, "B": $itemB.storage_limits, "C": $itemC.storage_limits},
              "CPU Requests": {"A": $itemA.cpu_requests, "B": $itemB.cpu_requests, "C": $itemC.cpu_requests},
              "Memory Requests": {"A": $itemA.memory_requests, "B": $itemB.memory_requests, "C": $itemC.memory_requests},
              "Storage Requests": {"A": $itemA.storage_requests, "B": $itemB.storage_requests, "C": $itemC.storage_requests}
            } | with_entries(select(.value.A != .value.B or .value.A != .value.C or .value.B != .value.C))
          } | select(.Differences | length > 0)
        else
          empty
        end
      ' > differences.json

      echo "Comparison completed. Check the output for details."
      cat differences.json
  artifacts:
    paths:
      - differences.json
    expire_in: 1 hour











    compare_resources:
  stage: compare_resources
  image: docker:latest
  script:
    - apk add --no-cache jq
    - |
      echo "Loading JSON files..."
      cat ${CLUSTER_A}-${NAMESPACE_A}.json | jq . > /dev/null || echo "Failed to parse JSON from Cluster A"
      cat ${CLUSTER_B}-${NAMESPACE_B}.json | jq . > /dev/null || echo "Failed to parse JSON from Cluster B"
      cat ${CLUSTER_C}-${NAMESPACE_C}.json | jq . > /dev/null || echo "Failed to parse JSON from Cluster C"

      echo "Performing detailed resource comparison..."
      jq --argfile a ${CLUSTER_A}-${NAMESPACE_A}.json --argfile b ${CLUSTER_B}-${NAMESPACE_B}.json --argfile c ${CLUSTER_C}-${NAMESPACE_C}.json -n '
        ($a.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0].resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        }) as $itemA
        | ($b.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu,
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0].resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        }) as $itemB
        | ($c.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu,
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0].resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        }) as $itemC
        | if $itemA.name == $itemB.name and $itemA.name == $itemC.name then
          {
            "Name": $itemA.name,
            "Differences": [
              { "Replicas": (if $itemA.replicas != $itemB.replicas or $itemA.replicas != $itemC.replicas then {"A": $itemA.replicas, "B": $itemB.replicas, "C": $itemC.replicas} else null) },
              { "CPU Limits": (if $itemA.cpu_limits != $itemB.cpu_limits or $itemA.cpu_limits != $itemC.cpu_limits then {"A": $itemA.cpu_limits, "B": $itemB.cpu_limits, "C": $itemC.cpu_limits} else null) },
              { "Memory Limits": (if $itemA.memory_limits != $itemB.memory_limits or $itemA.memory_limits != $itemC.memory_limits then {"A": $itemA.memory_limits, "B": $itemB.memory_limits, "C": $itemC.memory_limits} else null) },
              { "Storage Limits": (if $itemA.storage_limits != $itemB.storage_limits or $itemA.storage_limits != $itemC.storage_limits then {"A": $itemA.storage_limits, "B": $itemB.storage_limits, "C": $itemC.storage_limits} else null) },
              { "CPU Requests": (if $itemA.cpu_requests != $itemB.cpu_requests or $itemA.cpu_requests != $itemC.cpu_requests then {"A": $itemA.cpu_requests, "B": $itemB.cpu_requests, "C": $itemC.cpu_requests} else null) },
              { "Memory Requests": (if $itemA.memory_requests != $itemB.memory_requests or $itemA.memory_requests != $itemC.memory_requests then {"A": $itemA.memory_requests, "B": $itemB.memory_requests, "C": $itemC.memory_requests} else null) },
              { "Storage Requests": (if $itemA.storage_requests != $itemB.storage_requests or $itemA.storage_requests != $itemC.storage_requests then {"A": $itemA.storage_requests, "B": $itemB.storage_requests, "C": $itemC.storage_requests} else null) }
            ] | add | with_entries(select(.value != null))
          }
          | select(.Differences | length > 0)
        else
          empty
        end
      ' > differences.json

      echo "Comparison completed. Check the output for details."
      cat differences.json
  artifacts:
    paths:
      - differences.json
    expire_in: 1 hour


compare_resources:
  stage: compare_resources
  image: docker:latest
  script:
    - apk add --no-cache jq
    - |
      echo "Loading JSON files..."
      cat ${CLUSTER_A}-${NAMESPACE}.json | jq . || echo "Failed to parse JSON from Cluster A"
      cat ${CLUSTER_B}-${NAMESPACE}.json | jq . || echo "Failed to parse JSON from Cluster B"
      cat ${CLUSTER_C}-${NAMESPACE}.json | jq . || echo "Failed to parse JSON from Cluster C"

      echo "Performing detailed resource comparison..."
      jq --argfile a ${CLUSTER_A}-${NAMESPACE}.json --argfile b ${CLUSTER_B}-${NAMESPACE}.json --argfile c ${CLUSTER_C}-${NAMESPACE}.json -n '
        ($a.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu,
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0].resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        }) as $itemA
        | ($b.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu,
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0].resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        }) as $itemB
        | ($c.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu,
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0].resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        }) as $itemC
        | if $itemA.name == $itemB.name and $itemA.name == $itemC.name then
          {
            "Name": $itemA.name,
            "Differences": [
              { "Replicas": (if $itemA.replicas != $itemB.replicas or $itemA.replicas != $itemC.replicas then {"A": $itemA.replicas, "B": $itemB.replicas, "C": $itemC.replicas} else null end) },
              { "CPU Limits": (if $itemA.cpu_limits != $itemB.cpu_limits or $itemA.cpu_limits != $itemC.cpu_limits then {"A": $itemA.cpu_limits, "B": $itemB.cpu_limits, "C": $itemC.cpu_limits} else null end) },
              { "Memory Limits": (if $itemA.memory_limits != $itemB.memory_limits or $itemA.memory_limits != $itemC.memory_limits then {"A": $itemA.memory_limits, "B": $itemB.memory_limits, "C": $itemC.memory_limits} else null end) },
              { "Storage Limits": (if $itemA.storage_limits != $itemB.storage_limits or $itemA.storage_limits != $itemC.storage_limits then {"A": $itemA.storage_limits, "B": $itemB.storage_limits, "C": $itemC.storage_limits} else null end) },
              { "CPU Requests": (if $itemA.cpu_requests != $itemB.cpu_requests or $itemA.cpu_requests != $itemC.cpu_requests then {"A": $itemA.cpu_requests, "B": $itemB.cpu_requests, "C": $itemC.cpu_requests} else null end) },
              { "Memory Requests": (if $itemA.memory_requests != $itemB.memory_requests or $itemA.memory_requests != $itemC.memory_requests then {"A": $itemA.memory_requests, "B": $itemB.memory_requests, "C": $itemC.memory_requests} else null end) },
              { "Storage Requests": (if $itemA.storage_requests != $itemB.storage_requests or $itemA.storage_requests != $itemC.storage_requests then {"A": $itemA.storage_requests, "B": $itemB.storage_requests, "C": $itemC.storage_requests} else null end) }
            ] | add | with_entries(select(.value != null))
          }
          | select(.Differences | length > 0)
        else
          empty
        end
      ' > differences.json

      echo "Comparison completed. Check the output for details."
      cat differences.json
  artifacts:
    paths:
      - differences.json
    expire_in: 1 hour


