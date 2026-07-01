curl -X GET \
  "$PRIMEAGFENT_URL/api/v1/flows/?remove_example_flows=false&components_only=false&get_all=true&header_flows=false&page=1&size=50" \
  -H "accept: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY"
