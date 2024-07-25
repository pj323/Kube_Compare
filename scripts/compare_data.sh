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
      echo "Printing sample data from both files to verify structure and data:"
      jq '.' data_${CLUSTER_A_CONTEXT}_${NAMESPACE}.json | head -n 20
      jq '.' data_${CLUSTER_B_CONTEXT}_${NAMESPACE}.json | head -n 20

      jq --argfile a data_${CLUSTER_A_CONTEXT}_${NAMESPACE}.json --argfile b data_${CLUSTER_B_CONTEXT}_${NAMESPACE}.json -n '
      ($a.items[] | {name: .metadata.name, replicas: .spec.replicas, cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu, memory_limits: .spec.template.spec.containers[0].resources.limits.memory, storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"], cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu, memory_requests: .spec.template.spec.containers[0].resources.requests.memory, storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]}) as $itemA
      | ($b.items[] | {name: .metadata.name, replicas: .spec.replicas, cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu, memory_limits: .spec.template.spec.containers[0].resources.limits.memory, storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"], cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu, memory_requests: .spec.template.spec.containers[0].resources.requests.memory, storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]}) as $itemB
      | if $itemA.name == $itemB.name then
        {
          name: $itemA.name,
          differences: {
            replicas: (if $itemA.replicas != $itemB.replicas then {"A": $itemA.replicas, "B": $itemB.replicas} else empty end),
            cpu_limits: (if $itemA.cpu_limits != $itemB.cpu_limits then {"A": $itemA.cpu_limits, "B": $itemB.cpu_limits} else empty end),
            memory_limits: (if $itemA.memory_limits != $itemB.memory_limits then {"A": $itemA.memory_limits, "B": $itemB.memory_limits} else empty end),
            storage_limits: (if $itemA.storage_limits != $itemB.storage_limits then {"A": $itemA.storage_limits, "B": $itemB.storage_limits} else empty end),
            cpu_requests: (if $itemA.cpu_requests != $itemB.cpu_requests then {"A": $itemA.cpu_requests, "B": $itemB.cpu_requests} else empty end),
            memory_requests: (if $itemA.memory_requests != $itemB.memory_requests then {"A": $itemA.memory_requests, "B": $itemB.memory_requests} else empty end),
            storage_requests: (if $itemA.storage_requests != $itemB.storage_requests then {"A": $itemA.storage_requests, "B": $itemB.storage_requests} else empty end)
          }
        }
        else empty
        end' > differences.json



        - |
      echo "Printing sample data from both files to verify structure and data:"
      jq '.' data_${CLUSTER_A_CONTEXT}_${NAMESPACE}.json | head -n 50
      jq '.' data_${CLUSTER_B_CONTEXT}_${NAMESPACE}.json | head -n 50

      jq --argfile a data_${CLUSTER_A_CONTEXT}_${NAMESPACE}.json --argfile b data_${CLUSTER_B_CONTEXT}_${NAMESPACE}.json -n '
      ($a.items[] | {name: .metadata.name, replicas: .spec.replicas}) as $itemA
      | ($b.items[] | {name: .metadata.name, replicas: .spec.replicas}) as $itemB
      | if $itemA.name == $itemB.name then
        {
          name: $itemA.name,
          differences: {
            replicas: (if $itemA.replicas != $itemB.replicas then {"A": $itemA.replicas, "B": $itemB.replicas} else empty end)
          }
        }
        else empty
      end' > differences.json
____________________________________
____________________________________



- |
      jq --argfile a ${CLUSTER_A}-${NAMESPACE}.json --argfile b ${CLUSTER_B}-${NAMESPACE}.json -n '
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
        | if $itemA.name == $itemB.name then
          {
            name: $itemA.name,
            differences: {
              replicas: (if $itemA.replicas != $itemB.replicas then {"A": $itemA.replicas, "B": $itemB.replicas} else empty end),
              cpu_limits: (if $itemA.cpu_limits != $itemB.cpu_limits then {"A": $itemA.cpu_limits, "B": $itemB.cpu_limits} else empty end),
              memory_limits: (if $itemA.memory_limits != $itemB.memory_limits then {"A": $itemA.memory_limits, "B": $itemB.memory_limits} else empty end),
              storage_limits: (if $itemA.storage_limits != $itemB.storage_limits then {"A": $itemA.storage_limits, "B": $itemB.storage_limits} else empty end),
              cpu_requests: (if $itemA.cpu_requests != $itemB.cpu_requests then {"A": $itemA.cpu_requests, "B": $itemB.cpu_requests} else empty end),
              memory_requests: (if $itemA.memory_requests != $itemB.memory_requests then {"A": $itemA.memory_requests, "B": $itemB.memory_requests} else empty end),
              storage_requests: (if $itemA.storage_requests != $itemB.storage_requests then {"A": $itemA.storage_requests, "B": $itemB.storage_requests} else empty end)
            }
          }
          else empty
        end' > differences.json





        - |
      echo "Loading JSON files..."
      jq '.' ${CLUSTER_A}-${NAMESPACE}.json > /dev/null
      jq '.' ${CLUSTER_B}-${NAMESPACE}.json > /dev/null
      echo "JSON files loaded successfully."

      echo "Extracting data and preparing for comparison..."
      jq --argfile a ${CLUSTER_A}-${NAMESPACE}.json --argfile b ${CLUSTER_B}-${NAMESPACE}.json -n '
        ($a.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu,
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0].resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        } | tojson) as $itemA
        | echo "Item from Cluster A: " $itemA
        | ($b.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu,
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0].resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        } | tojson) as $itemB
        | echo "Item from Cluster B: " $itemB
        | if $itemA.name == $itemB.name then
          {
            name: $itemA.name,
            differences: {
              replicas: (if $itemA.replicas != $itemB.replicas then {"A": $itemA.replicas, "B": $itemB.replicas} else "No difference in replicas"),
              cpu_limits: (if $itemA.cpu_limits != $itemB.cpu_limits then {"A": $itemA.cpu_limits, "B": $itemB.cpu_limits} else "No difference in CPU limits"),
              memory_limits: (if $itemA.memory_limits != $itemB.memory_limits then {"A": $itemA.memory_limits, "B": $itemB.memory_limits} else "No difference in memory limits"),
              storage_limits: (if $itemA.storage_limits != $itemB.storage_limits then {"A": $itemA.storage_limits, "B": $itemB.storage_limits} else "No difference in storage limits"),
              cpu_requests: (if $itemA.cpu_requests != $itemB.cpu_requests then {"A": $itemA.cpu_requests, "B": $itemB.cpu_requests} else "No difference in CPU requests"),
              memory_requests: (if $itemA.memory_requests != $itemB.memory_requests then {"A": $itemA.memory_requests, "B": $itemB.memory_requests} else "No difference in memory requests"),
              storage_requests: (if $itemA.storage_requests != $itemB.storage_requests then {"A": $itemA.storage_requests, "B": $itemB.storage_requests} else "No difference in storage requests")
            } | tojson
          }
          else
            echo "No matching names found or no differences"
        end' > differences.json
      echo "Comparison completed. Output saved to differences.json."
      echo "Differences:"
      cat differences.json








 - |
      echo "Verifying JSON file from Cluster A:"
      cat ${CLUSTER_A}-${NAMESPACE}.json | jq . || echo "Failed to parse JSON from Cluster A"
      
      echo "Verifying JSON file from Cluster B:"
      cat ${CLUSTER_B}-${NAMESPACE}.json | jq . || echo "Failed to parse JSON from Cluster B"

      echo "Performing a simple comparison to test JSON structure and jq command..."
      jq --argfile a ${CLUSTER_A}-${NAMESPACE}.json --argfile b ${CLUSTER_B}-${NAMESPACE}.json -n '
        ($a.items[] | {name: .metadata.name, replicas: .spec.replicas}) as $itemA
        | ($b.items[] | {name: .metadata.name, replicas: .spec.replicas}) as $itemB
        | if $itemA.name == $itemB.name then
          {
            "Name": $itemA.name,
            "Replicas A": $itemA.replicas,
            "Replicas B": $itemB.replicas,
            "Difference in Replicas": ($itemA.replicas != $itemB.replicas)
          }
          else
            empty
        end' | tee differences.json

      echo "Comparison results:"
      cat differences.json || echo "No differences file generated, check the jq command."





     - |
      echo "Loading JSON files..."
      cat ${CLUSTER_A}-${NAMESPACE}.json | jq . || echo "Failed to parse JSON from Cluster A"
      cat ${CLUSTER_B}-${NAMESPACE}.json | jq . || echo "Failed to parse JSON from Cluster B"

      echo "Performing detailed resource comparison..."
      jq --argfile a ${CLUSTER_A}-${NAMESPACE}.json --argfile b ${CLUSTER_B}-${NAMESPACE}.json -n '
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
        | if $itemA.name == $itemB.name then
          {
            "Name": $itemA.name,
            "Differences": {
              "Replicas": (if $itemA.replicas != $itemB.replicas then {"A": $itemA.replicas, "B": $itemB.replicas} else "No difference" end),
              "CPU Limits": (if $itemA.cpu_limits != $itemB.cpu_limits then {"A": $itemA.cpu_limits, "B": $itemB.cpu_limits} else "No difference" end),
              "Memory Limits": (if $itemA.memory_limits != $itemB.memory_limits then {"A": $itemA.memory_limits, "B": $itemB.memory_limits} else "No difference" end),
              "Storage Limits": (if $itemA.storage_limits != $itemB.storage_limits then {"A": $itemA.storage_limits, "B": $itemB.storage_limits} else "No difference" end),
              "CPU Requests": (if $itemA.cpu_requests != $itemB.cpu_requests then {"A": $itemA.cpu_requests, "B": $itemB.cpu_requests} else "No difference" end),
              "Memory Requests": (if $itemA.memory_requests != $itemB.memory_requests then {"A": $itemA.memory_requests, "B": $itemB.memory_requests} else "No difference" end),
              "Storage Requests": (if $itemA.storage_requests != $itemB.storage_requests then {"A": $itemA.storage_requests, "B": $itemB.storage_requests} else "No difference" end)
            }
          }
          else
            { "Name": $itemA.name, "Message": "No matching name found or no differences" }
        end' > differences.json





























