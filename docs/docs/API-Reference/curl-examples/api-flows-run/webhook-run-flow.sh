curl -X POST \
  "$PRIMEAGFENT_SERVER_URL/api/v1/webhook/$FLOW_ID" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY" \
  -d '{"data": "example-data"}'
