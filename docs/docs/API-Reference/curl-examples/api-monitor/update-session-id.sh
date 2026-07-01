curl -X PATCH \
  "$PRIMEAGFENT_URL/api/v1/monitor/messages/session/01ce083d-748b-4b8d-97b6-33adbb6a528a?new_session_id=different_session_id" \
  -H "accept: application/json" \
  -H "x-api-key: $PRIMEAGFENT_API_KEY"
