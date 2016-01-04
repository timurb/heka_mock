require "spec/heka_mock"
require "spec/test_helper"

describe("encoder_protobuf", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "encoder_protobuf.lua"       -- don't use "require", use "dofile"
    mock_read_message(test_message)

    process_message()
    assert.is.equal('{Payload=\'{Hostname=\'hostname\',Payload=\'mutated\',Pid=12345,Severity=4,Timestamp=54321,Type=\'after\'}\'}', injected())
  end)
end)
