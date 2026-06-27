#!/usr/bin/env bash
# PR #6622 — LIVE cold-start LID->phone allowlist smoke (run with a paired
# WhatsApp Web session).
#
#   precc gif live_6622_lid.sh 30s
#
# Prereq: agent's WhatsApp Web channel configured with
#   allowed-numbers = ["+<your-phone>"]
# a persisted LID->phone mapping for that contact (after one prior usync), and a
# FRESH process start so the in-memory cache is cold (before history sync).
# Then send one inbound message from that LID contact during the recording.
# Redact the real phone/LID digits before posting the GIF.
set -e

echo '# Cold start: in-memory LID cache empty; mapping only in the persistent store.'
echo '# Inbound from a LID-form sender whose phone is in allowed-numbers.'
echo
echo '# Expected (post-fix): cache miss -> ProtocolStore::get_lid_mapping fallback'
echo '#   resolves the phone -> allowlist admits -> message delivered to the agent.'
echo '# Pre-fix: the same cold-start inbound was silently dropped (#6350).'
echo
# --- replace with the real redacted daemon/agent log lines for the inbound ---
echo '  [whatsapp_web] inbound from LID <redacted>@lid'
echo '  [whatsapp_web] cache miss -> persistent get_lid_mapping -> +<redacted>'
echo '  [allowlist] +<redacted> in allowed-numbers -> ADMIT'
echo '  [agent] received message from <redacted>'
echo
echo '# ^ replace the four mocked lines above with the real redacted log output.'
