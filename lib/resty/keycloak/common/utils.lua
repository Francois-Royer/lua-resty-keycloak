local http = require "resty.http"
local cjson = require "cjson"


local _M = {_VERSION="1.0.0"}
local mt = { __index = _M }

function _M.to_pem(key)
  if key == nil then
    return nil
  end
  local pem = "-----BEGIN PUBLIC KEY-----\n"
  for i=1,#key,64 do
    pem = pem..string.sub(key, i, i+63).."\n"
  end
  pem = pem.."-----END PUBLIC KEY-----"
  return pem

end

return _M
