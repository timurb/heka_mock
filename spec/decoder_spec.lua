require "spec/test_helper"

_G.lpeg = require "lpeg"

describe("decoder", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "decoder.lua"       -- don't use "require", use "dofile"
    mock_read_message({Payload="1451844654 debug"})

    process_message()
    assert.is.equal('{Payload=\'{Fields={},Severity=7,Timestamp=1451844654000000000}\'}', injected())
  end)
end)
