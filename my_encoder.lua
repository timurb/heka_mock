--
-- Example Heka encoder to illustrate testing of Lua functions
--

require "cjson"

-- Define this config in "default_config()"
msg_type = read_config("Type")

-- We are testing this function
function send_message( buffer )
  add_to_payload(cjson.encode(buffer))
  inject_payload()
end

-- We are NOT testing this function. No reason for that, just an example.
function process_message ()
  local msg = decode_message(read_message("raw"))

  msg.Type = msg_type

  send_message(msg)

  return 0
end
