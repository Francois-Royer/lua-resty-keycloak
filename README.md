# lua-resty-keycloak

``lua-resty-keycloak`` is a [Keycloak](http://www.keycloak.org) adaptar for OpenResty. 

It provide OpenID Connect Resource Server functinality with keycloak IdP server.

### Open ID connect 
It can verify ID Token from client using `lua-resty-odic`.

### Authorization Service

It can support the [Authorization Service](https://keycloak.gitbooks.io/documentation/authorization_services/index.html) provided by Keycloak. This function provides fine graind access controlle and  integrate access policy to the keycloak server.

**NOTE**: The Authoriztion Service function is limited compared with the adapter provided by Keycloak. Only provides url based access contorl.

##Author
Takashi Mogi, Hitachi,Ltd

## Installation 
**TBD**

## Usage

```lua

  local Authz = require "resty.keycloak.authz"
  local Oidc = require "resty.keycloak.oidc"

  local access_token,err = get_bearer_token() 
  
  if access_token == nil then 
    ngx.status = 403
    ngx.say(err)
    ngx.exit(ngx.HTTP_FORBIDDEN)
  end

  local opt = {
    keycloak_uri = "http://keycloak.example.com/auth/realms/example/",
    client_id = "client",
    client_secret = "client_secret"
  }
  
  -- validate access token 
  local oidc = Oidc:new(opt)
  local res, err  = oidc:validate_token(access_token)
  
  if err then
    ngx.status=403
    ngx.say(err)
    ngx.exit(ngx.HTTP_FORBIDDEN)
  end

  local authz = Authz:new(opt)
  authz:initialize()

  -- check permissions using resource set provided by keycloak server
  if not authz:is_authorize(access_token, ngx.var.uri) then
    ngx.status = 403
    ngx.exit(ngx.HTTP_FORBIDDEN)
  end

```


## TODO

- Common
  - [ ] improve error handling and logging 
  - [ ] test cases
  - [ ] use caches 
- Authorization service
  - [ ] "**Authorization Scopes**" and "**Methods**" based access control. 
  - [ ] improve path matchings between request path and resources.
    - [x]  Wildcards: /*
    - [x] Suffix: /*.html
    - [x] Sub-paths: /path/*
    - [ ] Path parameters: /resource/{id}
    - [x] Exact match: /resource
    - [ ] Patterns: /{version}/resource, /api/{version}/resource, /api/{version}/resource/*
