#!/usr/bin/env bash
# Spec for petals/scripts/fetch-brand.sh
# Run from the repo root: bash tests/fetch-brand.spec.sh
cd "$(dirname "$0")/.." || exit 1
SCRIPT="$(pwd)/petals/scripts/fetch-brand.sh"
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }

[ -f "$SCRIPT" ] || { echo "not ok - fetch-brand.sh does not exist"; exit 1; }

# Test 1: Local directory copy with v1.1.0 fixture
TMPDIR=$(mktemp -d /tmp/fetch-brand-test-XXXXXX)
trap "rm -rf '$TMPDIR' 2>/dev/null || true" EXIT

OUT1=$(bash "$SCRIPT" "file://$(pwd)/test/fixtures/brand-repo-test-v1.1.0" --target "$TMPDIR/.brand" 2>&1); RC1=$?
t "local copy exit 0" '0' "$RC1"
t "local copy version=v1.1.0" 'v1\.1\.0' "$OUT1"

# Test 2: Missing .brand/ directory (brand-repo-malformed fixture)
OUT2=$(bash "$SCRIPT" "file://$(pwd)/test/fixtures/brand-repo-malformed" --target "$TMPDIR/.brand2" 2>&1); RC2=$?
t "missing .brand exit 1" '1' "$RC2"

# Test 3: Unreachable path
OUT3=$(bash "$SCRIPT" "/nonexistent/path/12345" --target "$TMPDIR/.brand3" 2>&1); RC3=$?
t "unreachable path exit 2" '2' "$RC3"

# A relative source and target resolve from the caller's directory. The
# target sits inside tests/ so it means something else from the project root;
# the run removes it.
SUB=$(mktemp -d tests/.scratch-fb-XXXXXX); trap 'rm -rf "$TMPDIR" "$SUB" 2>/dev/null || true' EXIT
OUT_REL=$(cd tests && bash "$SCRIPT" "../test/fixtures/brand-repo-test-v1.1.0" --target "$(basename "$SUB")/.brand" 2>&1); RC_REL=$?
t "relative source from a subdirectory exit 0" '^0$' "$RC_REL"
[ -f "$SUB/.brand/identity.md" ] && echo "ok - relative target lands where the caller meant" || { echo "not ok - relative target lands where the caller meant"; fails=$((fails+1)); }

# The fetched brand holds every file the source holds, byte for byte
if diff -r "$(pwd)/test/fixtures/brand-repo-test-v1.1.0/.brand" "$TMPDIR/.brand" >/dev/null 2>&1; then echo "ok - fetched brand matches the source file for file"; else echo "not ok - fetched brand matches the source file for file"; fails=$((fails+1)); fi

echo; echo "$fails failure(s)"; exit "$fails"
