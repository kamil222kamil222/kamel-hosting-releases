# Kamel Hosting

Panel hostingowy dla Ubuntu: witryny WWW, WordPress, PHP, bazy, poczta, DNS, SSL, kopie zapasowe i aktualizacje — w jednym miejscu, po polsku.

**STABLE:** [0.17.11](https://github.com/kamil222kamil222/kamel-hosting-releases/releases/tag/v0.17.11) · [Wszystkie wydania](https://github.com/kamil222kamil222/kamel-hosting-releases/releases)

---

## Instalacja

Na czystym **Ubuntu Server 24.04 LTS AMD64** (jako root / `sudo`):

```bash
curl -fsSLO https://github.com/kamil222kamil222/kamel-hosting-releases/releases/download/v0.17.11/bootstrap-github-0.17.11.sh
echo '19a7474f63a18089c739f9c04d51ab07419b7969361682b454bc6579b2113dfc  bootstrap-github-0.17.11.sh' | sha256sum -c -
sudo bash bootstrap-github-0.17.11.sh --stable
```

Jeśli `sha256sum -c` zgłosi błąd — **nie uruchamiaj** skryptu (plik został zmieniony lub pobranie jest niekompletne).

Po weryfikacji bootstrap pobierze najnowszy zatwierdzony pakiet **STABLE**, sprawdzi podpisy i uruchomi kreator instalacji.

---

## Wymagania

| | |
|--|--|
| System | Ubuntu Server **24.04 LTS**, **AMD64** |
| RAM | min. **2 GB** (zalecane 4 GB+) |
| Dysk | min. **4 GB** wolnego na `/` (zalecane 20 GB+) |
| Uprawnienia | **root** / `sudo` |
| Sieć | Internet (APT + GitHub Releases) |
| Porty | **80**, **443** (oraz poczta wg potrzeb) |
| DNS | rekord A/AAAA domen wskazujący VPS |
| Środowisko | zalecany **czysty** VPS |

---

## Pierwsze logowanie

1. Po instalacji otwórz adres panelu podany przez kreator (domena lub tunel SSH do portu 80).
2. Ustaw hasło administratora (strona setup / link z instalacji).
3. Włącz **2FA** w ustawieniach konta.
4. Dodaj pierwszą domenę w **WWW**, zainstaluj WordPress w razie potrzeby, wystaw **SSL**.
5. Sprawdź **Kopie zapasowe** i **Aktualizacje**.

---

## Funkcje

WWW · WordPress · PHP 8.3 · MariaDB · Redis · DNS · SSL (Let’s Encrypt) · poczta + Roundcube · kopie zapasowe · użytkownicy · bezpieczeństwo (w tym 2FA) · aktualizacje panelu

---

## Automatyczne aktualizacje

Na nowych instalacjach (od **0.17.10**) automatyczne aktualizacje **Kamel Hosting STABLE** są **włączone domyślnie**: tylko podpisane wydania, backup przed aktualizacją, kontrola usług, możliwość wyłączenia w panelu. Aktualizacje Ubuntu (APT) są osobnym mechanizmem.

---

## Pobieranie i dokumentacja

| | |
|--|--|
| Wydania STABLE | [Releases](https://github.com/kamil222kamil222/kamel-hosting-releases/releases) |
| Instalator tej wersji | [bootstrap-github-0.17.11.sh](https://github.com/kamil222kamil222/kamel-hosting-releases/releases/download/v0.17.11/bootstrap-github-0.17.11.sh) |
| Weryfikacja kryptograficzna | [INSTALL-TRUST.md](INSTALL-TRUST.md) |
| Problemy | [Issues](https://github.com/kamil222kamil222/kamel-hosting-releases/issues) |

Offline: pobierz bootstrap + `kamel-hosting-install-*.tar.gz` (+ `.sha256` / `.sig`), potem  
`sudo bash bootstrap-github-0.17.11.sh --offline /ścieżka/do/pakietu.tar.gz`
