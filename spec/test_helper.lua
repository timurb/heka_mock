local payload
local injected_messages
local delimiter = '-|-'
local default_config

-- Reset payload at the start of the test suite
function reset_payload( )
  payload = {}
  injected_messages = nil
end
reset_payload( )

--
-- Stubs for Heka functions.
--   See Heka docs for details.
--
function _G.add_to_payload( value )
  table.insert(payload, value)
end

-- Several consecutive messages are concated as strings with "|D|"" as delimiter
function _G.inject_payload()
  local result = ''

  for _,x in ipairs(payload) do
    result = result .. x
  end

  -- Lua doesn't support equality of arrays that's why we use strings here
  if injected_messages then
    injected_messages = injected_messages .. delimiter .. result
  else
    injected_messages = result
  end

  payload = {}
end

function injected()
  return injected_messages
end

-- Mock "read_config" heka function
-- Pass k:v pairs for config values and params
function mock_read_config( keys )
  local config_keys = {}

  for k,v in pairs(default_config) do
    config_keys[k] = v
  end

  if keys then
    for k,v in pairs(keys) do
      config_keys[k] = v
    end
  end

  function _G.read_config( key )
    local keys = config_keys

    for k,v in pairs(keys) do
      if key == k then return v end
    end

    return nil
  end
end

-- Use this func to set default config params to use in mock_read_config()
-- This function does NOT create any mocks
function set_default_config( config )
  if config then
    default_config = config
  else
    default_config = {}
  end
end
set_default_config()
