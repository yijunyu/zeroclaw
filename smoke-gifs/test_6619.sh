#!/usr/bin/env bash
# PR #6619 — regression tests for the narrowed Full-autonomy authorization prompt.
# Animated as evidence that the attempt-scoped wording is pinned and the
# overbroad "not blocked by any security policy" claim cannot return.
set -e
cd /home/y00577373/zeroclaw

echo '$ cargo test -p zeroclaw-runtime --lib agent::system_prompt::tests'
cargo test -p zeroclaw-runtime --lib agent::system_prompt::tests 2>&1 \
  | grep -E 'running|test agent::system_prompt|test result'
