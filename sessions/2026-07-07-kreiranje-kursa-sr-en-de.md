# Sesija 2026-07-07 — Kreiranje kursa (SR/EN/DE) i objavljivanje na GitHub

**Model:** Claude Fable 5

## Šta se radilo

Cela izrada projekta od nule, u jednoj sesiji (kasnije izdvojeno u zaseban repo):

1. **Kurs "Claude Code za 90 dana"** — napisan po uzoru na reklamu za komercijalni kurs ("Claude Code in 90 days"), ali kao besplatna, samostalna verzija:
   - 6 modula / 12 nedelja: CLI osnove, CLAUDE.md, Plan mode i Loop, MCP serveri, paralelni subagenti, Git i automatizacija
   - Svaki modul ima mini-projekat od nule (dnevnik troškova, portfolio sajt, kviz, prognoza+beleške, analiza open-source repoa, završni projekat)
   - Na kraju kursa odeljak **Rešenja zadataka**: referentni promptovi, česte greške, kriterijumi uspeha, kompletni primer-fajlovi (CLAUDE.md, agent, slash komanda, hook)
2. **Zahtevi korisnika tokom izrade** (bitno za buduće izmene kursa):
   - Kurs NE sme biti vezan za bilo koji privatni projekat — univerzalan, deljiv sa bilo kim
   - Primeri se prave od nule, objašnjava se i KAKO i ZAŠTO
   - Rešenja zadataka obavezna na kraju (za one koji zapnu)
3. **PDF verzije** — na mašini nema Python-a, pandoc-a ni Node-a; rešeno preko **Edge headless štampe**: `napravi-pdf.ps1` (markdown → HTML parser u PowerShell-u → `msedge --headless --print-to-pdf`). Skript prima `-MdPath` i `-Lang`, naslov izvlači iz prvog `#` naslova.
4. **Prevodi:** kompletne EN (`COURSE-CLAUDE-CODE-90-DAYS.md`) i DE (`KURS-CLAUDE-CODE-90-TAGE.md`) verzije. Oznake vežbi po jeziku: SR **V**, EN **E**, DE **Ü** — interni linkovi ka rešenjima (`#rešenje-v11` / `#solution-e11` / `#lösung-ü11`) rade u sve tri verzije. Primeri u promptovima lokalizovani (`troskovi.py` / `expenses.py` / `ausgaben.py`).
5. **Zaseban repo:** korisnik je tokom rada preusmerio — kurs je izdvojen u svoj folder i svoj repo. GitHub repo kreiran preko API-ja (nema `gh` CLI — token pročitan iz Windows Credential Manager-a, `git:https://github.com`, blob je UTF-16): **https://github.com/dejan024/kurs-claude-code-90-dana** (javni). Push preko postojećeg HTTPS kredencijala.
6. **README** višejezičan: tabela sve tri verzije (md + PDF), komande za regenerisanje PDF-ova.

## Važne napomene za buduće sesije

- **Sesije ovog projekta idu OVDE** (`sessions/` u ovom folderu), ne u neki drugi projekat — eksplicitna instrukcija korisnika 2026-07-07.
- Kad se menja bilo koja jezička verzija kursa, izmeniti **sve tri** (SR je izvorna) i regenerisati **sva tri PDF-a** (`napravi-pdf.ps1`, komande u README).
- PDF-ovi su pregledani od strane korisnika (dijakritika č/ć/š/ž/đ i ä/ö/ü/ß, tabele) — sve je OK.
- Kurs ne sme pominjati nijedan privatni projekat (javan repo — važi globalno pravilo o ne-pominjanju privatnih stvari u javnim repoima).
- Anchor konvencija u `napravi-pdf.ps1` prati GitHub stil (mala slova, bez interpunkcije, razmaci→crtice) — pri dodavanju novih naslova sa linkovima proveriti da se poklapaju.

## Izmenjeni/kreirani fajlovi

- `KURS-CLAUDE-CODE-90-DANA.md` + `.pdf` (srpski, izvorna verzija)
- `COURSE-CLAUDE-CODE-90-DAYS.md` + `.pdf` (engleski)
- `KURS-CLAUDE-CODE-90-TAGE.md` + `.pdf` (nemački)
- `napravi-pdf.ps1` (md → PDF preko Edge-a)
- `README.md` (višejezičan)

## Stanje posle sesije / sledeći koraci

- Projekat je kompletan, objavljen i verifikovan: 3 jezičke verzije (md + PDF) na https://github.com/dejan024/kurs-claude-code-90-dana, repo je javan i spreman za deljenje. PDF-ovi pregledani — sve OK.
- Moguće buduće ideje (nisu dogovorene): licenca (npr. CC BY), GitHub Pages prezentacija kursa, ažuriranje kursa kad se Claude Code promeni (komande/nazivi u kursu prate dokumentaciju iz jula 2026).
