local http = require "resty.http"
local cjson = require "cjson"

local version = require "resty.keycloak.version"
local utils = require "resty.keycloak.common.utils"

local ResourceSet = { _VERSION = version }
local ResourceSet_mt = { __index = ResourceSet }


local Path = { _VERSION = version }
local Path_mt = { __index = Path }

function Path:new(path)
  return setmetatable({
    path = path
  },Path_mt)
end

function Path:value()
  return self.path
end

function Path:suffix() 
  return self.path:match("/%*(.%w+)$")
end

function Path:startsWith(prefix)
  return self.path:sub(1,#prefix) == prefix
end

function Path:endsWith(suffix)
  return suffix=='' or self.path:sub(-#suffix)==suffix
end

function Path:depth()
  return #self:split()
end

function Path:split() 
  local result = {}
  local pat = "(.-)/()"
  local lastPos
  for part, pos in string.gfind(self.path, pat) do
    table.insert(result, part)
    lastPos = pos
  end
  table.insert(result, string.sub(self.path, lastPos))
  return result
end



function ResourceSet:new(resource_set) 
  local resources = {}
  for _,v in pairs(resource_set) do
    v["path"] = Path:new(v["uri"])
    resources[v["uri"]] = v
  end
  return setmetatable({
    resources = resources
  }, ResourceSet_mt)
end

function ResourceSet:match(uri)
  local path_config = self.resources[uri]
  if path_config then
    return path_config
  end
  
  local path = Path:new(uri);
  
  local keys = {}
  local n = 0
  
  for k,v in pairs(self.resources) do
    n = n+1
    keys[n] = k
  end
  
  table.sort(keys,function(a,b)
    local depth = self.resources[a]["path"]:depth() > self.resources[b]["path"]:depth()
    local suffix = (self.resources[a]["path"]:suffix() ~= nil)
    return  depth or suffix
  end)
  
  for i,key in pairs(keys) do
    local entry = self.resources[key]
    local target = entry["path"]
    -- match wild card uri
    if target:endsWith("/*") then
      local uri = string.sub(target:value(), 1, #target:value() -1)
      if path:startsWith(uri) then
        return  entry
      end
    end
    
    -- match wild card with suffix
    local suffix = target:suffix()
    if suffix ~= nil then
      local base = string.sub(target:value(), 1, #target:value() - #suffix -1 )
      if path:startsWith(base) and path:endsWith(suffix) then
        return entry
      end
    end
  end

  return nil
end


return ResourceSet
