#!/usr/bin/env bash
# PR #6622 — regression tests for the WhatsApp LID->phone persistent fallback.
# Animated as evidence that the store-hit unblocks the allowlist and the empty
# store fabricates nothing (fail-closed), ported to the wacore API.
set -e
cd /home/y00577373/zeroclaw

echo '$ cargo test -p zeroclaw-channels --features whatsapp-web -- <lid tests>'
cargo test -p zeroclaw-channels --features whatsapp-web -- \
  whatsapp_web_persistent_lid_mapping_unblocks_allowlist \
  whatsapp_web_missing_persistent_mapping_leaves_allowlist_intact \
  whatsapp_web_sender_candidates_include_lid_mapping_phone \
  whatsapp_storage::tests::lid_mapping_round_trip_preserves_learning_source_and_updated_at \
  2>&1 | grep -E 'running|test whatsapp|test result'
