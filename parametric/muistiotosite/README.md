# Muistiotosite (Typst)

Dokumenttipohja muistiotositteille.

## Käyttö

1. Kopioi `muistiotosite.typ` uudeksi tiedostoksi (esim. `MT-2026-01.typ`) tositteiden kansioon:
   ```bash
   cp tools/muistiotosite/muistiotosite.typ data/tositteet/2026/MT-2026-01.typ
   ```
2. Avaa tiedosto ja muokkaa sitä:
   - Muuta tiedoston alussa olevat muuttujat (`numero`, `paivays`, `otsikko`, `allekirjoittajat`).
   - Kirjoita kuvausteksti suoraan leipätekstinä.
   - Muokkaa kirjausvientitaulukon (`#table(...)`) rivejä.
   - Muokkaa liiteluetteloa.
3. Käännä PDF:ksi:
   ```bash
   typst compile MT-2026-01.typ
   ```

## Allekirjoitukset

Allekirjoittajat määritellään tiedoston alussa listana:

```typst
#let allekirjoittajat = (
  ("Etunimi Sukunimi", "Rahastonhoitaja"),
  ("Matti Meikäläinen", "Puheenjohtaja"),
)
```

## PDF-liitteiden liittäminen

PDF- ja kuvatodisteet voi liittää suoraan tiedoston loppuun Typstin `#image()`-komennolla:

```typst
#pagebreak()
= Liite 1: Tosite tai tiliote
#image("tiliote.pdf", width: 100%)

#pagebreak()
= Liite 2: Myyntiraportti sivu 1
#image("raportti.pdf", page: 1, width: 100%)
```
