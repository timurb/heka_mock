require "spec/heka_mock"

_G.cjson = require "cjson"

describe("encoder_json", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "encoder_json.lua"       -- don't use "require", use "dofile"
    mock_read_message({
      Payload="original",
      Type="my_type",
      Pid=12345,
      Severity=4,
      Timestamp=54321
    })

    process_message()
    code = "return " .. injected()
    result = assert(loadstring(code))()
    assert.is.table(result)
    assert.is.equal("json", result.Fields__payload_type)
    assert.is.equal("message_table", result.Fields__payload_name)

    payload = result.Payload
    assert.is.string(payload)

    payload = cjson.decode(payload)
    assert.is.table(payload)
    assert.is.equal("original", payload.Payload)
    assert.is.equal("my_type", payload.Type)
    assert.is.equal(12345, payload.Pid)
    assert.is.equal(4, payload.Severity)
    assert.is.equal(54321, payload.Timestamp)
  end)
end)
