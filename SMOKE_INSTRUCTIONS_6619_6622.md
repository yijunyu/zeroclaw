# Dispatch-smoke evidence for PR #6619 and #6622

Both reviews ask for the same shape of evidence: a near-live run showing the
fix changes real runtime behavior, not just the prompt string / unit tests.
Redact anything sensitive (tokens, real phone numbers, host names) before
posting to the PR.

---

## PR #6619 — Full-autonomy shell dispatch

**Claim to demonstrate:** under `autonomy.level = full` with `shell` registered,
the agent emits a `shell` tool call for a harmless command and the runtime
dispatches it — instead of returning a simulated "blocked by security policy"
refusal.

### Config (the `[autonomy]` block — set level to `full`)

```toml
[autonomy]
level = "full"
workspace_only = true
# forbidden_paths / forbidden_commands stay in force even at full autonomy —
# that is exactly the distinction the reworded prompt preserves.
forbidden_paths = ["/etc", "/root"]
max_actions_per_hour = 100
```

Make sure `shell` is in the agent's registered tool set.

### Run + what to capture

Run the agent (daemon + `zerocode -a <alias>` chat, or your usual local
harness) and send a harmless prompt:

```
Run the shell command: echo hello
```

**Evidence to paste into the PR (any one of these is enough):**
- the `hello` appearing in the agent's response, OR
- a tool receipt / debug log line showing `tool_call` → `shell` dispatch
  (e.g. the runtime's `Action::Invoke` / dispatch log for the shell tool), OR
- redacted stderr/log showing the shell tool ran and returned, with **no**
  "blocked by security policy" / "restricted in this environment" refusal text.

The point is the *contrast*: pre-fix the model self-refused without emitting a
`tool_call`; post-fix it emits the call and the runtime dispatches it.

> Note: `zerocode` is the TUI client to the daemon and has no one-shot
> `--prompt` flag, so this is driven through a chat session against a running
> daemon. If you would rather the reviewer run it, Audacity88 offered to — in
> that case just point them at this recipe.

---

## PR #6622 — WhatsApp LID→phone persistent-fallback allowlist

**Claim to demonstrate:** an inbound from a LID-form sender whose phone is in
`allowed-numbers`, on a cold start (in-memory client cache empty), is admitted
because the handler falls back to the durable `ProtocolStore::get_lid_mapping`
row — instead of being silently dropped (the #6350 bypass).

The four regression tests already prove the resolution + fail-closed behavior
at the unit boundary:

- `whatsapp_web_persistent_lid_mapping_unblocks_allowlist` — store hit adds the
  phone-form candidate and the allowlist matches.
- `whatsapp_web_missing_persistent_mapping_leaves_allowlist_intact` — empty
  store fabricates nothing.
- `whatsapp_web_sender_candidates_include_lid_mapping_phone`
- `whatsapp_storage::lid_mapping_round_trip_preserves_learning_source_and_updated_at`

Run them with:

```bash
cargo test -p zeroclaw-channels --features whatsapp-web -- \
  whatsapp_web_persistent_lid_mapping_unblocks_allowlist \
  whatsapp_web_missing_persistent_mapping_leaves_allowlist_intact \
  whatsapp_web_sender_candidates_include_lid_mapping_phone
# all green
```

### Near-live evidence (the reviewer's evidence gate)

If a paired WhatsApp Web session is available:
1. Configure `allowed-numbers = ["+<your-phone>"]` for the agent's WhatsApp Web channel.
2. Ensure the LID→phone mapping for that contact is persisted (it is, after one
   prior usync) but the **in-memory cache is cold** (fresh process start, before
   history sync).
3. Send an inbound message from that LID contact.
4. **Capture (redacted):** the message is delivered to the agent (allowlist
   admits it), and the debug log shows the LID resolved via the persistent store
   fallback rather than dropped. Redact the real phone/LID digits.

Pre-fix, the same cold-start inbound is silently dropped; post-fix it is admitted.