- |
      echo "Loading JSON data..."
      jq --argfile test cache-test-data.json --argfile prep cache-prep-data.json --argfile prod cache-prod-data.json -n '
        ($test.items[] | {name: (.metadata.name | split("-")[0]), replicas: .spec.replicas}) as $itemsTest
        | ($prep.items[] | {name: (.metadata.name | split("-")[0]), replicas: .spec.replicas}) as $itemsPrep
        | ($prod.items[] | {name: (.metadata.name | split("-")[0]), replicas: .spec.replicas}) as $itemsProd
        | if ($itemsTest.name == $itemsPrep.name and $itemsTest.name == $itemsProd.name) then
          {
            BaseName: $itemsTest.name,
            Test_replicas: $itemsTest.replicas,
            Prep_replicas: $itemsPrep.replicas,
            Prod_replicas: $itemsProd.replicas
          }
          | select(.Test_replicas != .Prep_replicas or .Test_replicas != .Prod_replicas or .Prep_replicas != .Prod_replicas)
          else
            empty
          end
      ' > differences.json

      echo "Comparison of replicas across clusters completed. Differences:"
      cat differences.json




- |
      echo "Loading JSON data..."
      jq --argfile test cache-test-data.json --argfile prep cache-prep-data.json --argfile prod cache-prod-data.json -n '
        ($test.items[] | {name: (.metadata.name | split("-")[0]), test_replicas: .spec.replicas}) as $itemsTest
        | ($prep.items[] | {name: (.metadata.name | split("-")[0]), prep_replicas: .spec.replicas}) as $itemsPrep
        | ($prod.items[] | {name: (.metadata.name | split("-")[0]), prod_replicas: .spec.replicas}) as $itemsProd
        | if ($itemsTest.name == $itemsPrep.name and $itemsTest.name == $itemsProd.name) then
          {
            BaseName: $itemsTest.name,
            Test_replicas: $itemsTest.test_replicas,
            Prep_replicas: $itemsPrep.prep_replicas,
            Prod_replicas: $itemsProd.prod_replicas
          }
          | select(.Test_replicas != .Prep_replicas or .Test_replicas != .Prod_replicas or .Prep_replicas != .Prod_replicas)
          else
            empty
          end
      ' > differences.json
      
      # Create a new file with all the base names and their replicas
      jq -s '
        map({name: .BaseName, Test_replicas: .Test_replicas, Prep_replicas: .Prep_replicas, Prod_replicas: .Prod_replicas}) 
      ' differences.json > all-replicas.json
      
      echo "Comparison of replicas across clusters completed. Differences:"
      cat differences.json
      echo "All replicas:"
      cat all-replicas.json





