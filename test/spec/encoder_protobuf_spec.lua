require "heka_mock"
require "spec/test_helper"

describe("encoder_protobuf", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "encoder_protobuf.lua"       -- don't use "require", use "dofile"
    mock_read_message(test_message)

    process_message()
    result = injected()[1]
    assert.is.equal(54321, result.Timestamp)
    assert.is.equal(12345, result.Pid)
    assert.is.equal(4, result.Severity)
    assert.is.equal("hostname", result.Hostname)
    assert.is.equal("mutated", result.Payload)
    assert.is.equal("after", result.Type)
  end)
end)
