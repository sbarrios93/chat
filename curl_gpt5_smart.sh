#!/bin/bash
# Usage: ./curl_gpt5_smart.sh "Your prompt here"


API_URL="http://localhost:4000/v1/responses"
API_KEY="sk-1234"
MODEL="gpt-5-smart"
PROMPT="$1"

read -r -d '' PAYLOAD <<EOF
{
  "model": "$MODEL",
  "input": [{"role": "user", "content": "$PROMPT"}],
  "text": {"verbosity": "low"}
}
EOF

curl -v -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
