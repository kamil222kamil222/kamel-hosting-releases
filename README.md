# Kamel Hosting

Panel hostingowy do zarządzania witrynami, WordPressem, PHP, bazami, pocztą, DNS, SSL i kopiami zapasowymi na serwerze Ubuntu.

**Aktualna wersja STABLE:** [0.17.11](https://github.com/kamil222kamil222/kamel-hosting-releases/releases/tag/v0.17.11)  
**Oficjalne wydania:** [GitHub Releases](https://github.com/kamil222kamil222/kamel-hosting-releases/releases)

---

## Szybka instalacja

Na **czystym** VPS z Ubuntu Server **24.04 LTS AMD64** zaloguj się jako root (lub przez `sudo`) i wklej **cały** blok poniżej.

Komenda **nie** jest niezweryfikowanym `curl | bash`.  
Zawiera **przypięty klucz publiczny Ed25519**. Bootstrap jest pobierany z GitHub Releases i uruchamiany **dopiero po** sprawdzeniu SHA256 oraz podpisu.

```bash
sudo bash <<'KAMEL_INSTALL'
set -euo pipefail
PINNED_PUB_HEX="387c48338b9b473a4d01da37a1e78d74080b3fd2a9b64edfe6ab7d29885f7277"
RELEASES_REPO="kamil222kamil222/kamel-hosting-releases"
need(){ command -v "$1" >/dev/null 2>&1 || { echo "Brak: $1" >&2; exit 1; }; }
need curl; need python3; need sha256sum; need awk; need tar
WORK=$(mktemp -d /tmp/kamel-get.XXXXXX); trap 'rm -rf "$WORK"' EXIT
curl -fsSL -H 'Accept: application/vnd.github+json' -H 'User-Agent: kamel-hosting-installer' \
  "https://api.github.com/repos/${RELEASES_REPO}/releases?per_page=30" -o "$WORK/releases.json"
eval "$(RELEASES_JSON="$WORK/releases.json" python3 - <<'PY'
import json,os,re,shlex,sys
from pathlib import Path
rels=json.loads(Path(os.environ["RELEASES_JSON"]).read_text(encoding="utf-8"))
for rel in rels:
    if rel.get("draft") or rel.get("prerelease"):
        continue
    assets={a.get("name"):a for a in (rel.get("assets") or []) if a.get("name")}
    boot=next((n for n in assets if re.fullmatch(r"bootstrap-github-\d+\.\d+\.\d+\.sh", n or "")), None)
    if not boot: continue
    need=[boot,boot+".sha256",boot+".sig","channel-manifest.json","channel-manifest.json.sha256","channel-manifest.json.sig"]
    if any(n not in assets for n in need): continue
    print("TAG="+shlex.quote(rel.get("tag_name") or ""))
    print("BOOT_NAME="+shlex.quote(boot))
    print("BOOT_URL="+shlex.quote(assets[boot]["browser_download_url"]))
    print("BOOT_SHA_URL="+shlex.quote(assets[boot+".sha256"]["browser_download_url"]))
    print("BOOT_SIG_URL="+shlex.quote(assets[boot+".sig"]["browser_download_url"]))
    sys.exit(0)
print("echo 'Brak STABLE' >&2; exit 2")
PY
)"
echo "STABLE ${TAG} → ${BOOT_NAME}"
curl -fsSL "$BOOT_URL" -o "$WORK/$BOOT_NAME"
curl -fsSL "$BOOT_SHA_URL" -o "$WORK/${BOOT_NAME}.sha256"
curl -fsSL "$BOOT_SIG_URL" -o "$WORK/${BOOT_NAME}.sig"
ACTUAL=$(sha256sum "$WORK/$BOOT_NAME" | awk '{print $1}')
EXPECTED=$(awk '{print $1}' "$WORK/${BOOT_NAME}.sha256" | tr -d '\r\n' | tr 'A-F' 'a-f')
[[ "$ACTUAL" == "$EXPECTED" ]] || { echo "SHA256 NIEZGODNY"; exit 1; }
echo "SHA_OK"
PKG="$WORK/$BOOT_NAME" PINNED_PUB_HEX="$PINNED_PUB_HEX" python3 - <<'PY'
import os
from pathlib import Path
try:
    from nacl.signing import VerifyKey
    from nacl.exceptions import BadSignatureError
except ImportError:
    import subprocess
    subprocess.check_call(["apt-get","install","-y","-qq","python3-nacl"], stdout=subprocess.DEVNULL)
    from nacl.signing import VerifyKey
    from nacl.exceptions import BadSignatureError
pkg=Path(os.environ["PKG"]); pub=bytes.fromhex(os.environ["PINNED_PUB_HEX"])
digest=Path(str(pkg)+".sha256").read_text(encoding="utf-8").strip().split()[0].strip().lower()
sig=Path(str(pkg)+".sig").read_bytes()
if len(sig.strip())==128:
    try: sig=bytes.fromhex(sig.strip().decode())
    except Exception: pass
vk=VerifyKey(pub); ok=False
for msg in (digest.encode("ascii"), (digest+"\n").encode("ascii")):
    try:
        vk.verify(sig+msg); ok=True; break
    except BadSignatureError: pass
    try:
        vk.verify(msg, sig); ok=True; break
    except Exception: pass
if not ok: raise SystemExit("SIG_FAIL")
print("SIG_OK")
PY
chmod 755 "$WORK/$BOOT_NAME"
exec bash "$WORK/$BOOT_NAME" --stable
KAMEL_INSTALL
```

Po weryfikacji uruchomi się kreator instalacji po polsku. Na końcu zobaczysz adres panelu i dalsze kroki.

### Instalacja offline (bez GitHub API)

1. Pobierz z [wydania STABLE](https://github.com/kamil222kamil222/kamel-hosting-releases/releases/latest):  
   `bootstrap-github-*.sh`, `.sha256`, `.sig` oraz pakiet `kamel-hosting-install-*.tar.gz` (+ sidecary).  
2. Skopiuj pliki na serwer.  
3. Zweryfikuj bootstrap (SHA256 + Ed25519), potem:

```bash
sudo bash bootstrap-github-0.17.11.sh --offline /ścieżka/do/kamel-hosting-install-0.17.11.tar.gz
```

---

## Wymagania systemowe

| Wymaganie | Wartość |
|--|--|
| System | Ubuntu Server **24.04 LTS** |
| Architektura | **AMD64** (`x86_64`) |
| RAM | minimum **2 GB** (zalecane 4 GB+) |
| Dysk | minimum **4 GB** wolnego na `/` (zalecane 20 GB+ pod witryny i kopie) |
| Uprawnienia | konto **root** / `sudo` |
| Sieć | dostęp do Internetu (APT + GitHub Releases) |
| Porty WWW | **80** i **443** (publicznie, do SSL i panelu) |
| Porty poczty (opcjonalnie) | 25 / 465 / 587 / 993 — według konfiguracji poczty |
| DNS | rekord A/AAAA domeny panelu i witryn wskazujący na VPS |
| Środowisko | zalecany **czysty VPS** (bez HestiaCP / innego panelu na tych samych portach) |

Instalator odrzuca inne dystrybucje, inne wersje Ubuntu oraz architekturę inną niż AMD64.

---

## Pierwsze uruchomienie

1. **Otwórz panel** pod adresem podanym na końcu instalacji (domena panelu lub tunel SSH do portu 80).  
2. **Konto administratora** — dokończ konfigurację hasła w kreatorze / stronie setup (link z tokenem jest wyświetlany po instalacji).  
3. **2FA** — w panelu włącz dwuskładnikowe logowanie dla konta administratora.  
4. **Pierwsza domena** — sekcja WWW → dodaj witrynę.  
5. **WordPress** — przy tworzeniu witryny wybierz WordPress albo użyj zakładki WordPress.  
6. **SSL** — wystaw certyfikat Let’s Encrypt dla domeny (wymagany poprawny DNS).  
7. **Kopie zapasowe** — zakładka Kopie zapasowe (harmonogram i ręczne kopie).  
8. **Aktualizacje** — zakładka Aktualizacje (panel Kamel Hosting oraz osobno aktualizacje systemu Ubuntu).

Nie publikujemy przykładowych haseł produkcyjnych.

---

## Automatyczne aktualizacje

Od wersji **0.17.10** na **nowych instalacjach**:

- automatyczne aktualizacje **Kamel Hosting** są **domyślnie włączone**;
- instalowane są wyłącznie zgodne, **podpisane** wydania **STABLE**;
- przed aktualizacją wykonywany jest **backup**;
- po aktualizacji sprawdzany jest stan kluczowych usług;
- administrator może **wyłączyć** automatyczne aktualizacje w panelu;
- aktualizacje **Ubuntu (APT)** to osobny mechanizm — nie mylić z aktualizacjami panelu.

Awaria aktualizacji nie gwarantuje bezwarunkowego przywrócenia wszystkich danych — zawsze utrzymuj własne kopie poza VPS.

---

## Funkcje panelu

| Obszar | Co robi |
|--|--|
| WWW | Witryny, nginx, izolacja użytkowników PHP-FPM |
| WordPress | Instalacja, administracja, cache, klon/staging |
| PHP | PHP 8.3, pule FPM, OPcache |
| MariaDB | Bazy i użytkownicy baz powiązane z witrynami |
| Redis | Redis Object Cache dla WordPress (izolacja prefiksem) |
| DNS | Strefy i rekordy w panelu (lokalna konfiguracja) |
| SSL | Let’s Encrypt dla domen panelu i witryn |
| Poczta | Konta pocztowe, aliasy; webmail Roundcube |
| Kopie zapasowe | Kopie witryn i kont, harmonogram, przywracanie |
| Użytkownicy | Konta klientów / limity zasobów |
| Bezpieczeństwo | Hasła, sesje, 2FA administratora |
| Aktualizacje | Kanał STABLE z GitHub Releases + opcjonalne auto-aktualizacje |

---

## Bezpieczeństwo instalacji

- Klucz prywatny podpisu **nigdy** nie jest publikowany.  
- Klucz publiczny Ed25519 jest **przypięty** w bootstrapie / komendzie instalacji (`387c4833…7277`).  
- Każdy pakiet ma pliki `.sha256` i `.sig`.  
- Wydania STABLE mają **immutable** artefakty — historyczne pliki nie są podmieniane.  
- Nie instaluj pakietów z nieznanego źródła ani bez sidecarów.

Fingerprint klucza (hex):

```text
387c48338b9b473a4d01da37a1e78d74080b3fd2a9b64edfe6ab7d29885f7277
```

---

## Wsparcie

- Problemy z instalacją i wydaniami: [Issues](https://github.com/kamil222kamil222/kamel-hosting-releases/issues)  
- Kod źródłowy panelu jest prywatny; tutaj publikowane są wyłącznie podpisane artefakty.
