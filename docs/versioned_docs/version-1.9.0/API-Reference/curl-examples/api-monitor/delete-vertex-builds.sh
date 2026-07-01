curl -X DELETE \
  "$PRIMEAGFENT_URL/api/v1/monitor/builds?flow_id=$FLOW_ID" \
  -H "accept: */*" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY"
