curl -X PUT \
  "$PRIMEAGFENT_URL/api/v2/files/$FILE_ID?name=new_file_name" \
  -H "accept: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY"
