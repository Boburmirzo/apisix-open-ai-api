curl "http://127.0.0.1:9180/apisix/admin/upstreams/1" -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "name": "OpenAI API upstream",
  "desc": "Add the OpenAI API domain as the upstream",
  "type": "roundrobin",
  "scheme": "https",
  "nodes": {
    "api.openai.com:443": 1
  }
}'