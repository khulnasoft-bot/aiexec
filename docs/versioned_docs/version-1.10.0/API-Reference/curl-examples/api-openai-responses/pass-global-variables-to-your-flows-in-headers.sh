curl -X POST \
  "$PRIMEAGFENT_SERVER_URL/api/v1/responses" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-PRIMEAGFENT-GLOBAL-VAR-OPENAI_API_KEY: sk-..." \
  -H "X-PRIMEAGFENT-GLOBAL-VAR-USER_ID: user123" \
  -H "X-PRIMEAGFENT-GLOBAL-VAR-ENVIRONMENT: production" \
  -d '{
    "model": "your-flow-id",
    "input": "Hello"
  }'
