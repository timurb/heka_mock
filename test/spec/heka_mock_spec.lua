require "heka_mock"
require "spec/test_helper"

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

    it("NOT SUPPORTED IN HEKA: works without payload", function()
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

    it("works when called several times", function()
      inject_payload(nil,nil,"bar")
      inject_payload(nil,nil,"baz")
      result = injected()
      assert.is.equal(2, #result)
      assert.is.equal("bar", result[1].Payload)
      assert.is.equal("baz", result[2].Payload)
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

    it("returns raw message for processing with decode_message()", function()
      -- NOTE: raw message is not compatible with Heka internals. Use it only with decode_message()
      mock_read_message({foo="bar"})

      local msg = decode_message(read_message("raw"))
      assert.is.equal("bar", msg.foo)
    end)

    it("is able to process custom fields", function()
      mock_read_message(test_message)

      local msg = read_message("Fields[foo]")
      assert.is.equal("bar", msg)
    end)
  end)

  describe("inject_message()", function ()
    before_each(function()
      reset_all()
    end)

    it("injects message", function ()
      inject_message({Payload="foo"})
      result = injected()
      assert.is.table(result)
      assert.is.equal(1, #result)
      msg = result[1]
      assert.is.table(msg)
      assert.is.equal("foo", msg.Payload)
      assert.is.table(msg.Fields)
    end)

    it("produces an error if there is some payload", function ()
      add_to_payload("foo")
      assert.has.errors(function () inject_message({Payload="foo"}) end)
    end)

    it("doesn't produces an error if there is some payload but you've run ignore_payload_error", function ()
      ignore_payload_error(true)
      add_to_payload("foo")
      assert.has_no.errors(function () inject_message({Payload="foo"}) end)
    end)
  end)

  describe("read_config()", function()
    before_each(function()
      reset_all()
    end)

    it("returns mocked config value", function()
      mock_read_config({foo="bar"})

      local cfg = read_config("foo")
      assert.is.equal("bar", cfg)
    end)

    it("returns nil when no value mocked", function()
      mock_read_config({foo="bar"})

      local cfg = read_config("baz")
      assert.is.equal(nil, cfg)
    end)
  end)

  describe("decode_message()", function()
    it("decodes message returned by read_message('raw')", function()
       local msg = "foobar"
       local raw_msg = {_raw=msg}
       local decoded = decode_message(raw_msg)
       assert.is.equal("foobar", decoded)
    end)

    it("decodes table returned by read_message('raw')", function()
       local msg = {foo="bar"}
       local raw_msg = {_raw=msg}
       local decoded = decode_message(raw_msg)
       assert.is.table(decoded)
       assert.is.equal("bar", decoded.foo)
    end)
  end)
end)
