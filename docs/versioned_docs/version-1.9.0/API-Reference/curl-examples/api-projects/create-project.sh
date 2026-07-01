curl -X POST \
  "$PRIMEAGFENT_URL/api/v1/projects/" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY" \
  -d '{
  "name": "new_project_name",
  "description": "string",
  "components_list": [],
  "flows_list": []
}'
