# Initial step, just request directly OpenAI API without the API Gateway
# Typical request to OpenAI API completion endpoint

curl https://api.openai.com/v1/completions \
-H "Content-Type: application/json" \
-H "Authorization: Bearer {OpenAI API Key}" \
-d '{"model": "text-davinci-003", "prompt": "Say this is a test", "temperature": 0, "max_tokens": 7}'

# Request through the API Gateway

# http://mywebsitedomain.com/openai/product/desc -----> https://api.openai.com/v1/completions
# How the final request should like like. 
curl http://127.0.0.1:9080/openai/product/desc  -X POST -d 
'{
   "model":"text-davinci-003",
   "prompt":"Write a brief product description for Apple 13 pro",
   "temperature":0,
   "max_tokens":256
}'

# Step 1: Create an Upstream for the OpenAI API

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

# Step 2: Create a new plugin config

curl http://127.0.0.1:9180/apisix/admin/plugin_configs/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d ' 
{
   "plugins":{
      "proxy-rewrite":{
         "uri":"/v1/completions",
         "host":"api.openai.com",
         "headers":{
            "Authorization":"Bearer {OpenAI API Key}",
            "Content-Type":"application/json"
         }
      }
   }
}'

# Step 3: Set up a Route for the OpenAI completion endpoint

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

# Step 4: Test With a Curl Request
## The API Gateway will forward the request to the OpenAI API completion endpoint

curl -i http://127.0.0.1:9080/openai/product/desc -X POST -d \
'{
   "model":"text-davinci-003",
   "prompt":"Write a brief product description for Apple 13 pro",
   "temperature":0,
   "max_tokens":256
}'

# Step 5: Create a new consumer and add authentication

curl http://127.0.0.1:9180/apisix/admin/consumers -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "username": "consumer1",
    "plugins": {
        "basic-auth": {
            "username": "username1",
            "password": "password1"
        }
    }
}'

# Step 6: Update the existing plugin config and append basic-auth

curl http://127.0.0.1:9180/apisix/admin/plugin_configs/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d ' 
{
   "plugins":{
      "proxy-rewrite":{
         "uri":"/v1/completions",
         "host":"api.openai.com",
         "headers":{
            "Authorization":"Bearer {OpenAI API Key}",
            "Content-Type":"application/json"
         }
      },
      "basic-auth":{

      }
   }
}'

# Step 7: Provide the correct user credentials in the request and access the same endpoint

curl -i -u username1:password1 http://127.0.0.1:9080/openai/product/desc  -X POST -d \
'{
   "model":"text-davinci-003",
   "prompt":"Write a brief product description for Apple 13 pro",
   "temperature":0,
   "max_tokens":256
}'

# Step 8: Apply and test the rate-limit policy

curl http://127.0.0.1:9180/apisix/admin/plugin_configs/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d ' 
{
   "plugins":{
      "proxy-rewrite":{
         "uri":"/v1/completions",
         "host":"api.openai.com",
         "headers":{
            "Authorization":"Bearer {OpenAI API Key}",
            "Content-Type":"application/json"
         }
      },
      "basic-auth":{

      },
      "limit-count":{
         "count":2,
         "time_window":60,
         "rejected_code":403,
         "rejected_msg":"Requests are too frequent, please try again later.",
         "key_type":"var",
         "key":"remote_addr"
      }
   }
}'

# Step 9: Try to request more than 2 times within 60 seconds, and you will get HTTP Unauthorized error
curl -i -u username1:password1 http://127.0.0.1:9080/openai/product/desc  -X POST -d \
'{
   "model":"text-davinci-003",
   "prompt":"Write a brief product description for Apple 13 pro",
   "temperature":0,
   "max_tokens":256
}'

## Optional step: Enable proxy caching
curl http://127.0.0.1:9180/apisix/admin/plugin_configs/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
   "plugins":{
      "proxy-rewrite":{
         "uri":"/v1/completions",
         "host":"api.openai.com",
         "headers":{
            "Authorization":"Bearer {OpenAI API Key}",
            "Content-Type":"application/json"
         }
      },
      "basic-auth":{},
      "proxy-cache":{
         "cache_key":[
            "$uri",
            "-cache-id"
         ],
         "cache_method":[
            "POST"
         ],
         "cache_http_status":[
            200
         ],
         "hide_cache_headers":true
      }
   }
}'