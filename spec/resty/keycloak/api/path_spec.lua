
require 'busted.runner'()
local ResourceSet = require("resty.keycloak.api.resourceset")
local utils = require("resty.keycloak.common.utils")

local resource_set ={
  ["/index.jsp"] = {
    id = "1",
    name = "index resource",
    uri = "/index.jsp"
  },

  ["/api/*"] = {
    id = "2",
    name = "api resource",
    uri = "/api/*"
  },


  ["/api/admin/*"] = {
    id = "3",
    name = "admin resource",
    uri = "/api/admin/*"
  },

  ["/api/admin/*.json"] = {
    id = "4",
    name = "admin resource with suffix",
    uri = "/api/admin/*.json"
  },
  
  ["/*"] = {
    id = "5",
    name = "default resource",
    uri = "/*"
  },
}


local resources = ResourceSet:new(resource_set);

describe("path matching", function()

  it("match existing resource", function()     
    local resource = resources:match("/index.jsp")
    assert.same(resource, resource_set["/index.jsp"])
  end)

  it("match wildcard resource if not match.", function()
    local resource = resources:match("/resource")
    assert.same(resource, resource_set["/*"])
    
  end)

  it("match more strictry", function()
    local resource = resources:match("/api/person/")
    assert.same(resource, resource_set["/api/*"])

  end)
  
  
  it("match wildcard resource if not match.", function()
    local resource = resources:match("/api/admin/sample.json")
    assert.same(resource, resource_set["/api/admin/*.json"])


  end)
  it("match wildcard resource if not match.", function()
    local resource = resources:match("/api/admin/persons")
    assert.same(resource, resource_set["/api/admin/*"])
  end)
end)

