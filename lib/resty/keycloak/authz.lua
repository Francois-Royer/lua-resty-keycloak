local version = require "resty.keycloak.api.version"
local Request = require "resty.keycloak.api.request" 
local Protection = require "resty.keycloak.api.protection"
local Entitlement = require "resty.keycloak.api.entitlement"
local ResourceSet = require "resty.keycloak.api.resourceset"

local utils = require "resty.keycloak.common.utils"


local Authz = { _VERSION = version }
local Authz_mt = { __index = Authz }

function Authz:new(opt)
  return setmetatable({
    discovery_url = opt.keycloak_url .. ".well-known/uma-configuration",
    client_id = opt.client_id,
    client_secret = opt.client_secret,
    conf = nil
  }, Authz_mt)
end


function Authz:discovery()
  local request = Request:new()
  local conf,err = request:get(self.discovery_url)
  if err ~= nil then
    ngx.log(ngx.ERR, err)
    return nil, err
  end
  
  return conf;
end


function Authz:initialize()
  self.conf = self:discovery(self.discovery_uri)  
  self.protection = Protection:new(self.conf, self.client_id, self.client_secret)
  self.protection:initialize()
  
  local resource_set = self.protection:resource_set_list()
  self.resources = ResourceSet:new(resource_set)
  
  self.entitlement = Entitlement:new(self.conf, self.client_id)
end


function Authz:is_authorize(access_token, path)
  local resource = self.resources:match(path)
  
  if resource == nil then
    return false
  end
  
  local entitlements = self.entitlement:get_all_entitlement(access_token)
  if entitlements == nil then 
    ngx.log(ngx.ERR, "cannot get entitlement")
    return false
  end
  
  local permissions = entitlements["authorization"]["permissions"]
  
  for _,permission in pairs(permissions) do
    if resource.id == permission.resource_set_id then
      ngx.log(ngx.DEBUG, "access granted :".. permission.resource_set_name)
      return true
    end
    ngx.log(ngx.DEBUG, "cannot find resouces for " .. path)
  end
  return false
end
  

return Authz