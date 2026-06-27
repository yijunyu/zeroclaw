# PR evidence — #6619 and #6622

Test-run GIFs and the live-smoke scripts behind the two PRs. Not part of either
PR's code diff; kept on the `pr-evidence/6619-6622` branch for reference.

## Test GIFs (recorded in CI-equivalent local runs)

- `test_6619.gif` — `cargo test -p zeroclaw-runtime --lib agent::system_prompt`
  → 5 passed, including `full_autonomy_authorization_is_attempt_scoped_not_unconditional`
  (the regression guard that pins the narrowed Full-autonomy wording).
- `test_6622.gif` — the WhatsApp LID→phone persistent-fallback tests → 4 passed.

`test_6619.sh` / `test_6622.sh` are the scripts that produce them.

## Live-smoke scripts (run in a model/API + WhatsApp env)

- `live_6619_dispatch.sh` — Full-autonomy `echo hello` dispatch smoke.
- `live_6622_lid.sh` — cold-start LID→phone allowlist smoke.

Each has placeholder lines to replace with real redacted output.

## How the GIFs were made

`precc gif`'s bundled pipeline silently dropped the output here, so use
record-then-render:

```bash
TMPDIR=~/gif-tmp asciinema rec --overwrite \
  --command "bash <script>" out.cast
~/.cargo/bin/agg --speed 1 out.cast out.gif
```
