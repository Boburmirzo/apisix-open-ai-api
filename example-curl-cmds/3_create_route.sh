curl -i http://127.0.0.1:9180/apisix/admin/routes/1 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
   "name":"OpenAI API completion route",
   "desc":"Create a new route in APISIX for the OpenAI API completion endpoint",
   "methods":[
      "POST"
   ],
   "uri":"/openai/product/desc",
   "upstream_id":"1",
   "plugin_config_id":1
}'