- |
      echo "Loading JSON data..."
      # Combine and normalize data from all clusters
      jq --argfile test cache-test-data.json --argfile prep cache-prep-data.json --argfile prod cache-prod-data.json -n '
        ($test.items[] | {BaseName: (.metadata.name | split("-")[0]), test_replicas: .spec.replicas}) as $itemsTest
        | ($prep.items[] | {BaseName: (.metadata.name | split("-")[0]), prep_replicas: .spec.replicas}) as $itemsPrep
        | ($prod.items[] | {BaseName: (.metadata.name | split("-")[0]), prod_replicas: .spec.replicas}) as $itemsProd
        | [$itemsTest, $itemsPrep, $itemsProd]
      ' > temp-replicas.json

      # Create a new file with all the base names and their replicas from each cluster
      jq -s '
        add | group_by(.BaseName) | map({
          BaseName: .[0].BaseName,
          Test_replicas: (map(select(.test_replicas)) | .[].test_replicas),
          Prep_replicas: (map(select(.prep_replicas)) | .[].prep_replicas),
          Prod_replicas: (map(select(.prod_replicas)) | .[].prod_replicas)
        })
      ' temp-replicas.json > all-replicas.json

      # Now perform comparisons
      jq '
        group_by(.BaseName) | map({
          BaseName: .[0].BaseName,
          replicas: {
            Test: (map(select(.test_replicas)) | .[].test_replicas),
            Prep: (map(select(.prep_replicas)) | .[].prep_replicas),
            Prod: (map(select(.prod_replicas)) | .[].prod_replicas)
          }
        }) | map(select(
          .replicas.Test != .replicas.Prep or 
          .replicas.Test != .replicas.Prod or 
          .replicas.Prep != .replicas.Prod
        ))
      ' all-replicas.json > differences.json

      echo "All replicas across clusters:"
      cat all-replicas.json
      echo "Comparison of replicas across clusters completed. Differences:"
      cat differences.json







