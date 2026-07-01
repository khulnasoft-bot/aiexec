curl -X GET \
  "$PRIMEAGFENT_URL/api/v1/users/whoami" \
  -H "accept: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY"
