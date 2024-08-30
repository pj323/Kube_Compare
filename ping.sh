- |
      SINGLE_INSTANCE=$1  # Get the single instance name from the first argument
      echo "Checking DNS resolution for $SINGLE_INSTANCE"
      IP_ADDRESS=$(getent hosts $SINGLE_INSTANCE | awk '{ print $1 }')

      if [ -z "$IP_ADDRESS" ]; then
        echo "DNS name $SINGLE_INSTANCE could not be resolved to an IP address" >> PING_RESULTS.txt
      else
        echo "Pinging $SINGLE_INSTANCE ($IP_ADDRESS)"
        touch PING_RESULTS.txt
        PING=$(timeout 5 sh -c '(echo ping; sleep 1) | nc -q 1 -v $SINGLE_INSTANCE 6379 2>&1')
        if [ $? -eq 124 ]; then
          echo "$SINGLE_INSTANCE STS is Down" >> PING_RESULTS.txt
        elif echo "$PING" | grep -q "+PONG"; then
          echo "$SINGLE_INSTANCE +PONG" >> PING_RESULTS.txt
        elif echo "$PING" | grep -q "Connection refused"; then
          echo "$SINGLE_INSTANCE Connection refused" >> PING_RESULTS.txt
        else
          echo "$SINGLE_INSTANCE Connection failed: $PING" >> PING_RESULTS.txt
        fi
      fi





      stages:
  - search
  - details
  - health-check
  - report

variables:
  CLUSTERS: "EDCO EDCR"
  KUBECONFIG_EDCO: "/path/to/edco/kubeconfig"
  KUBECONFIG_EDCR: "/path/to/edcr/kubeconfig"

search_instance:
  stage: search
  script:
    - echo "Searching for instance in all clusters..."
    - INSTANCE_FOUND=0
    - for CLUSTER in $CLUSTERS; do
        KUBECONFIG_VAR="KUBECONFIG_$CLUSTER";
        export KUBECONFIG=${!KUBECONFIG_VAR};
        NAMESPACE=$(kubectl get pods --all-namespaces -o wide | grep "$INSTANCE_NAME" | awk '{print $1}');
        if [ -n "$NAMESPACE" ]; then
          echo "Instance found in $CLUSTER cluster, namespace: $NAMESPACE";
          echo "$CLUSTER" > cluster_name.txt;
          echo "$NAMESPACE" > namespace_name.txt;
          INSTANCE_FOUND=1;
          break;
        fi;
      done;
    - if [ "$INSTANCE_FOUND" -eq 0 ]; then
        echo "Instance not found in any cluster. Exiting.";
        exit 1;
      fi;

fetch_details:
  stage: details
  script:
    - export KUBECONFIG=$(cat cluster_name.txt | xargs -I {} echo KUBECONFIG_{});
    - NAMESPACE=$(cat namespace_name.txt);
    - POD_NAME=$(kubectl get pods --namespace $NAMESPACE | grep "$INSTANCE_NAME" | awk '{print $1}');
    - echo "Fetching pod details for $POD_NAME in namespace $NAMESPACE..."
    - kubectl describe pod $POD_NAME --namespace $NAMESPACE > pod_details.txt;
    - kubectl get statefulsets --namespace $NAMESPACE > sts_details.txt;
    - kubectl describe svc --namespace $NAMESPACE > svc_details.txt;
    - kubectl get cm --namespace $NAMESPACE > configmaps.txt;
    - kubectl logs $POD_NAME --namespace $NAMESPACE --tail=100 > pod_logs.txt;
    - kubectl get events --namespace $NAMESPACE > events.txt;
    - cat pod_details.txt sts_details.txt svc_details.txt configmaps.txt pod_logs.txt events.txt > instance_report.txt;

health_check:
  stage: health-check
  script:
    - echo "Performing health check on instance $POD_NAME..."
    - kubectl exec $POD_NAME --namespace $NAMESPACE -- ping -c 4 127.0.0.1 > ping_results.txt;
    - kubectl top pod $POD_NAME --namespace $NAMESPACE > resource_usage.txt;
    - echo "Health check complete.";

generate_report:
  stage: report
  script:
    - echo "Generating report..."
    - cat instance_report.txt ping_results.txt resource_usage.txt > full_report.txt;
    - mkdir -p reports;
    - mv full_report.txt reports/instance_report_$INSTANCE_NAME.txt;
  artifacts:
    paths:
      - reports/


