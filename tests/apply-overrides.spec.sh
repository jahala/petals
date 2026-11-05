#!/usr/bin/env bash
# Spec for petals/scripts/apply-overrides.sh
# Run from the repo root: bash tests/apply-overrides.spec.sh
cd "$(dirname "$0")/.." || exit 1
SCRIPT="$(pwd)/petals/scripts/apply-overrides.sh"
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }

[ -f "$SCRIPT" ] || { echo "not ok - apply-overrides.sh does not exist"; exit 1; }

# Create a temp .brand copy and a .petalsrc with overrides
TMPDIR=$(mktemp -d /tmp/apply-overrides-test-XXXXXX)
trap "rm -rf '$TMPDIR' 2>/dev/null || true" EXIT

cp -r "$(pwd)/test/fixtures/brand-repo-test-v1.1.0/.brand" "$TMPDIR/.brand"

# Test 1: Apply colors.primary override
cat > "$TMPDIR/.petalsrc" <<'EOF'
brand:
  source: https://github.com/example/test.git
  version: v1.1.0
  overrides:
    colors.primary: "#FF0000"
EOF

OUT1=$(cd "$TMPDIR" && bash "$SCRIPT" 2>&1); RC1=$?
t "apply colors.primary exit 0" '0' "$RC1"
t "value changed in colors.md" '#FF0000' "$(grep '| Primary |' "$TMPDIR/.brand/colors.md" | head -1)"

# Reset for test 2
rm -rf "$TMPDIR/.brand"
cp -r "$(pwd)/test/fixtures/brand-repo-test-v1.1.0/.brand" "$TMPDIR/.brand"

# Test 2: Null value → key skipped
cat > "$TMPDIR/.petalsrc" <<'EOF'
brand:
  source: https://github.com/example/test.git
  version: v1.1.0
  overrides:
    colors.primary: null
EOF

OUT2=$(cd "$TMPDIR" && bash "$SCRIPT" 2>&1); RC2=$?
t "null value exit 0" '0' "$RC2"
t "null value skipped in log" 'Skipping' "$OUT2"
t "original color unchanged" '#2F99A4' "$(grep '| Primary |' "$TMPDIR/.brand/colors.md" | head -1)"

# A relative --petalrc and --brand resolve from the caller's directory.
# The scratch folder sits inside tests/ so the same relative path from the
# project root points nowhere; the run removes it.
SUB=$(mktemp -d tests/.scratch-ao-XXXXXX); trap 'rm -rf "$TMPDIR" "$SUB" 2>/dev/null || true' EXIT
cp -r "$(pwd)/test/fixtures/brand-repo-test-v1.1.0/.brand" "$SUB/.brand"
printf 'brand:\n  source: https://github.com/example/test.git\n  version: v1.1.0\n  overrides:\n    colors.primary: "#00AA00"\n' > "$SUB/.petalsrc"
OUT_REL=$(cd tests && bash "$SCRIPT" --petalrc "$(basename "$SUB")/.petalsrc" --brand "$(basename "$SUB")/.brand" 2>&1)
t "relative paths from a subdirectory apply the override" '#00AA00' "$(grep '| Primary |' "$SUB/.brand/colors.md" | head -1)"

# an empty overrides map is not an error, on every bash the scripts meet
# (macOS ships bash 3.2, where an empty array is unbound under set -u)
for sh in /bin/bash bash; do
  command -v "$sh" >/dev/null || continue
  rm -rf "$TMPDIR/.brand"; cp -r "$(pwd)/test/fixtures/brand-repo-test-v1.1.0/.brand" "$TMPDIR/.brand"
  printf 'brand:\n  source: x\n  version: v1.1.0\n  overrides: {}\n' > "$TMPDIR/.petalsrc"
  OUT_EMPTY=$("$sh" "$SCRIPT" --petalrc "$TMPDIR/.petalsrc" --brand "$TMPDIR/.brand" 2>&1); RC_EMPTY=$?
  [ "$RC_EMPTY" -eq 0 ] && echo "ok - empty overrides exit 0 under $sh" || { echo "not ok - empty overrides exit 0 under $sh ($RC_EMPTY): $(echo "$OUT_EMPTY" | tail -1)"; fails=$((fails+1)); }
done
echo; echo "$fails failure(s)"; exit "$fails"
