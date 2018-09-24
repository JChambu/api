require 'faraday'
require 'oj'

client = Faraday.new(url: 'http://localhost:3000') do |config|
    config.adapter  Faraday.default_adapter
      config.token_auth('34a80f7c8371a97d15b07e430b97529e')
end
 
response = client.post do |req|
    req.url '/api/v1/project_types'
      req.headers['Content-Type'] = 'application/json'
        req.body = '{ "project_type_params": {"name": "prueba"} }'
end
