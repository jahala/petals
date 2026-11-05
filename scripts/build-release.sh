#!/usr/bin/env bash
# build-release.sh <out-dir>: build the release artifact the plotplot stem plants.
#
# The stem copies only <artifact root>/petals into a repository's .plotplot/bin/,
# so the artifact's one member is a self-contained `petals`: a short launcher
# with every file git tracks under petals/ embedded. On first run it unpacks
# them into ${XDG_CACHE_HOME:-~/.cache}/petals/<content sha>/ and hands over to
# bin/petals there. The build is deterministic (sorted members, zero mtimes and
# owners), so one commit always gives the same bytes and the same sha256.
#
# Writes <out-dir>/petals-<version>.tar.gz and <out-dir>/petals-<version>.tar.gz.sha256.
# Building publishes nothing.
set -euo pipefail
OUT="${1:?usage: build-release.sh <out-dir>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION=$("$ROOT/petals/bin/petals" --version | awk '{print $2}')
mkdir -p "$OUT"
python3 -I - "$ROOT" "$OUT" "$VERSION" <<'PY'
import base64, gzip, hashlib, io, os, subprocess, sys, tarfile

root, out, version = sys.argv[1], sys.argv[2], sys.argv[3]

def deterministic_tar(members):
    """A gzipped tar of (name, bytes, mode) with fixed metadata, in name order."""
    raw = io.BytesIO()
    with tarfile.open(fileobj=raw, mode="w", format=tarfile.USTAR_FORMAT) as tar:
        for name, data, mode in sorted(members):
            info = tarfile.TarInfo(name)
            info.size, info.mode, info.mtime = len(data), mode, 0
            info.uid = info.gid = 0
            info.uname = info.gname = ""
            tar.addfile(info, io.BytesIO(data))
    packed = io.BytesIO()
    with gzip.GzipFile(fileobj=packed, mode="wb", mtime=0) as gz:
        gz.write(raw.getvalue())
    return packed.getvalue()

tracked = subprocess.run(["git", "-C", root, "ls-files", "-z", "--", "petals/"],
                         capture_output=True, check=True).stdout.split(b"\0")
members = []
for rel in sorted(t.decode() for t in tracked if t):
    path = os.path.join(root, rel)
    mode = 0o755 if os.access(path, os.X_OK) else 0o644
    members.append((rel, open(path, "rb").read(), mode))
payload = deterministic_tar(members)
sha = hashlib.sha256(payload).hexdigest()[:16]

launcher = """#!/usr/bin/env bash
# petals %(version)s, a self-contained release: the files petals needs are
# embedded below. On first run they are unpacked into a folder named for
# their content, then bin/petals there runs with this command's arguments.
# Where: planted by the stem (this file in <repo>/.plotplot/bin/), under
# <repo>/.plotplot/cache/petals/, inside the stem's footprint; anywhere else,
# under ${XDG_CACHE_HOME:-~/.cache}/petals/. What it keeps: the current
# version's copy. What removes the rest: the first run of a new version hands
# every older copy to `trash`; where trash is not installed it names them on
# stderr and leaves them. Only this run's own temp folder is ever rm'd.
set -euo pipefail
self_dir=$(cd "$(dirname "$0")" && pwd)
if [ "$(basename "$self_dir")" = bin ] && [ "$(basename "$(dirname "$self_dir")")" = .plotplot ]; then
  base="$(dirname "$self_dir")/cache/petals"
else
  base="${XDG_CACHE_HOME:-$HOME/.cache}/petals"
fi
here="$base/%(sha)s"
if [ ! -x "$here/petals/bin/petals" ]; then
  mkdir -p "$base"
  tmp=$(mktemp -d "$base/.unpack.XXXXXX")
  sed -n '/^__PETALS_PAYLOAD__$/,$p' "$0" | tail -n +2 | base64 -d | tar -xzf - -C "$tmp"
  mv "$tmp" "$here" 2>/dev/null || rm -rf "$tmp"
  for old in "$base"/*/; do
    old=${old%%/}
    [ "$old" = "$here" ] && continue
    if command -v trash >/dev/null 2>&1; then
      trash "$old" || echo "petals: could not trash the older copy $old" >&2
    else
      echo "petals: $old is an older unpacked copy; remove it with trash when convenient" >&2
    fi
  done
fi
exec "$here/petals/bin/petals" "$@"
__PETALS_PAYLOAD__
""" % {"version": version, "sha": sha}
encoded = base64.encodebytes(payload).decode()
bundle = (launcher + encoded).encode()

name = "petals-%s.tar.gz" % version
artifact = deterministic_tar([("petals", bundle, 0o755)])
with open(os.path.join(out, name), "wb") as f:
    f.write(artifact)
with open(os.path.join(out, name + ".sha256"), "w") as f:
    f.write("%s  %s\n" % (hashlib.sha256(artifact).hexdigest(), name))
print(os.path.join(out, name))
PY
