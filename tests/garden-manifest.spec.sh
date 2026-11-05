#!/usr/bin/env bash
# Spec: garden.json declares petals as a bed the plotplot stem can plant:
# the fields the contract requires, a check whose first word is the CLI and
# that carries no shell characters, a git pin that exists, and paths that
# exist (issue #4, part C). Full schema validation runs against plotplot's
# contracts/manifest.schema.json (draft 2020-12) outside this dependency-free
# spec; see the commit that added this file. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
python3 -I - <<'PY'
import json, re, subprocess, os, sys
fails = 0
def ok(c, n):
    global fails
    print(("ok - " if c else "not ok - ") + n); fails += 0 if c else 1
try: m = json.load(open("garden.json", encoding="utf-8"))
except Exception as e: print("not ok - garden.json is JSON: %s" % e); sys.exit(1)
ok(m.get("name") == "petals" and "gate" in m.get("kind", []), "names petals, a gate")
ok(re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?", m.get("version", "")) is not None, "a semantic version")
cli = m.get("faces", {}).get("cli")
check = m.get("check", "")
ok(cli == "petals" and check.split()[0] == cli, "check's first word is the CLI, which the stem replaces with its installed path")
ok(not re.search(r"[|&;<>$`\\\"'(){}*?\[\]]", check), "check carries no shell characters")
# the release artifact's top-level `petals` (scripts/build-release.sh) wraps
# this entry point; tests/release.spec.sh checks the artifact itself
entry = "petals/bin/petals"
ok("binary_name" not in m.get("install", {}), "no binary_name: the artifact's top-level file is named for the CLI")
ok(os.path.isfile(entry) and os.access(entry, os.X_OK), "the entry point the release wraps exists and runs")
v = subprocess.run([entry, "--version"], capture_output=True, text=True).stdout.strip()
ok(v == "petals " + m.get("version", ""), "the executable's version is the manifest's (%s)" % v)
ok(os.path.isfile(m.get("faces", {}).get("skill", "")), "the skill path exists")
rev = m.get("install", {}).get("git", {}).get("rev", "")
ok(re.fullmatch(r"[0-9a-f]{40}", rev) is not None and subprocess.run(["git", "cat-file", "-e", rev + "^{commit}"]).returncode == 0, "the git pin is a full sha this repository has")
ok("upfront_tokens" in m.get("context", {}), "the context cost is declared (null when unmeasured)")
cov = m.get("coverage", {})
ok(isinstance(cov.get("languages"), list) and isinstance(cov.get("kinds"), list) and "html" in cov["kinds"], "coverage names the file kinds petals judges")
ok(all({"what", "why"} <= set(f) for f in m.get("flagged", [])), "every flagged unknown says what and why")
print(); print("%d failure(s)" % fails); sys.exit(fails)
PY
