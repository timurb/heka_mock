package.path = "../?.lua;./?.lua;spec/?.lua;" .. package.path

_ = require "underscore"

local payload
local injected_messages
local delimiter = nil
local default_config

-- Reset payload at the start of the test suite
function reset_payload( )
  payload = {}
  injected_messages = nil
end
reset_payload()

function reset_config()
  _G.read_config = nil
end

function reset_message()
  _G.read_message = nil
end

function reset_all()
  reset_payload()
  reset_config()
  reset_message()
end

--
-- Stubs for Heka functions.
--   See Heka docs for details.
--
function _G.add_to_payload(value)
  table.insert(payload, value)
end

--- Helper function to update injected messages
function _add_to_injected( msg )
  -- Lua doesn't support equality of arrays in assertions that's why we use strings here
  if injected_messages then
    injected_messages = injected_messages .. delimiter .. msg
  else
    injected_messages = msg
  end
end

-- Several consecutive messages are concated as strings
-- "payload_type" and "payload_name" params are ignored
function _G.inject_payload(payload_type, payload_name, ...)

  for _, x in ipairs({...}) do
     add_to_payload(x)
  end

  string_payload = {}
  for _, k in ipairs(payload) do
    table.insert(string_payload, tostring_sorted(k))
  end
  local msg = { format_payload(table.concat(string_payload)) }


  table.insert(msg, format_kv("Fields__payload_type", payload_type))
  table.insert(msg, format_kv("Fields__payload_name", payload_name))

  local result = bracketize(table.concat(msg,","))

  _add_to_injected(result)

  payload = {}
end

function _G.inject_message(msg)
--  inject_payload(nil, nil, tostring_sorted(msg))
  _add_to_injected(msg)
  payload = {}
end

function injected()
  return injected_messages
end

function _G.write_message()
  error("write_message() is not implemented")
end

function _G.decode_message()
  error("decode_message() is not implemented")
end

-- Mock "read_config" heka function
-- Pass k:v pairs for config values and params
function mock_read_config(keys)
  local config_keys = {}

  for k,v in pairs(default_config) do
    config_keys[k] = v
  end

  if keys then
    for k,v in pairs(keys) do
      config_keys[k] = v
    end
  end

  function _G.read_config(key)
    for k,v in pairs(config_keys) do
      if key == k then return v end
    end

    return nil
  end
end

-- Mock "read_message" heka function
-- Pass k:v pairs for config values and params
function mock_read_message(keys)
  local msg = {}

  if keys then
    for k,v in pairs(keys) do
      msg[k] = v
    end
  end

  function _G.read_message(key)
    if key == "raw" then
      return msg
    end

    for k,v in pairs(msg) do
      if key == k then return v end
    end

    return nil
  end
end

-- Use this func to set default config params to use in mock_read_config()
-- This function does NOT create any mocks
function set_default_config(config)
  if config then
    default_config = config
  else
    default_config = {}
  end
end
set_default_config()

----
---- Helper functions
----

---- Formatting functions

function format_payload(val)
  if val and #val > 0 then
    return string.format("Payload='%s'", val)
  else
    return "Payload=nil"
  end
end

function format_kv(key, val)
  if val then
    return string.format("%s=\'%s\'", key, val)
  else
    return nil
  end
end


-- Convert object to string with sorting of tables
-- Note: doesn't support mixed tables
function tostring_sorted(val, quote)
  if type(val) == "number" then
    return string.format("%d", val)
  elseif type(val) == "boolean" then
    return string.format("%s", val)
  elseif type(val) == "string" then
    if quote then
      return string.format("'%s'", val)
    else
      return val
    end
  elseif type(val) ~= "table" then
    error("Unsupported type:" .. type(val))
  end

  local keys = _.keys(val)
  table.sort(keys)

  local result = {}

  _.each(keys, function(key)
    if type(key) == "number" then
      key = tostring_sorted(val[key], true)
    else
      key = string.format("%s=%s", key, tostring_sorted(val[key], true))
    end
    table.insert(result, key)
  end)

  result = bracketize(table.concat(result, ","))

  return result
end

-- A function to enclose value into brackets
function bracketize(val)
  return '{' .. val .. '}'
end
