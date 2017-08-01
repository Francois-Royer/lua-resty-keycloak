local http = require "resty.http"
local cjson = require "cjson"

local version = require "resty.keycloak.version"
local utils = require "resty.keycloak.common.utils"

local Request = { _VERSION= version}
local Request_mt = { __index = Request }


function Request:new()
  local httpc = http.new()
  return setmetatable({
    httpc = httpc,
    headers = {}
  },Request_mt)
end

function Request:get(uri)
  local res, err = self.httpc:request_uri(uri, {
    method = "GET",
    headers = self.headers
  })
  if err or res == nil then 
    return nil, err
  end
  
  local json = cjson.decode(res.body)
  return json
end

function Request:post(uri, body)
  local res, err = self.httpc:request_uri(uri, {
    method = "POST",
    headers = self.headers,
    body = ngx.encode_args(body)
  })
  utils.print_r(res)
  if err or res == nil then
    return res, err
  end

  local json = cjson.decode(res.body)

  return json
end

function Request:add_bearer_auth(token)
  self.headers["Authorization"] = "Bearer "..token
end

function Request:add_basic_auth(id, secret)
  self.headers["Authorization"] = "Basic " .. ngx.encode_base64(id..":"..secret)
end

function Request:add_header(name, value)
  self.headers[name] = value
end

return Request