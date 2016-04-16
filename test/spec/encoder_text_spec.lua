require "heka_mock"
require "spec/test_helper"

describe("encoder_text", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "encoder_text.lua"       -- don't use "require", use "dofile"
    mock_read_message(test_message)

    process_message()
    result = injected()[1]
    assert.is.equal("Prefixed original", result.Payload)
    assert.is.equal("txt", result.Fields.payload_type)
    assert.is.equal("", result.Fields.payload_name)
  end)
end)
