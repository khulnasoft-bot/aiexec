curl -X GET \
  "$PRIMEAGFENT_URL/logs-stream" \
  -H "accept: text/event-stream" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY"
