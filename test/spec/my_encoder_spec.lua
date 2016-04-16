require "heka_mock"

_G.cjson = require "cjson"

set_default_config({ Type="my_type" }) --

describe("my_encoder", function()
  it("accepts table and sends out message", function ()
    reset_all()                   -- run this before every test

    mock_read_config({foo="bar"}) -- define config parameters in
                                  -- addition to default_config as needed

    dofile "my_encoder.lua"       -- don't use "require", use "dofile"

    send_message({foo="bar"})
    result = injected()[1]

    assert.is.equal('{"foo":"bar"}', result.Payload)
  end)
end)
