curl -X POST \
  "$PRIMEAGFENT_SERVER_URL/api/v1/run/$FLOW_ID" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY" \
  -H "X-PRIMEAGFENT-GLOBAL-VAR-OPENAI_API_KEY: sk-..." \
  -H "X-PRIMEAGFENT-GLOBAL-VAR-USER_ID: user123" \
  -H "X-PRIMEAGFENT-GLOBAL-VAR-ENVIRONMENT: production" \
  -d '{
    "input_value": "Tell me about something interesting!",
    "input_type": "chat",
    "output_type": "chat"
  }'
