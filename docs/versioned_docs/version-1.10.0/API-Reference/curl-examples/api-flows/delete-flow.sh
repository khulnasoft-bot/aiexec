curl -X DELETE \
  "$PRIMEAGFENT_URL/api/v1/flows/$FLOW_ID" \
  -H "accept: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY"
