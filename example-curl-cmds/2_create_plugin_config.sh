curl http://127.0.0.1:9180/apisix/admin/plugin_configs/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d ' 
{
   "plugins":{
      "proxy-rewrite":{
         "uri":"/v1/completions",
         "host":"api.openai.com",
         "headers":{
            "Authorization":"OpenAI API Key",
            "Content-Type":"application/json"
         }
      }
   }
}'