- |
      echo "Loading JSON data..."
      # Save all normalized names and replicas into all-replicas.json
      jq --argfile test cache-test-data.json --argfile prep cache-prep-data.json --argfile prod cache-prod-data.json -n '
        [
          ($test.items[] | {BaseName: (.metadata.name | split("-")[0]), Test_replicas: .spec.replicas}),
          ($prep.items[] | {BaseName: (.metadata.name | split("-")[0]), Prep_replicas: .spec.replicas}),
          ($prod.items[] | {BaseName: (.metadata.name | split("-")[0]), Prod_replicas: .spec.replicas})
        ] | flatten | group_by(.BaseName) | map({
          BaseName: .[0].BaseName,
          Test_replicas: map(select(.Test_replicas)) | .[].Test_replicas,
          Prep_replicas: map(select(.Prep_replicas)) | .[].Prep_replicas,
          Prod_replicas: map(select(.Prod_replicas)) | .[].Prod_replicas
        })
      ' > all-replicas.json
      
      echo "All BaseNames and their replicas across clusters have been saved to all-replicas.json:"
      cat all-replicas.json

      # Now perform comparisons directly from the initial data
      jq --argfile test cache-test-data.json --argfile prep cache-prep-data.json --argfile prod cache-prod-data.json -n '
        ($test.items[] | {name: (.metadata.name | split("-")[0]), replicas: .spec.replicas}) as $itemsTest
        | ($prep.items[] | {name: (.metadata.name | split("-")[0]), replicas: .spec.replicas}) as $itemsPrep
        | ($prod.items[] | {name: (.metadata.name | split("-")[0]), replicas: .spec.replicas}) as $itemsProd
        | if ($itemsTest.name == $itemsPrep.name and $itemsTest.name == $itemsProd.name) then
          {
            BaseName: $itemsTest.name,
            Test_replicas: $itemsTest.replicas,
            Prep_replicas: $itemsPrep.replicas,
            Prod_replicas: $itemsProd.replicas
          }
          | select(.Test_replicas != .Prep_replicas or .Test_replicas != .Prod_replicas or .Prep_replicas != .Prod_replicas)
          else
            empty
          end
      ' > differences.json

      echo "Comparison of replicas across clusters completed. Differences found:"
      cat differences.json




























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
          end' > differences.json

      echo "Comparison completed. Check the output for details."
      cat differences.json






