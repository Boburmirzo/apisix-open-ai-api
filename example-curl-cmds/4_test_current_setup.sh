curl http://127.0.0.1:9080/openai/product/desc -X POST -d \
'{
   "model":"text-davinci-003",
   "prompt":"Write a brief product description for Apple 13 pro",
   "temperature":0,
   "max_tokens":256
}'