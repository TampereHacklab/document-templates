// Tampere Hacklab ry — Muistiotosite (Accounting Voucher)
// Kopioi tämä tiedosto (esim. MT-2026-01.typ), muokkaa vapaasti ja käännä:
// typst compile MT-2026-01.typ

#let numero = "MT-202X-XX"
#let paivays = "202X-XX-XX"
#let otsikko = "Tositteen aihe tai otsikko"

#let allekirjoittajat = (
  ("Etunimi Sukunimi", "Rahastonhoitaja"),
  ("Matti Meikäläinen", "Puheenjohtaja"),
)

#set document(title: [Muistiotosite #numero --- #otsikko])

#set page(
  paper: "a4",
  margin: 2.5cm,
  header: [
    #smallcaps[
      #grid(
        columns: (1fr, auto, 1fr),
        align(left)[*Tampere Hacklab ry*],
        align(center)[Muistiotosite],
        align(right)[#paivays]
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.4pt)
    ]
  ],
  footer: context [
    #if counter(page).final().first() > 1 [
      #align(center)[Sivu #counter(page).display("1/1", both: true)]
    ]
  ]
)

// Global text settings
#set text(lang: "fi", size: 11pt)
#set par(justify: true)

// --- FIRST PAGE HEADER SECTION ---
#grid(
  columns: (1fr, auto),
  align: (left, horizon),
  [
    *Tampere Hacklab ry* \
    Ahlmanintie 56, 33800 Tampere \
    Y-tunnus: 2419748-5 \
    hallitus\@tampere.hacklab.fi
  ],
  // Fancy logo drawn entirely in typst
  [
    #scale(x: 75%, y: 75%, origin: right + horizon, reflow: true)[
      #box(width: 124pt, height: 124pt, stroke: 1.5pt + black)[
        #align(center + horizon)[
          #box(width: 38pt, height: 62pt)[
            #polygon(
              fill: black,
              (10pt, 0pt), (10pt, 16pt), (0pt, 16pt), (0pt, 20pt), (24pt, 20pt),
              (24pt, 16pt), (14pt, 16pt), (14pt, 4pt), (34pt, 4pt), (34pt, 58pt),
              (14pt, 58pt), (14pt, 26pt), (21pt, 26pt), (21pt, 22pt), (3pt, 22pt),
              (3pt, 26pt), (10pt, 26pt), (10pt, 62pt), (38pt, 62pt), (38pt, 0pt)
            )
          ]
        ]
        
        #set text(size: 5pt, font: "Dejavu Sans Mono", tracking: 0.2pt)
        
        #place(top + center, dy: 6pt)[Tampere Hacklab, Ahlmanintie 56,]
        #place(right + horizon, dx: 38pt)[#rotate(90deg)[33800 Tampere FINLAND, phone ]]
        #place(bottom + center, dy: -6pt)[#rotate(180deg)[+358 93157 6905, info\@tampere]]
        #place(left + horizon, dx: -38pt - 5pt)[#rotate(270deg)[.hacklab.fi, tampere.hacklab.fi]]
      ]
    ]
  ]
)

// --- MAIN HEADING & VOUCHER METADATA ---
#v(0.5cm)
#align(center)[
  #text(size: 16pt, weight: "bold", hyphenate: false)[#otsikko] \
  #v(0.4em)
  #text(size: 10pt)[*Nro:* #numero #h(2.5em) *Päiväys:* #paivays]
]
#v(0.3cm)
#line(length: 100%, stroke: 0.4pt)
#v(0.5cm)

// --- KUVAUS / PERUSTELUT ---
Tähän kirjoitetaan muistiotositteen taustat ja perustelut sekä kuvaus siitä, mitä
tällä tositteella kirjataan tai oikaistaan kirjanpidossa.

Kirjaukset perustuvat liitteenä oleviin tositteisiin, raportteihin tai tiliotteisiin.

#v(1em)

// --- KIRJAUSVIENNIT ---
*Kirjausviennit*
#v(0.5em)

#table(
  columns: (auto, 1fr, auto, auto),
  stroke: (x, y) => if y == 0 { (bottom: 1pt + black) } else { 0.5pt + luma(200) },
  fill: (x, y) => if y == 0 { luma(245) } else { none },
  inset: (x: 8pt, y: 7pt),
  align: (col, row) => (
    if col < 2 { left + horizon } else { right + horizon }
  ),
  table.header(
    [*Tili*], [*Tilin nimi / Selite*], [*Debet*], [*Kredit*]
  ),
  [1910], [Pankkitili (Seliteteksti)], [100,00 €], [],
  [4920], [Kulutili (Seliteteksti)], [20,00 €], [],
  [1700], [Selvittelytili / Vastatili], [], [120,00 €],
  // Yhteensä-rivi (valinnainen):
  // table.cell(stroke: (top: 1pt + black, bottom: 1pt + black))[],
  // table.cell(stroke: (top: 1pt + black, bottom: 1pt + black))[*Yhteensä*],
  // table.cell(stroke: (top: 1pt + black, bottom: 1pt + black))[*120,00 €*],
  // table.cell(stroke: (top: 1pt + black, bottom: 1pt + black))[*120,00 €*],
)

#v(1.5em)

// --- LIITTEET JA TODISTEET ---
*Liitteet ja todisteet*
#v(0.3em)

- Liite 1: Tosite, tiliote tai kuitti (PDF)
- Liite 2: Laskelma, myyntiraportti tai erittely (PDF/CSV)

#v(1.5cm)

// --- ALLEKIRJOITUKSET ---
// Funktio, joka renderöi 2 sarakkeen allekirjoitusruudukon (kuten poytakirja-pohjassa).
#let allekirjoituslohko(..args) = {
  let signers = if args.pos().len() > 0 {
    args.pos().first()
  } else if "allekirjoittajat" in args.named() {
    args.named().at("allekirjoittajat")
  } else if "signers" in args.named() {
    args.named().at("signers")
  } else {
    allekirjoittajat
  }

  if signers != () and signers.len() > 0 [
    #v(1.5cm)
    #block(breakable: false)[
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 2cm,
        row-gutter: 1.5cm,
        ..signers.map(s => {
          let (nimi, titteli) = if type(s) == array {
            (s.at(0, default: ""), s.at(1, default: ""))
          } else if type(s) == dictionary {
            (s.at("nimi", default: ""), s.at("rooli", default: s.at("titteli", default: "")))
          } else {
            (str(s), "")
          }
          [
            #v(1.5cm)
            #line(length: 100%, stroke: 0.5pt)
            #v(0.2cm)
            #nimi \
            #if titteli != "" [#titteli \ ]
            Tampere Hacklab ry
          ]
        })
      )
    ]
  ]
}

#allekirjoituslohko(allekirjoittajat)

// --- LIITTEET (PDF / KUVAT) ---
// Voit liittää PDF-tiedostoja tai kuvia suoraan tähän Typstin image-komennolla:
//
// #pagebreak()
// = Liite 1: Tosite tai tiliote
// #image("tiliote.pdf", width: 100%)
//
// Monisivuisesta PDF:stä sivukohtainen valinta:
// #image("raportti.pdf", page: 1, width: 100%)
// #pagebreak()
// #image("raportti.pdf", page: 2, width: 100%)
