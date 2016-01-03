Helper for testing Lua sandboxes
================================

This is a helper to do unit testing of Heka lua sandboxes: encoders and decoders.

It is in Proof-Of-Concept stage: use at own risk.

Contributions are welcome

Usage
-----

Install busted:
```
luarocks install busted underscore
```

Create `spec/` subdir in the dir with your lua modules:
```
---+--- spec/ -+- test_helper.lua
   |           -- my_encoder_spec.lua
   ---- my_encoder.lua
```

Run tests:
```
$ busted
●
1 success / 0 failures / 0 errors / 0 pending : 0.004586 seconds
```

API
---

(See also [Heka docs](http://hekad.readthedocs.org/en/v0.10.0/sandbox/index.html) for real behaviour of the functions in heka)

#### add_to_payload(val)

Add val to payload.

#### inject_payload(payload_type, payload_name, ...)

Inject payload to injection list and clear current payload. 

#### inject_message(msg)

Converts `msg` to string and injects payload.

#### injected()
(NOT IMPLEMENTED IN HEKA UPSTREAM)

All injected messages since last `reset_payload()` merged into a single string.

#### reset_payload()
(NOT IMPLEMENTED IN HEKA UPSTREAM)

Reset payload and injection list. Run it before every test.

### Mocks

#### mock_read_message(hash)

Set values for `read_message()` called by encoder.
As in upstream `read_message("raw")` should return table with original unprocessed message for further handling.

#### mock_read_config(hash)

Set values for `read_config()` called by encoder.
If no paramater passed only the default config params will be set (see `default_config()`).

#### set_default_config(hash)

If you need to set some config values shared by all tests define them here.
Note: you still need to run `mock_read_config()` to set them.

### Helper functions

These functions are used to simplify test helper. Reuse them in your tests at your own risk.

#### format_payload(val)

Format passed value as a payload for text representation.

#### format_kv(key, val)

If `val` is not nil format is a hash pair for text representation.

#### tostring_sorted(val)

Recursive function to convert table to string always preserving the same order of keys.
Was *not* tested with mixed tables (like `{10,20,30,foo="bar"}`) and probably will not work with these.
This is used inside helper codebase which means such arrays will produce crashes.

#### bracketize(val)

Enclose value in curly brackets: `"{val}"`
