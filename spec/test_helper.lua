_G.cjson = require "cjson"

-- Reset payload at the start of the test suite
function _G.reset_payload( )
  _G._payload = {}
  _G._injected = nil
end
reset_payload( )

--
-- Stubs for Heka functions.
--   See Heka docs for details.
--
function _G.add_to_payload( value )
  table.insert(_payload, value)
end

-- Several consecutive messages are concated as strings with "|D|"" as delimiter
function _G.inject_payload()
  result = ""
  for _,x in ipairs(_payload) do
    result = result .. x
  end
  if _injected then
    _G._injected = _G._injected .. "|D|" .. result
  else
    _G._injected = result
  end
  _G._payload = {}
end

-- Mock "read_config" heka function
-- Pass k:v pairs for config values and params
function mock_read_config( keys )

  _G._config_keys = _G._default_config

  if keys then
    for k,v in pairs(keys) do
      _G._config_keys[k] = v
    end
  end

  function _G.read_config( value )
    keys = _G._config_keys
    if not keys then
      keys = {}
    end

    for k,v in pairs(keys) do
      if value == k then return v end
    end
    return nil
  end
end

-- Use this func to set default config params to use in mock_read_config()
-- This function does NOT create any mocks
function default_config( config )
  if config then
    _G._default_config = config
  else
    _G._default_config = {}
  end
end
default_config()
