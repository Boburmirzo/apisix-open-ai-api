curl -L http://127.0.0.1:9180/apisix/admin/plugin_configs/2 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d ' 
{
  "plugins": {
    "redirect": {
      "uri": "/v1$uri",
      "ret_code": 301
    }
  }
}'