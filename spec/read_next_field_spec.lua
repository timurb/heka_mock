require "spec/heka_mock"

describe("read_next_field", function()
  before_each(function()
    reset_all()
  end)

  it("processes message", function ()
    dofile "read_next_field.lua"       -- don't use "require", use "dofile"
    mock_read_message(test_next_field)

    err, msg = process_message()
    assert.is.equal(0, err)
    -- result = injected()[1]
    -- assert.is.equal("7", result.Severity)
    -- assert.is.equal("1376389920000000000", result.Timestamp)
    -- assert.is.table(result.Fields)
    -- assert.is.equal("2321", result.Fields.id)
    -- assert.is.equal("1", result.Fields.item)
    -- assert.is.equal("example.com", result.Fields.url)
  end)
end)
