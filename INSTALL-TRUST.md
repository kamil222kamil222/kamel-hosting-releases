# Kamel Hosting — weryfikacja instalacji (dokumentacja techniczna)

Ten dokument opisuje łańcuch zaufania. **Krótka instrukcja dla użytkownika** jest w [README](README.md) (3 linie).

## Trust anchor w instrukcji publicznej

W README jest **przypięty SHA256** konkretnego pliku `bootstrap-github-WERSJA.sh` z wydania STABLE.

```text
curl … bootstrap-github-WERSJA.sh
echo 'PRZYPINANY_SHA256  bootstrap-github-WERSJA.sh' | sha256sum -c -
sudo bash bootstrap-github-WERSJA.sh --stable
```

- Linia 1: pobranie wersjonowanego bootstrapa z GitHub Releases (nie z gałęzi `main`).
- Linia 2: porównanie z sumą **wpisaną w dokumentacji** — to kotwica zaufania wobec CDN/GitHub.
- Linia 3: uruchomienie **tylko** po udanej weryfikacji SHA256. To **nie** jest `curl | bash`.

## Co robi bootstrap po uruchomieniu

1. Preflight: Ubuntu 24.04 LTS AMD64, RAM, dysk, sieć.
2. Pobranie `channel-manifest.json` (+ `.sha256`, `.sig`) z najnowszego non-prerelease STABLE.
3. Weryfikacja SHA256 + **Ed25519** przypiętym kluczem w bootstrapie  
   `387c48338b9b473a4d01da37a1e78d74080b3fd2a9b64edfe6ab7d29885f7277`.
4. Pobranie pakietu `kamel-hosting-install-*.tar.gz` wg manifestu.
5. Ponowna weryfikacja SHA256 + Ed25519.
6. Rozpakowanie i kreator instalacji PL.

## Aktualizacja instrukcji przy nowym STABLE

Artefakty Release są **immutable**. Przy publikacji `vX.Y.Z`:

1. Policz SHA256 nowego `bootstrap-github-X.Y.Z.sh`.
2. Zaktualizuj **3 linie** w publicznym README (URL + hash + nazwa pliku).
3. Zaktualizuj Release Notes (link do README).
4. Nie podmieniaj plików starszych wydań.

Szablon utrzymywany w prywatnym repo: `docs/releases-repo-README.md`, skrypt bootstrapa: `packaging/bootstrap-github.sh` (publikowany jako podpisany artefakt).

## Offline

```bash
sudo bash bootstrap-github-WERSJA.sh --offline /ścieżka/do/kamel-hosting-install-WERSJA.tar.gz
```

Pakiet i sidecary muszą pochodzić z tego samego wydania.
