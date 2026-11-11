#!/usr/bin/env bash
# Kamel Hosting — oficjalny launcher online (STABLE).
# Trust anchor: PINNED_PUB_HEX (Ed25519). Nie pobieramy klucza z sieci.
#
# Omija bug bootstrap-github --stable (v0.17.11): $(fetch_stable_package) mieszal
# logi ze sciezka pakietu. Launcher sam pobiera i weryfikuje pakiet, potem:
#   bootstrap-github-*.sh --offline <zweryfikowany.tar.gz>
set -euo pipefail

PINNED_PUB_HEX="${KAMEL_PINNED_PUB_HEX:-387c48338b9b473a4d01da37a1e78d74080b3fd2a9b64edfe6ab7d29885f7277}"
RELEASES_REPO="${KAMEL_RELEASES_REPO:-kamil222kamil222/kamel-hosting-releases}"
CHANNEL_ASSET="channel-manifest.json"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Uruchom jako root (sudo -i)." >&2
  exit 1
fi

export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"
need() { command -v "$1" >/dev/null 2>&1; }
if ! need curl || ! need python3 || ! need sha256sum || ! need tar || ! need awk; then
  apt-get update -qq
  apt-get install -y -qq curl ca-certificates python3 python3-nacl tar
fi
need curl || { echo "Brak curl" >&2; exit 1; }
need python3 || { echo "Brak python3" >&2; exit 1; }
need sha256sum || { echo "Brak sha256sum" >&2; exit 1; }
need tar || { echo "Brak tar" >&2; exit 1; }

# Staging poza /tmp sesyjnym — musi przezyc exec bootstrapu
STAGING="/var/tmp/kamel-install-$$"
mkdir -p "$STAGING"
cleanup() { rm -rf "$STAGING"; }
trap cleanup EXIT

log() { echo "$*" >&2; }

verify_pkg() {
  local pkg="$1"
  [[ -f "$pkg" ]] || { log "Brak pakietu $pkg"; exit 1; }
  [[ -f "${pkg}.sha256" ]] || { log "Brak ${pkg}.sha256"; exit 1; }
  [[ -f "${pkg}.sig" ]] || { log "Brak ${pkg}.sig"; exit 1; }
  local actual expected
  actual="$(sha256sum "$pkg" | awk '{print $1}')"
  expected="$(awk '{print $1}' "${pkg}.sha256" | tr -d '\r\n' | tr 'A-F' 'a-f')"
  [[ "$actual" == "$expected" ]] || { log "SHA256 NIEZGODNY: $pkg"; exit 1; }
  log "SHA_OK $actual"
  PKG="$pkg" PINNED_PUB_HEX="$PINNED_PUB_HEX" python3 - <<'PY'
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
    sys.exit("SIG_FAIL")
print("SIG_OK", file=sys.stderr)
PY
}

log "== Kamel Hosting: instalacja STABLE =="

# --- bootstrap (do trybu --offline) ---
curl -fsSL -H 'Accept: application/vnd.github+json' -H 'User-Agent: kamel-hosting-installer' \
  "https://api.github.com/repos/${RELEASES_REPO}/releases?per_page=30" -o "$STAGING/releases.json"

eval "$(
  RELEASES_JSON="$STAGING/releases.json" python3 - <<'PY'
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
    need = [boot, boot + ".sha256", boot + ".sig", "channel-manifest.json", "channel-manifest.json.sha256", "channel-manifest.json.sig"]
    if any(n not in assets for n in need):
        continue
    print("TAG=" + shlex.quote(rel.get("tag_name") or ""))
    print("BOOT_NAME=" + shlex.quote(boot))
    print("BOOT_URL=" + shlex.quote(assets[boot]["browser_download_url"]))
    print("BOOT_SHA_URL=" + shlex.quote(assets[boot + ".sha256"]["browser_download_url"]))
    print("BOOT_SIG_URL=" + shlex.quote(assets[boot + ".sig"]["browser_download_url"]))
    print("MAN_URL=" + shlex.quote(assets["channel-manifest.json"]["browser_download_url"]))
    print("MAN_SHA_URL=" + shlex.quote(assets["channel-manifest.json.sha256"]["browser_download_url"]))
    print("MAN_SIG_URL=" + shlex.quote(assets["channel-manifest.json.sig"]["browser_download_url"]))
    sys.exit(0)
