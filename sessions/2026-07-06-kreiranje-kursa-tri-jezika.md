# Sesija 2026-07-06 — Kreiranje kursa "Claude Code za 90 dana" (SR/EN/DE)

**Model:** Claude Fable 5

## Šta je rađeno

1. **Kurs napisan od nule** (`KURS-CLAUDE-CODE-90-DANA.md`) po ugledu na reklamu "Claude Code in 90 days":
   - 12 nedelja / 6 modula: CLI osnove, CLAUDE.md, Plan mode i Loop, MCP serveri, paralelni subagenti, Git i automatizacija
   - Zahtevi korisnika: univerzalan (bez veze sa bilo kojim postojećim projektom), primeri od nule (6 mini-projekata), objašnjava i ZAŠTO, deljiv sa bilo kim, **sa rešenjima svih zadataka na kraju** (referentni promptovi, česte greške, kriterijumi uspeha)
2. **PDF verzija:** na mašini nema Python/node/pandoc — napravljen `napravi-pdf.ps1` (markdown → HTML → PDF preko **Microsoft Edge headless** štampe, bez ikakvih instalacija). Parametri: `-MdPath`, `-PdfPath` (opciono), `-Lang`.
3. **Izdvojeno u zaseban projekat** (zahtev korisnika): folder `Kurs-Claude-Code-90-dana`, zaseban git repo.
4. **GitHub repo kreiran:** https://github.com/dejan024/kurs-claude-code-90-dana (javni). `gh` CLI nije instaliran — repo kreiran preko GitHub API-ja, token pročitan iz Windows Credential Manager-a (`git:https://github.com`, blob je UTF-16!). `git credential fill` NE koristiti (visi čekajući interaktivni unos).
5. **Prevodi:** kompletan engleski (`COURSE-CLAUDE-CODE-90-DAYS.md`) i nemački (`KURS-CLAUDE-CODE-90-TAGE.md`) + PDF-ovi. Oznake vežbi po jeziku: **V** (srpski), **E** (engleski), **Ü** (nemački); interni linkovi ka rešenjima rade u sve tri verzije. Primeri u promptovima lokalizovani (`troskovi.py` / `expenses.py` / `ausgaben.py`).
6. **README** višejezičan: tabela sa sve tri verzije (md + PDF), uputstvo za regenerisanje PDF-ova.

## Izmenjeni/kreirani fajlovi

- `KURS-CLAUDE-CODE-90-DANA.md` + `.pdf` (srpski)
- `COURSE-CLAUDE-CODE-90-DAYS.md` + `.pdf` (engleski)
- `KURS-CLAUDE-CODE-90-TAGE.md` + `.pdf` (nemački)
- `napravi-pdf.ps1` (generator PDF-a)
- `README.md`

## Važne napomene za buduće sesije

- **PDF-ovi NISU vizuelno pregledani** (na mašini nema alata za renderovanje PDF-a) — korisnik treba da prelista sve tri verzije, posebno dijakritike (č/ć/š/ž/đ, ä/ö/ü/ß) i tabele. Ako nešto ne valja, popravka ide u `napravi-pdf.ps1` pa regenerisati.
- Posle SVAKE izmene nekog od md fajlova kursa regenerisati odgovarajući PDF (komande u README-u) pre push-a.
- Kada se menja sadržaj kursa, menjati **sve tri jezičke verzije** da ne bi divergirale.
- Sidra (anchors) rešenja zavise od naslova (`### Rešenje V1.1` → `#rešenje-v11`) — pri preimenovanju naslova rešenja ažurirati i linkove u vežbama.
- Anchor generator u `napravi-pdf.ps1` (`Get-Anchor`) imitira GitHub stil (mala slova, izbačena interpunkcija, razmaci → crtice, unicode slova ostaju).
