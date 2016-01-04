require "spec/test_helper"

describe("encoder_text", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "encoder_text.lua"       -- don't use "require", use "dofile"
    mock_read_message({Payload="original"})

    process_message()
    assert.is.equal('{Payload=\'Prefixed original\',Fields__payload_type=\'txt\',Fields__payload_name=\'\'}', injected())
  end)
end)
