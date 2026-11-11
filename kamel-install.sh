#!/usr/bin/env bash
# Kamel Hosting — oficjalny launcher online (STABLE).
# Trust anchor: PINNED_PUB_HEX (Ed25519). Nie pobieramy klucza z sieci.
# Weryfikuje bootstrap z GitHub Releases PRZED uruchomieniem.
# Publiczna „jedna komenda” to ten skrypt spakowany do jednej linii (zob. gen-one-command.py).
set -euo pipefail

PINNED_PUB_HEX="${KAMEL_PINNED_PUB_HEX:-387c48338b9b473a4d01da37a1e78d74080b3fd2a9b64edfe6ab7d29885f7277}"
RELEASES_REPO="${KAMEL_RELEASES_REPO:-kamil222kamil222/kamel-hosting-releases}"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Uruchom jako root: sudo …" >&2
  exit 1
fi

export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"
need() { command -v "$1" >/dev/null 2>&1 || return 1; }
if ! need curl || ! need python3 || ! need sha256sum || ! need tar || ! need awk; then
  apt-get update -qq
  apt-get install -y -qq curl ca-certificates python3 python3-nacl tar
fi
need curl; need python3; need sha256sum; need tar; need awk

WORK="$(mktemp -d /tmp/kamel-online.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

echo "== Kamel Hosting: pobieranie bootstrapa STABLE =="
curl -fsSL -H 'Accept: application/vnd.github+json' -H 'User-Agent: kamel-hosting-installer' \
  "https://api.github.com/repos/${RELEASES_REPO}/releases?per_page=30" -o "$WORK/releases.json"

eval "$(
  RELEASES_JSON="$WORK/releases.json" python3 - <<'PY'
import json, os, re, shlex, sys
from pathlib import Path
rels = json.loads(Path(os.environ["RELEASES_JSON"]).read_text(encoding="utf-8"))
for rel in rels:
    if rel.get("draft") or rel.get("prerelease"):
        continue
    assets = {a.get("name"): a for a in (rel.get("assets") or []) if a.get("name")}
    boot = next((n for n in assets if re.fullmatch(r"bootstrap-github-\d+\.\d+\.\d+\.sh", n or "")), None)
    if not boot:
        continue
    need = [boot, boot + ".sha256", boot + ".sig"]
    if any(n not in assets for n in need):
        continue
    print("TAG=" + shlex.quote(rel.get("tag_name") or ""))
    print("BOOT_NAME=" + shlex.quote(boot))
    print("BOOT_URL=" + shlex.quote(assets[boot]["browser_download_url"]))
    print("BOOT_SHA_URL=" + shlex.quote(assets[boot + ".sha256"]["browser_download_url"]))
    print("BOOT_SIG_URL=" + shlex.quote(assets[boot + ".sig"]["browser_download_url"]))
    sys.exit(0)
print("echo 'Brak zatwierdzonego STABLE' >&2; exit 2")
PY
)"

echo "STABLE ${TAG} → ${BOOT_NAME}"
curl -fsSL "$BOOT_URL" -o "$WORK/$BOOT_NAME"
curl -fsSL "$BOOT_SHA_URL" -o "$WORK/${BOOT_NAME}.sha256"
curl -fsSL "$BOOT_SIG_URL" -o "$WORK/${BOOT_NAME}.sig"

ACTUAL="$(sha256sum "$WORK/$BOOT_NAME" | awk '{print $1}')"
EXPECTED="$(awk '{print $1}' "$WORK/${BOOT_NAME}.sha256" | tr -d '\r\n' | tr 'A-F' 'a-f')"
[[ "$ACTUAL" == "$EXPECTED" ]] || { echo "SHA256 NIEZGODNY — przerwano"; exit 1; }
echo "SHA_OK"

PKG="$WORK/$BOOT_NAME" PINNED_PUB_HEX="$PINNED_PUB_HEX" python3 - <<'PY'
import os, subprocess, sys
from pathlib import Path
try:
    from nacl.signing import VerifyKey
    from nacl.exceptions import BadSignatureError
except ImportError:
    subprocess.check_call(["apt-get", "install", "-y", "-qq", "python3-nacl"], stdout=subprocess.DEVNULL)
    from nacl.signing import VerifyKey
    from nacl.exceptions import BadSignatureError
pkg = Path(os.environ["PKG"])
pub = bytes.fromhex(os.environ["PINNED_PUB_HEX"])
digest = Path(str(pkg) + ".sha256").read_text(encoding="utf-8").strip().split()[0].strip().lower()
sig = Path(str(pkg) + ".sig").read_bytes()
if len(sig.strip()) == 128:
    try:
        sig = bytes.fromhex(sig.strip().decode())
    except Exception:
        pass
vk = VerifyKey(pub)
ok = False
for msg in (digest.encode("ascii"), (digest + "\n").encode("ascii")):
    try:
        vk.verify(sig + msg)
        ok = True
        break
    except BadSignatureError:
        pass
    try:
        vk.verify(msg, sig)
        ok = True
        break
    except Exception:
        pass
if not ok:
    sys.exit("SIG_FAIL — możliwa podmiana bootstrapa")
print("SIG_OK")
PY

chmod 755 "$WORK/$BOOT_NAME"
echo "Bootstrap zweryfikowany — uruchamiam instalację STABLE…"
exec bash "$WORK/$BOOT_NAME" --stable
