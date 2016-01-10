require "spec/heka_mock"

describe("Heka mocks", function()
  describe("inject_payload()", function()
    before_each(function()
      reset_payload()
    end)

    it("works with add_to_payload()", function ()
      add_to_payload("foo")
      inject_payload()
      result = injected()
      assert.is.table(result)
      assert.is.equal(1, #result)
      msg = result[1]
      assert.is.table(msg)
      assert.is.equal("foo", msg.Payload)
      assert.is.table(msg.Fields)
    end)

    it("joins 2 consecutive add_to_payload()", function ()
      add_to_payload("foo")
      add_to_payload("bar")
      inject_payload()
      result = injected()
      assert.is.equal(1, #result)
      msg = result[1]
      assert.is.equal("foobar", msg.Payload)
    end)

    it("accepts payload as params", function()
      inject_payload(nil,nil,"bar","baz")
      result = injected()
      assert.is.equal(1, #result)
      msg = result[1]
      assert.is.equal("barbaz", msg.Payload)
    end)

    it("NOT SUPPORTED IN HEKA: works without payload ", function()
      inject_payload(nil,nil)
      result = injected()
      assert.is.table(result)
      assert.is.equal(1, #result)
      msg = result[1]
      assert.is.equal("", msg.Payload)
    end)

    it("accepts type and name as params", function()
      inject_payload("foo","bar","baz")
      result = injected()
      assert.is.equal(1, #result)
      msg = result[1]
      assert.is.equal("baz", msg.Payload)
      fields = msg.Fields
      assert.is.table(fields)
      assert.is.equal("foo", fields.payload_type)
      assert.is.equal("bar", fields.payload_name)
    end)
  end)

  -- this function is used only in tests
  describe("NOT SUPPORTED IN HEKA: reset_payload()", function()
    it("resets payload", function ()
      reset_payload()
      add_to_payload("foo")
      reset_payload()
      add_to_payload("bar")
      inject_payload()
      result = injected()
      assert.is.equal(1, #result)
      msg = result[1]
      assert.is.equal("bar", msg.Payload)
    end)
  end)

  describe("read_message()", function()
    before_each(function()
      reset_all()
    end)

    it("returns mocked field", function()
      mock_read_message({foo="bar"})

      local msg = read_message("foo")
      assert.is.equal("bar", msg)
    end)

    it("processes payload as any other field", function()
      mock_read_message({Payload="1451844654 debug"})

      local msg = read_message("Payload")
      assert.is.equal("1451844654 debug", msg)
    end)

    it("returns raw message when asked", function()
      mock_read_message({foo="bar"})

      local msg = read_message("raw")
      assert.is.equal("bar", msg.foo)
    end)
  end)
end)
