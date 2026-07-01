curl -X POST \
  "$PRIMEAGFENT_URL/api/v1/users/" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY" \
  -d '{
    "username": "newuser2",
    "password": "securepassword123"
  }'
