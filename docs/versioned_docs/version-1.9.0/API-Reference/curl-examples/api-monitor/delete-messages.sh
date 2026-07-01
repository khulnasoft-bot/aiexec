curl -v -X DELETE \
  "$PRIMEAGFENT_URL/api/v1/monitor/messages" \
  -H "accept: */*" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY" \
  -d '["MESSAGE_ID_1", "MESSAGE_ID_2"]'
