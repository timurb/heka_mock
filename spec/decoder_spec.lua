require "spec/heka_mock"

_G.lpeg = require "lpeg"

describe("decoder", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "decoder.lua"       -- don't use "require", use "dofile"
    mock_read_message({Payload="1376389920 debug id=2321 url=example.com item=1"})

    process_message()
    assert.is.equal('{Fields={id=\'2321\',item=\'1\',url=\'example.com\'},Severity=\'7\',Timestamp=\'1376389920000000000\'}', injected())
  end)
end)
