curl http://127.0.0.1:9180/apisix/admin/plugin_configs/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PATCH -d ' 
{
  "plugins": {
    "traffic-split": {
      "rules": [
        {
          "weighted_upstreams": [      
            {
              "upstream_id": 2,
              "weight": 1
            },
            {
              "weight": 1
            }
          ]
        }
      ]
    }
  }
}'