print("echo 'Brak STABLE' >&2; exit 2")
PY
)"

log "STABLE ${TAG}"
curl -fsSL "$BOOT_URL" -o "$STAGING/$BOOT_NAME"
curl -fsSL "$BOOT_SHA_URL" -o "$STAGING/${BOOT_NAME}.sha256"
curl -fsSL "$BOOT_SIG_URL" -o "$STAGING/${BOOT_NAME}.sig"
verify_pkg "$STAGING/$BOOT_NAME"

curl -fsSL "$MAN_URL" -o "$STAGING/${CHANNEL_ASSET}"
curl -fsSL "$MAN_SHA_URL" -o "$STAGING/${CHANNEL_ASSET}.sha256"
curl -fsSL "$MAN_SIG_URL" -o "$STAGING/${CHANNEL_ASSET}.sig"
verify_pkg "$STAGING/${CHANNEL_ASSET}"

eval "$(
  MAN="$STAGING/${CHANNEL_ASSET}" python3 - <<'PY'
import json, os, shlex
from pathlib import Path
man = json.loads(Path(os.environ["MAN"]).read_text(encoding="utf-8"))
if str(man.get("channel", "")).upper() != "STABLE":
    raise SystemExit("Manifest nie jest STABLE")
arts = man.get("artifacts") or man.get("packages") or {}
cand = None
for key in ("install", "kamel-hosting-install"):
    if key in arts and isinstance(arts[key], dict):
        cand = arts[key]
        break
if cand is None:
    for name, meta in arts.items():
        if isinstance(meta, dict) and "install" in str(name) and meta.get("url"):
            cand = meta
            cand.setdefault("name", name)
            break
if not cand:
    raise SystemExit("Manifest bez pakietu install")
print("pkg_url=" + shlex.quote(cand["url"]))
print("pkg_sha=" + shlex.quote(cand["sha256"]))
print("pkg_sig=" + shlex.quote(cand.get("sig_url") or ""))
print("pkg_name=" + shlex.quote(cand.get("name") or "kamel-hosting-install.tar.gz"))
print("pkg_size=" + shlex.quote(str(cand.get("size") or "")))
print("target_ver=" + shlex.quote(str(man.get("version") or "")))
PY
)"

[[ -n "${pkg_sig:-}" ]] || { log "Brak sig_url"; exit 1; }
log "Pobieram pakiet ${pkg_name} (wersja ${target_ver})"
curl -fsSL "$pkg_url" -o "$STAGING/${pkg_name}"
if [[ -n "${pkg_size}" && "${pkg_size}" != "None" && "${pkg_size}" != "" ]]; then
  got="$(wc -c <"$STAGING/${pkg_name}" | tr -d ' ')"
  [[ "$got" == "$pkg_size" ]] || { log "Niekompletne pobranie: $got != $pkg_size"; exit 1; }
fi
printf '%s  %s\n' "$pkg_sha" "$pkg_name" >"$STAGING/${pkg_name}.sha256"
curl -fsSL "$pkg_sig" -o "$STAGING/${pkg_name}.sig"
verify_pkg "$STAGING/${pkg_name}"

chmod 755 "$STAGING/$BOOT_NAME"
log "Wszystkie podpisy OK — uruchamiam bootstrap --offline"
# Nie usuwaj staging przed koncem bootstrapu (exec)
trap - EXIT
exec bash "$STAGING/$BOOT_NAME" --offline "$STAGING/${pkg_name}"
