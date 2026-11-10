# Kamel Hosting — Releases

Publiczne, podpisane pakiety instalacyjne i aktualizacyjne **Kamel Hosting**.

Kod źródłowy jest prywatny. Tutaj publikowane są wyłącznie artefakty do instalacji i aktualizacji serwerów Ubuntu.

## Status

| | |
|--|--|
| Pierwsze wydanie STABLE | **jeszcze nieopublikowane** |
| Docelowa wersja pierwszego STABLE | 0.17.8 (po zatwierdzeniu) |

Gdy pojawi się wydanie, znajdziesz je w zakładce **Releases** tego repozytorium.

## Co będzie w wydaniu STABLE

- bootstrap instalacji (`bootstrap-github-*.sh` + `.sha256` + `.sig`)
- pakiet instalacji (`kamel-hosting-install-*.tar.gz` + sidecary)
- pakiety aktualizacji ze wspieranych wersji (`kamel-hosting-update-*-to-*.tar.gz`)
- `channel-manifest.json` + `.sha256` + `.sig` (kanał **STABLE**)
- changelog i wymagania Ubuntu Server **24.04 LTS AMD64**

## Instalacja (po publikacji STABLE)

1. Pobierz bootstrap oraz pliki `.sha256` / `.sig` z Releases.  
2. Zweryfikuj SHA256 i podpis Ed25519 **zanim** uruchomisz skrypt.  
3. Nie używaj `curl … | bash` na niezweryfikowanym pliku.  
4. Postępuj zgodnie z instrukcją w Release Notes.

Do czasu publikacji STABLE nie ma oficjalnej komendy instalacji online.

## Aktualizacje

Zainstalowane serwery mogą sprawdzać ten kanał Releases.  
Weryfikacja podpisu i SHA256 jest obowiązkowa przed zastosowaniem pakietu.  
Automatyczne wdrażanie zależy od konfiguracji na serwerze (domyślnie ostrożne / wyłączone do czasu decyzji administratora).

## Zgłaszanie problemów

Użyj [Issues](https://github.com/kamil222kamil222/kamel-hosting-releases/issues) w tym repozytorium.

## Bezpieczeństwo

- Klucz prywatny Ed25519 **nigdy** nie jest publikowany tutaj.  
- HTTPS z GitHub nie zastępuje weryfikacji podpisu.  
- Nie instaluj pakietów z nieznanego źródła ani bez sidecarów `.sha256` / `.sig`.
