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

