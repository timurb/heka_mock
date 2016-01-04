require "spec/test_helper"

describe("encoder_raw", function()
  it("processes message", function ()
    reset_all() -- run this before every test

    dofile "encoder_raw.lua"       -- don't use "require", use "dofile"
    mock_read_message({Severity=7,Timestamp=1451844654000000000})

    process_message()
    assert.is.equal('{Payload=\'{Severity=7,Timestamp=1451844654000000000}\',Fields__payload_type=\'json\',Fields__payload_name=\'message_table\'}', injected())
  end)
end)
