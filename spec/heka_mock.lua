package.path = "../?.lua;./?.lua;spec/?.lua;" .. package.path

_ = require "underscore"

local payload
local injected_messages
local delimiter = nil
local default_config

-- Reset payload at the start of the test suite
function reset_payload( )
  payload = {}
  injected_messages = {}
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

function _G.inject_payload(payload_type, payload_name, ...)

  for _, x in ipairs({...}) do
     add_to_payload(x)
  end

  local fields = {}
  fields.payload_type = payload_type
  fields.payload_name = payload_name

  local msg = {}
  msg.Payload = table.concat(payload, delimiter)
  msg.Fields = fields

  _add_to_injected(msg)

  payload = {}
end

function _G.inject_message(msg)
  _add_to_injected(msg)
  payload = {}
end

function _G.write_message()
  error("write_message() is not implemented")
end

function _G.decode_message()
  error("decode_message() is not implemented")
end

--- Helper function to handle injected messages

function _add_to_injected(msg) -- not for public use
  table.insert(injected_messages, msg)
end

function injected()
  return injected_messages
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

-- Helper function to set default config params for use in several mock_read_config() calls
-- This function does NOT create any mocks
function set_default_config(config)
  if config then
    default_config = config
  else
    default_config = {}
  end
end
set_default_config()
