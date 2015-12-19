Helper for testing Lua sandboxes
================================

This is a helper to do unit testing of Heka lua sandboxes: encoders and decoders.

It is in Proof-Of-Concept stage: use at own risk.

Contributions are welcome

Usage
-----

Install busted:
```
luarocks install busted
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

(See also Heka docs: http://hekad.readthedocs.org/en/v0.10.0b2/sandbox/index.html)

### add_to_payload(val)

Add val to payload.

### inject_payload()

Stores injected payload to test against it in and clears payload.

### injected()

All injected messages since last `reset_payload()` merged into a single string.

### reset_payload()

Reset payload and stored `injected()` data. Run it before every test.

### mock_read_config(hash)

Set values for `read_config()` called by encoder.
If no paramater passed only the default config params will be set (see `default_config()`).

### set_default_config(hash)

If you need to set some config values shared by all tests define them here.
Note: you still need to run `mock_read_config()` to set them.
