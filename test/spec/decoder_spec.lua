require "heka_mock"

_G.lpeg = require "lpeg"

describe("decoder", function()
  before_each(function()
    reset_all()
  end)

  it("processes message", function ()
    dofile "decoder.lua"       -- don't use "require", use "dofile"
    mock_read_message({Payload="1376389920 debug id=2321 url=example.com item=1"})

    process_message()
    result = injected()[1]
    assert.is.equal("7", result.Severity)
    assert.is.equal("1376389920000000000", result.Timestamp)
    assert.is.table(result.Fields)
    assert.is.equal("2321", result.Fields.id)
    assert.is.equal("1", result.Fields.item)
    assert.is.equal("example.com", result.Fields.url)
  end)

  it("decodes invalid message", function ()
    dofile "decoder.lua"       -- don't use "require", use "dofile"
    mock_read_message({Payload="1376389920 bogus id=2321 url=example.com item=1"})

    err, msg = process_message()
    assert.is.equal(-1, err)
    assert.is.equal('LPeg grammar failed to match', msg)

    result = injected()
    assert.is.equal(0, #result)
  end)
end)
