curl -X POST \
  "$PRIMEAGFENT_URL/api/v1/build/$FLOW_ID/flow" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY" \
  -d '{"stop_component_id": "OpenAIModel-Uksag"}'
