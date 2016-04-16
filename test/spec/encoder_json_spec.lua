require "heka_mock"
require "spec/test_helper"

_G.cjson = require "cjson"

describe("encoder_json", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "encoder_json.lua"       -- don't use "require", use "dofile"
    mock_read_message(test_message)

    process_message()
    result = injected()[1]
    assert.is.equal("json", result.Fields.payload_type)
    assert.is.equal("message_table", result.Fields.payload_name)

    payload = result.Payload
    assert.is.string(payload)

    payload = cjson.decode(payload)
    assert.is.table(payload)
    assert.is.equal(54321, payload.Timestamp)
    assert.is.equal(12345, payload.Pid)
    assert.is.equal(4, payload.Severity)
    assert.is.equal("hostname", payload.Hostname)
    assert.is.equal("original", payload.Payload)
    assert.is.equal("my_type", payload.Type)
  end)
end)
