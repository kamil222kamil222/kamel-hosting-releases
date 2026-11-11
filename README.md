# Kamel Hosting

Panel hostingowy dla Ubuntu: WWW, WordPress, PHP, MariaDB, Redis, DNS, SSL, poczta, kopie zapasowe i aktualizacje.

**STABLE:** [0.17.11](https://github.com/kamil222kamil222/kamel-hosting-releases/releases/tag/v0.17.11) · [Wydania](https://github.com/kamil222kamil222/kamel-hosting-releases/releases)

---

## Instalacja Kamel Hosting — jedna komenda

Na czystym **Ubuntu Server 24.04 LTS AMD64** zaloguj się jako **root** (lub `sudo -i`) i wklej:

```bash
curl -fsSLO https://raw.githubusercontent.com/kamil222kamil222/kamel-hosting-releases/main/kamel-install.sh && echo '3734ef4bb730a81f22de59b4049087361b574031b0913f508ed1935b46a6985d  kamel-install.sh' | sha256sum -c - && bash kamel-install.sh
```

Ta jedna linia: pobiera oficjalny launcher → sprawdza **przypięty SHA256** → uruchamia go dopiero po zgodności.  
Launcher wykrywa najnowszy **STABLE**, weryfikuje **SHA256 + Ed25519**, instaluje stos i uruchamia kreator (domena / e-mail).  
Jeśli `sha256sum` zgłosi błąd — **nie kontynuuj**.

Szczegóły zaufania: [INSTALL-TRUST.md](INSTALL-TRUST.md)

---

## Wymagania

| | |
|--|--|
| System | Ubuntu Server **24.04 LTS**, **AMD64** |
| RAM | min. **2 GB** (zalecane 4 GB+) |
| Dysk | min. **4 GB** wolnego (zalecane 20 GB+) |
| Uprawnienia | **sudo** / root |
| Sieć | Internet |
| Porty | **80**, **443** (+ poczta wg potrzeb) |
| Środowisko | zalecany **czysty** VPS |

---

## Pierwsze logowanie

1. Po instalacji otwórz adres z raportu końcowego (domena lub tunel SSH do portu 80).
2. Ustaw hasło administratora.
3. Włącz **2FA**.
4. Dodaj domenę w **WWW**, WordPress, **SSL**.
5. Sprawdź **Kopie zapasowe** i **Aktualizacje**.

---

## Funkcje

WWW · WordPress · PHP 8.3 · MariaDB · Redis · DNS · SSL · poczta + Roundcube · kopie zapasowe · użytkownicy · 2FA · aktualizacje panelu

---

## Automatyczne aktualizacje

Od **0.17.10** na nowych instalacjach: `auto_apply=true`, tylko podpisane STABLE, backup przed aktualizacją, kontrola usług, rollback, dzwonek z changelogiem, możliwość wyłączenia w panelu. Bez automatycznego rebootu całego VPS. Aktualizacje Ubuntu (APT) są osobne.

---

## Pobieranie

| | |
|--|--|
| Launcher | [kamel-install.sh](kamel-install.sh) · [SHA256](kamel-install.sh.sha256) · [sig](kamel-install.sh.sig) |
| Pakiety STABLE | [Releases](https://github.com/kamil222kamil222/kamel-hosting-releases/releases) |
| Weryfikacja | [INSTALL-TRUST.md](INSTALL-TRUST.md) |
| Issues | [Issues](https://github.com/kamil222kamil222/kamel-hosting-releases/issues) |
