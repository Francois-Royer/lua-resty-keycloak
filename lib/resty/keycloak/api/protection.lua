local http = require "resty.http"
local cjson = require "cjson"

local version = require "resty.keycloak.version"

local Request = require "resty.keycloak.api.request"

local Protection = { _VERSION = version}
local Protection_mt = { __index = Protection }


function Protection:new(configuration, client_id, client_secret)
  return setmetatable({
    token_endpoint = configuration.token_endpoint,
    resource_set_registration_endpoint = configuration.resource_set_registration_endpoint,
    client_id = client_id,
    client_secret = client_secret,
    
    token = nil
  }, Protection_mt)
end


function Protection:initialize()
  local request = Request:new();
  request:add_basic_auth(self.client_id, self.client_secret)
  request:add_header("Content-Type", "application/x-www-form-urlencoded")

  local body = {
    grant_type = "client_credentials"
  }

  local response,err = request:post(self.token_endpoint,body)
      ngx.log(ngx.ERR, cjson.encode(response))
  if err then
    ngx.log(ngx.ERR, response)
    return nil,err
  end
  self.token = response
end

function Protection:resource_set(id)
  if self.token == nil then
    return nil, "not initialized"
  end
  
  local request = Request:new();
  request:add_bearer_auth(self.token.access_token)
  local resource_set, err = request:get(self.resource_set_registration_endpoint.."/"..id )
  
  return resource_set
end

function Protection:resource_set_list()
  if self.token == nil then
    return nil, "not initialized"
  end
  
  local request = Request:new()
  
  request:add_bearer_auth(self.token.access_token)
  local resource_ids,err = request:get(self.resource_set_registration_endpoint)

  local results = {}
  
  for index,id in ipairs(resource_ids) do 
    local response = self:resource_set(id)
    results[id] = response
  end
  
  return results
end


return Protection
