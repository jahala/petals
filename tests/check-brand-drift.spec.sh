#!/usr/bin/env bash
# Spec for petals/scripts/check-brand-drift.sh
# Run from the repo root: bash tests/check-brand-drift.spec.sh
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check-brand-drift.sh
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }

[ -f "$SCRIPT" ] || { echo "not ok - check-brand-drift.sh does not exist"; exit 1; }

FIXTURES="$(pwd)/test/fixtures"

# Test 1: v1.1.0 vs v1.2.0 → drift (exit 1)
OUT1=$(bash "$SCRIPT" "v1.1.0" "$FIXTURES/brand-repo-test-v1.2.0" 2>&1); RC1=$?
t "v1.1.0 vs v1.2.0 is drift (exit 1)" '1' "$RC1"
t "v1.1.0 vs v1.2.0 status=drift" '"status":"drift"' "$OUT1"

# Test 2: v1.1.0 vs v1.1.0 → current (exit 0)
OUT2=$(bash "$SCRIPT" "v1.1.0" "$FIXTURES/brand-repo-test-v1.1.0" 2>&1); RC2=$?
t "v1.1.0 vs v1.1.0 is current (exit 0)" '0' "$RC2"
t "v1.1.0 vs v1.1.0 status=current" '"status":"current"' "$OUT2"

# Test 3: v1.1.0 vs nonexistent → unreachable (exit 2)
OUT3=$(bash "$SCRIPT" "v1.1.0" "/nonexistent/path/99999" 2>&1); RC3=$?
t "v1.1.0 vs nonexistent is unreachable (exit 2)" '2' "$RC3"

# A relative source path resolves from the caller's directory
OUT_REL=$(cd tests && bash "../$SCRIPT" "v1.1.0" "../test/fixtures/brand-repo-test-v1.2.0" 2>&1)
t "relative source from a subdirectory is read" '"status":"drift"' "$OUT_REL"

# The drift report names both versions, and an unreachable source says why
t "drift report names the local version" '"local_version":"v1\.1\.0"' "$OUT1"
t "drift report names the central version" '"central_version":"v1\.2\.0"' "$OUT1"
t "unreachable report explains the connection failure" 'Cannot reach brand source' "$OUT3"
# Local ahead of central is its own state
OUT4=$(bash "$SCRIPT" "v1.3.0" "$FIXTURES/brand-repo-test-v1.2.0" 2>&1); RC4=$?
t "v1.3.0 vs v1.2.0 is ahead (exit 4)" '^4$' "$RC4"
t "v1.3.0 vs v1.2.0 status=ahead" '"status":"ahead"' "$OUT4"

echo; echo "$fails failure(s)"; exit "$fails"
