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
