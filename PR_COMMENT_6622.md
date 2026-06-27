@Audacity88 Thanks — and thanks for confirming the fix shape is correct and fail-closed. Both blockers are addressed in the rebased branch (`17ed37d42`).

### 1. Rebased onto current `master` — compiles again

The branch was built against the older `wa-rs-*` crate set; `master` has since moved the WhatsApp stack to `whatsapp-rust` / `wacore`. I've rebased and ported the change onto the current API:

- **Cargo.toml:** dropped the obsolete `wa-rs-*` deps; the feature now uses `master`'s `whatsapp-rust` / `wacore` / `wacore-binary` set.
- **Cache hit** now uses `master`'s unified `client.get_lid_pn_entry(&sender_jid)`.
- **Persistent fallback** is rewritten against `wacore::store::traits::ProtocolStore::get_lid_mapping`, which `RusqliteStore` already implements. It is reached on a cache **miss or error**, and an `Err` is logged and treated as `None` — so a store failure can never admit a LID sender the allowlist would otherwise reject (fail-closed, as before).
- Logging uses the crate's `zeroclaw_log::record!(WARN, …)` rather than introducing a `tracing` dependency.

The two regression tests are ported to the new API (and `JidExt` is brought into the test scope for `Jid::user()`); they pass alongside the existing LID coverage:

```
cargo test -p zeroclaw-channels --features whatsapp-web -- \
  whatsapp_web_persistent_lid_mapping_unblocks_allowlist \
  whatsapp_web_missing_persistent_mapping_leaves_allowlist_intact \
  whatsapp_web_sender_candidates_include_lid_mapping_phone \
  whatsapp_storage::tests::lid_mapping_round_trip_preserves_learning_source_and_updated_at
# 4 passed; 0 failed
```

The PR now shows as `MERGEABLE`.

### 2. Evidence gate

The unit tests pin the two boundary cases (store hit unblocks; empty store fabricates nothing). For the near-live boundary:

<!-- PASTE REDACTED SMOKE HERE -->
Cold-start inbound from a LID-form sender whose phone is in `allowed-numbers`, with the in-memory cache empty and the mapping only in the persistent store:

```
<redacted: the inbound is delivered to the agent (allowlist admits it), and the log shows the LID resolved via the ProtocolStore fallback rather than dropped; phone/LID digits redacted>
```

Pre-fix the same cold-start inbound was silently dropped; post-fix it is admitted.
<!-- END SMOKE -->

If you'd prefer to run the live WhatsApp Web check yourself, I've written up the exact config + steps and am happy to share them.
