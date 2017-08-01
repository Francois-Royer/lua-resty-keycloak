local http = require "resty.http"
local cjson = require "cjson"
local jwt = require "resty.jwt"

local version = require "resty.keycloak.version"
local utils = require "resty.keycloak.common.utils"
local Request = require "resty.keycloak.api.request"

local Entitlement = { _VERSION = version }
local Entitlement_mt = { __index = Entitlement }


function Entitlement:new(configuration,client_id)
  return setmetatable({
    client_id = client_id,
    entitlement_endpoint = configuration.serverUrl .. "/authz/entitlement/" .. client_id,
    public_key = utils.to_pem(configuration.realmPublicKey)
  }, Entitlement_mt)
end

function Entitlement:get_all_entitlement(access_token)
  local request = Request:new()
  request:add_bearer_auth(access_token)
  request:add_header("Content-Type", "application/json")
  
  local response, err = request:get(self.entitlement_endpoint)
  if err then
    ngx.log(ngx.ERR, err)
    return nil, err
  end
  
  local jwt_obj = jwt:verify(self.public_key,response.rpt)

  return jwt_obj["payload"]
end



return Entitlement

