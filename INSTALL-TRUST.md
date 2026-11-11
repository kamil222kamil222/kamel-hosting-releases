# Weryfikacja instalacji Kamel Hosting (dokumentacja techniczna)

## Jedna komenda użytkownika

```bash
curl -fsSLO https://raw.githubusercontent.com/kamil222kamil222/kamel-hosting-releases/main/kamel-install.sh && echo '<SHA256>  kamel-install.sh' | sha256sum -c - && sudo bash kamel-install.sh
```

To **nie** jest `curl | bash`. Kolejność jest wymuszona przez `&&`:

1. Pobranie `kamel-install.sh`
2. Porównanie z **przypiętym SHA256** (trust anchor w instrukcji)
3. Uruchomienie **tylko** przy zgodności

## Co robi launcher po weryfikacji SHA256

1. Preflight narzędzi (curl, python3, …)
2. Wyszukanie najnowszego non-prerelease STABLE w GitHub Releases
3. Pobranie `bootstrap-github-*.sh` + `.sha256` + `.sig`
4. Weryfikacja SHA256 + **Ed25519** kluczem przypiętym w launcherze  
   `387c48338b9b473a4d01da37a1e78d74080b3fd2a9b64edfe6ab7d29885f7277`
5. Bootstrap weryfikuje `channel-manifest.json` i pakiet install (ponownie SHA256 + Ed25519)
6. Kreator / instalacja stosu

Sidecar `kamel-install.sh.sig` jest publikowany dodatkowo; kotwicą w komendzie użytkownika jest SHA256 (czytelne, krótkie).

## Aktualizacja komendy

Launcher zmienia się rzadko. Gdy zmieni się `kamel-install.sh`:

1. `python3 packaging/gen-one-command.py`
2. Opublikuj `kamel-install.sh`, `.sha256`, `.sig` oraz README z nową sumą
3. Pakiety STABLE mogą iść naprzód bez zmiany komendy, dopóki launcher jest ten sam

## Odrzucanie podmiany

Zmiana bajtu w pobranym `kamel-install.sh` → `sha256sum -c` kończy się błędem → instalacja nie startuje.
