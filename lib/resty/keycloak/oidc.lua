local version = require "resty.keycloak.version"

local Oidc = { _VERSION = version }
local Oidc_mt = { __index = Oidc }

local Request = require "resty.keycloak.api.request" 
local utils = require "resty.keycloak.common.utils"
local oidc = require "resty.openidc"

function Oidc:new(opt)
  return setmetatable({
    keycloak_uri = opt.keycloak_uri,
    discovery_uri = opt.keycloak_uri .. ".well-known/openid-configuration"
  },Oidc_mt)
end

function Oidc:get_public_key()
  local request = Request:new()
  local result, err = request:get(self.keycloak_uri)
  
  return utils.to_pem(result.public_key)
end

function Oidc:validate_token(token)
  local secret = self:get_public_key() 
  local opts = {
    discovery = self.discovery_uri,
    secret = secret
  }
  
  local res,err = oidc.bearer_jwt_verify(opts)
  
  return res, err
end



return Oidc