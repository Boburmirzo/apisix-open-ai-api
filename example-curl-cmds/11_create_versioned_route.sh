curl -i http://127.0.0.1:9180/apisix/admin/routes/2 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
   "name":"OpenAI API completion route",
   "desc":"Create a new route in APISIX for the OpenAI API completion endpoint",
   "methods":[
      "POST"
   ],
   "uri":"/openai/product/desc",
   "uris": ["/v1/openai/product/desc", "/v1/openai/product/desc/", "/v1/openai/product/desc/*"],
   "upstream_id":"1",
   "plugin_config_id":1
}'

#Test new versioned route

curl -i -u username1:password1 http://127.0.0.1:9080/v1/openai/product/desc  -X POST -d \
'{
   "model":"text-davinci-003",
   "prompt":"Write a brief product description for Apple 13 pro",
   "temperature":0,
   "max_tokens":256
}'