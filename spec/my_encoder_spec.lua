package.path = "../?.lua;./?.lua;spec/?.lua;" .. package.path

require "test_helper"

default_config({ Type="my_type" }) --

describe("my_encoder", function()
  it("accepts table and sends out message", function ()
    reset_payload()               -- run this before every test

    mock_read_config({foo="bar"}) -- define config parameters in
                                  -- addition to default_config as needed

    dofile "my_encoder.lua"       -- don't use "require", use "dofile"

    send_message({foo="bar"})

    assert.is.equal('{"foo":"bar"}', _injected)
  end)
end)
