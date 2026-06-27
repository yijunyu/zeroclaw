#!/usr/bin/env bash
# PR #6619 — LIVE Full-autonomy shell dispatch smoke (run in your model/API env).
#
#   precc gif live_6619_dispatch.sh 30s "run the shell command: echo hello"
#
# Prereq: a config dir with [autonomy] level="full" and `shell` registered, and
# a running daemon the TUI/agent can reach. Adjust ZC_CONFIG / the run command
# to your local harness. Redact tokens/hostnames before posting the GIF.
set -e
ZC_CONFIG="${ZC_CONFIG:-$HOME/.config/zeroclaw}"

echo '# autonomy level (full) — approval prompt off, safeguards still on:'
grep -A1 '\[autonomy\]' "$ZC_CONFIG"/config.toml 2>/dev/null | sed 's/^/  /' || true
echo
echo '# Send a harmless command under Full autonomy and watch for a real dispatch.'
echo '# Expected: agent emits a `shell` tool_call -> runtime dispatches -> "hello".'
echo '# NOT expected: "blocked by security policy" / "restricted in this environment".'
echo
# --- replace the next line with your actual one-shot/chat invocation ---
# e.g. drive the daemon session API, or `zerocode -a <alias>` and type the prompt.
echo '$ <your-agent-run-command> --config-dir "'"$ZC_CONFIG"'"   # prompt: run the shell command: echo hello'
echo
echo '  [agent] (tool_call) shell { command: "echo hello" }'
echo '  [runtime] dispatch shell -> exit 0'
echo '  hello'
echo
echo '# ^ replace the three mocked lines above with the real redacted output.'
