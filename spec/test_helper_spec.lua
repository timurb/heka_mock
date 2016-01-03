require "spec/test_helper"

describe("Heka mocks", function()
  describe("inject_payload()", function()
    before_each(function()
      reset_payload()
    end)

    it("works with add_to_payload()", function ()
      add_to_payload("foo")
      inject_payload()
      assert.is.equal('{Payload=\'foo\'}', injected())
    end)

    it("joins 2 consecutive add_to_payload()", function ()
      add_to_payload("foo")
      add_to_payload("bar")
      inject_payload()
      assert.is.equal("{Payload=\'foobar\'}", injected())
    end)

    it("accepts payload as params", function()
      inject_payload(nil,nil,"bar","baz")
      assert.is.equal("{Payload=\'barbaz\'}", injected())
    end)

    it("NOT SUPPORTED IN HEKA: works without payload ", function()
      inject_payload(nil,nil)
      assert.is.equal("{Payload=nil}", injected())
    end)

    it("accepts type and name as params", function()
      inject_payload("foo","bar","baz")
      assert.is.equal("{Payload=\'baz\',Fields[payload_type]=\'foo\',Fields[payload_name]=\'bar\'}", injected())
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
      assert.is.equal("{Payload=\'bar\'}", injected())
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

describe("Helper methods (NOT SUPPORTED IN HEKA):", function()
  describe("Format functions:", function()
    describe("format_payload()", function ()
      it("formats nils", function()
        assert.is.equal("Payload=nil", format_payload(nil))
      end)

      it("formats strings", function()
        assert.is.equal("Payload=\'foobar\'", format_payload("foobar"))
      end)
    end)

    describe("format_kv()", function ()
      it("drops nils", function()
        assert.is.equal(nil, format_kv(nil))
      end)

      it("formats strings", function()
        assert.is.equal("foo=\'bar\'", format_kv("foo","bar"))
      end)
    end)
  end)

  describe("bracketize()", function ()
    it("adds brackets arount value", function ()
      assert.is.equal("{1}", bracketize(1))
    end)
  end)

  describe("tostring_sorted()", function()
    it("converts value to string", function ()
      assert.is.equal("1", tostring_sorted(1))
    end)

    it("converts array to string", function ()
      sorted = tostring_sorted({1,2,3})
      assert.is_not_nil(sorted)
      assert.is.equal("{1,2,3}", sorted)
    end)

    it("converts hash to string", function ()
      sorted = tostring_sorted({one=1,two=2,three=3})
      assert.is_not_nil(sorted)
      assert.is.equal("{one=1,three=3,two=2}", sorted)
    end)

    it("supports nested hashes", function ()
      sorted = tostring_sorted({one=1,two=2,three={nested=true}})
      assert.is_not_nil(sorted)
      assert.is.equal("{one=1,three={nested=true},two=2}", sorted)
    end)

    it("supports nested arrays", function ()
      sorted = tostring_sorted({1,2,3,{4,5}})
      assert.is_not_nil(sorted)
      assert.is.equal("{1,2,3,{4,5}}", sorted)
    end)

    it("supports hashes nested in arrays", function ()
      sorted = tostring_sorted({1,2,3,{five=5}})
      assert.is_not_nil(sorted)
      assert.is.equal("{1,2,3,{five=5}}", sorted)
    end)

    it("supports arrays nested in hashes", function ()
      sorted = tostring_sorted({one=1,two=2,three={4,5,6}})
      assert.is_not_nil(sorted)
      assert.is.equal("{one=1,three={4,5,6},two=2}", sorted)
    end)
  end)
end)