- |
      echo "Loading JSON files and performing resource comparison..."
      jq --argfile a ${CLUSTER_A}-${NAMESPACE}.json --argfile b ${CLUSTER_B}-${NAMESPACE}.json --argfile c ${CLUSTER_C}-${NAMESPACE}.json -n '
        def compare_items($itemsA, $itemsB):
          if $itemsA.name == $itemsB.name then {
            "Name": $itemsA.name,
            "Differences": {
              "Replicas": (if $itemsA.replicas != $itemsB.replicas then {"A": $itemsA.replicas, "B": $itemsB.replicas} else null),
              "CPU Limits": (if $itemsA.cpu_limits != $itemsB.cpu_limits then {"A": $itemsA.cpu_limits, "B": $itemsB.cpu_limits} else null),
              "Memory Limits": (if $itemsA.memory_limits != $itemsB.memory_limits then {"A": $itemsA.memory_limits, "B": $itemsB.memory_limits} else null),
              "Storage Limits": (if $itemsA.storage_limits != $itemsB.storage_limits then {"A": $itemsA.storage_limits, "B": $itemsB.storage_limits} else null),
              "CPU Requests": (if $itemsA.cpu_requests != $itemsB.cpu_requests then {"A": $itemsA.cpu_requests, "B": $itemsB.cpu_requests} else null),
              "Memory Requests": (if $itemsA.memory_requests != $itemsB.memory_requests then {"A": $itemsA.memory_requests, "B": $itemsB.memory_requests} else null),
              "Storage Requests": (if $itemsA.storage_requests != $itemsB.storage_requests then {"A": $itemsA.storage_requests, "B": $itemsB.storage_requests} else null)
            } | with_entries(select(.value != null))
          } | select(.Differences | length > 0)
          else
            empty;
        [
          ($a.items[] | {name: .metadata.name, replicas: .spec.replicas, cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu, memory_limits: .spec.template.spec.containers[0].resources.limits.memory, storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"], cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu, memory_requests: .spec.template.spec.containers[0].resources.requests.memory, storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]}) as $itemsA
          | ($b.items[] | {name: .metadata.name, replicas: .spec.replicas, cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu, memory_limits: .spec.template.spec.containers[0].resources.limits.memory, storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"], cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu, memory_requests: .spec.template.spec.containers[0].resources.requests.memory, storage_requests: .spec.template.spec.containers[0.resources.requests["ephemeral-storage"]}) as $itemsB
          | compare_items($itemsA, $itemsB)
        ]' > differences.json

      echo "Comparison completed. Differences are available in the output file."
      cat differences.json | jq 




















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
          memory_requests: .spec.template.spec.containers[0. resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        }) as $itemB
        | ($c.items[] | {
          name: .metadata.name,
          replicas: .spec.replicas,
          cpu_limits: .spec.template.spec.containers[0].resources.limits.cpu,
          memory_limits: .spec.template.spec.containers[0].resources.limits.memory,
          storage_limits: .spec.template.spec.containers[0].resources.limits["ephemeral-storage"],
          cpu_requests: .spec.template.spec.containers[0].resources.requests.cpu,
          memory_requests: .spec.template.spec.containers[0. resources.requests.memory,
          storage_requests: .spec.template.spec.containers[0].resources.requests["ephemeral-storage"]
        }) as $itemC
        | if ($itemA.name == $itemB.name and $itemA.name == $itemC.name) then
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
          end' > differences.json

      echo "Comparison completed. Check the output for details."
      cat differences.json
  artifacts:
    paths:
      - differences.json
    expire_in: 1 hour


