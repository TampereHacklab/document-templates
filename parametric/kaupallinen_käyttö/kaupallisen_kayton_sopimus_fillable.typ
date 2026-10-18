// Tampere Hacklab ry — Kaupallisen käytön sopimus (Commercial Use Agreement)
//
// Käyttöohje:
// 1. Voit syöttää sopimuksen tiedot suoraan alla oleviin muuttujiin tässä tiedostossa
//    tai ajaa komentoriviltä parametrina, esim:
//    typst compile --input jasen_nimi="Matti Meikäläinen" kaupallisen_kayton_sopimus.typ
// 2. Käännä PDF-tiedostoksi:
//    typst compile kaupallisen_kayton_sopimus.typ
// 3. Tyhjä pohja: Kun jätät muuttujat tyhjiksi (""), syntyy siisti tulostettava pohja
//    käsin täytettäviä merkintöjä ja allekirjoituksia varten.

// ==========================================
// 1. SOPIMUKSEN TIEDOT JA MUUTTUJAT
// ==========================================

// Sopimuksen perustiedot
#let sopimusnumero = sys.inputs.at("sopimusnumero", default: "")
#let paivays = sys.inputs.at("paivays", default: "")  // esim. "2026-09-29" tai "29.09.2026"

// 1. Sopijapuolet
#let hallituksen_edustajan_nimi = sys.inputs.at("hallituksen_edustajan_nimi", default: "")

#let jasen_nimi = sys.inputs.at("jasen_nimi", default: "")
#let jasen_y_tunnus = sys.inputs.at("jasen_y_tunnus", default: "")       // jos yritystoimintaa
#let jasennumero = sys.inputs.at("jasennumero", default: "")

#let huoltaja_nimi = sys.inputs.at("huoltaja_nimi", default: "")        // täytetään, jos jäsen on alaikäinen
#let huoltaja_yhteystiedot = sys.inputs.at("huoltaja_yhteystiedot", default: "") // puhelin / sähköposti

// 2. & 3. Toiminnan kuvaus & tilat
#let toiminnan_kuvaus = sys.inputs.at("toiminnan_kuvaus", default: "")
#let kaytettavat_tilat_ja_laitteet = sys.inputs.at("kaytettavat_tilat_ja_laitteet", default: "")

// 4. Sovittu korvaus yhteisölle
#let korvaus_rahallinen = sys.inputs.at("korvaus_rahallinen", default: false) == true or sys.inputs.at("korvaus_rahallinen", default: "false") == "true"
#let korvaus_talkootyo = sys.inputs.at("korvaus_talkootyo", default: false) == true or sys.inputs.at("korvaus_talkootyo", default: "false") == "true"
#let korvaus_materiaalikorvaus = sys.inputs.at("korvaus_materiaalikorvaus", default: false) == true or sys.inputs.at("korvaus_materiaalikorvaus", default: "false") == "true"
#let korvaus_tyopajojen_jarjestaminen = sys.inputs.at("korvaus_tyopajojen_jarjestaminen", default: false) == true or sys.inputs.at("korvaus_tyopajojen_jarjestaminen", default: "false") == "true"
#let korvaus_laitteiden_huolto = sys.inputs.at("korvaus_laitteiden_huolto", default: false) == true or sys.inputs.at("korvaus_laitteiden_huolto", default: "false") == "true"
#let korvaus_muu = sys.inputs.at("korvaus_muu", default: false) == true or sys.inputs.at("korvaus_muu", default: "false") == "true"
#let korvauksen_kuvaus = sys.inputs.at("korvauksen_kuvaus", default: "")

// 5. Erityisehdot
#let erityisehdot = sys.inputs.at("erityisehdot", default: "")

// 6. Sopimuksen voimassaolo
#let voimassaolo_toistaiseksi = sys.inputs.at("voimassaolo_toistaiseksi", default: false) == true or sys.inputs.at("voimassaolo_toistaiseksi", default: "false") == "true"
#let voimassaolo_maaraaikainen = sys.inputs.at("voimassaolo_maaraaikainen", default: false) == true or sys.inputs.at("voimassaolo_maaraaikainen", default: "false") == "true"
#let voimassa_asti = sys.inputs.at("voimassa_asti", default: "")        // esim. "31.12.2026" tai tyhjä

// 9. Allekirjoitukset
#let allekirjoitus_hacklab_nimi = sys.inputs.at("allekirjoitus_hacklab_nimi", default: "")
#let allekirjoitus_jasen_nimi = sys.inputs.at("allekirjoitus_jasen_nimi", default: "")
#let allekirjoitus_huoltaja_nimi = sys.inputs.at("allekirjoitus_huoltaja_nimi", default: "")


// ==========================================
// ASETUKSET JA TYYLIT
// ==========================================

#set document(
  title: [Kaupallisen käytön sopimus #if sopimusnumero != "" [#sopimusnumero]],
  author: "Tampere Hacklab ry"
)

#set text(lang: "fi", size: 10.5pt)
#set par(justify: true, leading: 0.6em)

#set page(
  paper: "a4",
  margin: (x: 2cm, top: 2.3cm, bottom: 1.8cm),
  header: [
    #set text(size: 11pt)
    #smallcaps[
      #grid(
        columns: (1fr, auto, 1fr),
        align(left)[*Tampere Hacklab ry*],
        align(center)[Kaupallisen käytön sopimus],
        []
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.4pt)
    ]
  ],
  footer: context [
    #align(center)[Sivu #counter(page).display("1/1", both: true)]
  ]
)

// typst-fillable metadata capture function
#let capture_field(
  field_name: "",
  field_type: "text",
  dimensions: none,
  content
) = {
  box({
    context {
      let pos = here().position()
      let size = if dimensions != none { dimensions } else {
        let m = measure(content)
        (width: m.width, height: m.height)
      }
      metadata((
        fieldName: field_name,
        fieldType: field_type,
        dimensions: (width: size.width, height: size.height),
        pos: (page: pos.page, x: pos.x, y: pos.y),
      ))
    }
    content
  })
}

// Tampere Hacklab ry -logo (identtinen muistiotositteen kanssa)
#let hacklab_logo(mittakaava: 75%) = {
  scale(x: mittakaava, y: mittakaava, origin: right + horizon, reflow: true)[
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
      #set text(size: 5pt, font: "DejaVu Sans Mono", tracking: 0.2pt)
      #place(top + center, dy: 6pt)[Tampere Hacklab, Ahlmanintie 56,]
      #place(right + horizon, dx: 38pt)[#rotate(90deg)[33800 Tampere FINLAND, phone ]]
      #place(bottom + center, dy: -6pt)[#rotate(180deg)[+358 93157 6905, info\@tampere]]
      #place(left + horizon, dx: -38pt - 5pt)[#rotate(270deg)[.hacklab.fi, tampere.hacklab.fi]]
    ]
  ]
}

// Apufunktio: Valintaruutu (checkbox) integroituna capture_fieldiin
#let valintaruutu(valittu: false, kentta: "", otsikko) = {
  box(baseline: 15%)[
    #capture_field(
      field_name: kentta,
      field_type: "checkbox",
      dimensions: (width: 9.5pt, height: 9.5pt),
    )[
      #box(
        width: 9.5pt,
        height: 9.5pt,
        stroke: 0.6pt + black,
        radius: 1.5pt,
        align(center + horizon)[
          #if valittu [
            #text(size: 8pt, weight: "bold")[#sym.times]
          ]
        ]
      )
    ]
    #h(6pt)
    #otsikko
  ]
}

// Apufunktio: Väliotsikko viivalla
#let osio(numero_ja_nimi) = {
  v(0.35em)
  block(width: 100%, breakable: false)[
    #text(size: 10.5pt, weight: "bold")[#numero_ja_nimi]
    #v(0.15em)
    #line(length: 100%, stroke: 0.4pt + luma(120))
  ]
  v(0.12em)
}

// Apufunktio: Tekstialue / laatikko kuvaukselle
#let kuvauslaatikko(arvo, kentta: "", korkeus: 36pt) = {
  capture_field(field_name: kentta, field_type: "textarea", dimensions: (width: 480pt, height: korkeus))[
    #rect(
      width: 100%,
      height: korkeus,
      stroke: 0.4pt + luma(180),
      radius: 2pt,
      fill: luma(252),
      inset: (x: 8pt, y: 5pt),
    )[
      #if arvo != "" and arvo != none [
        #set par(justify: false)
        #arvo
      ]
    ]
  ]
}


// ==========================================
// SIVU 1
// ==========================================

// --- FIRST PAGE HEADER SECTION (IDENTTINEN MUISTIOTOSITTEEN KANSSA: 11pt) ---
#grid(
  columns: (1fr, auto),
  align: (left, horizon),
  [
    #set text(size: 11pt)
    *Tampere Hacklab ry* \
    Ahlmanintie 56, 33800 Tampere \
    Y-tunnus: 2419748-5 \
    hallitus\@tampere.hacklab.fi
  ],
  [
    #hacklab_logo(mittakaava: 75%)
  ]
)

// --- MAIN HEADING & VOUCHER METADATA ---
#v(0.35cm)
#align(center)[
  #text(size: 16pt, weight: "bold", hyphenate: false)[Kaupallisen käytön sopimus] \
  #v(0.4em)
  #text(size: 10pt)[*Nro:* #capture_field(field_name: "sopimusnumero", field_type: "text", dimensions: (width: 50pt, height: 13pt))[#box(width: 50pt, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[#if sopimusnumero != "" [#sopimusnumero] else []]] #h(2.5em) *Päiväys:* #if paivays != "" [#paivays] else [#capture_field(field_name: "paiva_pv", field_type: "text", dimensions: (width: 20pt, height: 13pt))[#box(width: 20pt, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[]] / #capture_field(field_name: "paiva_kk", field_type: "text", dimensions: (width: 20pt, height: 13pt))[#box(width: 20pt, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[]] / #capture_field(field_name: "paiva_vuosi", field_type: "text", dimensions: (width: 32pt, height: 13pt))[#box(width: 32pt, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[]]]]
]
#v(0.3cm)
#line(length: 100%, stroke: 0.4pt)
#v(0.35cm)

// 1. SOPIJAPUOLET (TAULUKKORAKENNE)
#osio[1. Sopijapuolet]

#v(0.1em)
#table(
  columns: (auto, 1fr),
  stroke: 0.4pt + luma(180),
  inset: (x: 8pt, y: 4.5pt),
  fill: (col, row) => if col == 0 { luma(248) } else { none },
  align: (col, row) => (left + horizon),
  
  table.cell(colspan: 2, fill: luma(238))[*Tampere Hacklab ry*],
  [Hallituksen edustajan nimi], capture_field(field_name: "hallituksen_edustajan_nimi", field_type: "text", dimensions: (width: 310pt, height: 11pt))[#hallituksen_edustajan_nimi],
  
  table.cell(colspan: 2, fill: luma(238))[*Jäsen*],
  [Nimi], capture_field(field_name: "jasen_nimi", field_type: "text", dimensions: (width: 310pt, height: 11pt))[#jasen_nimi],
  [Y-tunnus (jos yritystoimintaa)], capture_field(field_name: "y_tunnus", field_type: "text", dimensions: (width: 310pt, height: 11pt))[#jasen_y_tunnus],
  [Jäsennumero], capture_field(field_name: "jasennumero", field_type: "text", dimensions: (width: 310pt, height: 11pt))[#jasennumero],
  
  table.cell(colspan: 2, fill: luma(238))[*Huoltaja (täytetään, jos jäsen on alaikäinen)*],
  [Nimi], capture_field(field_name: "huoltaja_nimi", field_type: "text", dimensions: (width: 310pt, height: 11pt))[#huoltaja_nimi],
  [Yhteystiedot (puhelin / sähköposti)], capture_field(field_name: "yhteystiedot", field_type: "text", dimensions: (width: 310pt, height: 11pt))[#huoltaja_yhteystiedot],
)

#v(0.3em)

// 2. TOIMINNAN KUVAUS
#osio[2. Toiminnan kuvaus]
#text(style: "italic", fill: luma(70), size: 9pt)[
  Kuvaile, mitä kaupallinen toiminta sisältää ja arvioi sen laajuus (esim. tuotteiden tai palveluiden määrä ja arvo kuukaudessa).
]
#v(0.2em)
#kuvauslaatikko(toiminnan_kuvaus, kentta: "toiminnan_kuvaus", korkeus: 95pt)

#v(0.3em)

// 3. KÄYTETTÄVÄT TILAT JA LAITTEET
#osio[3. Käytettävät tilat ja laitteet]
#text(style: "italic", fill: luma(70), size: 9pt)[
  Kuvaile, mitä Hacklabin tiloja ja laitteita kaupallisessa toiminnassa hyödynnetään.
]
#v(0.2em)
#kuvauslaatikko(kaytettavat_tilat_ja_laitteet, kentta: "kaytettavat_tilat_ja_laitteet", korkeus: 95pt)


// ==========================================
// SIVU 2
// ==========================================
#pagebreak()

// 4. SOVITTU KORVAUS YHTEISÖLLE
#osio[4. Sovittu korvaus yhteisölle]

*Korvauksen muoto:*
#v(0.15em)

#grid(
  columns: (1.2fr, 1fr),
  row-gutter: 0.45em,
  [
    #valintaruutu(valittu: korvaus_rahallinen, kentta: "korvaus_rahallinen")[Rahallinen korvaus]
  ],
  [
    #valintaruutu(valittu: korvaus_talkootyo, kentta: "korvaus_talkootyo")[Talkootyö]
  ],
  [
    #valintaruutu(valittu: korvaus_materiaalikorvaus, kentta: "korvaus_materiaalikorvaus")[Materiaalikorvaus]
  ],
  [
    #valintaruutu(valittu: korvaus_tyopajojen_jarjestaminen, kentta: "korvaus_tyopajojen_jarjestaminen")[Työpajojen järjestäminen]
  ],
  [
    #valintaruutu(valittu: korvaus_laitteiden_huolto, kentta: "korvaus_laitteiden_huolto")[Laitteiden huolto tai kunnossapito]
  ],
  [
    #valintaruutu(valittu: korvaus_muu, kentta: "korvaus_muu")[Muu]
  ]
)

#v(0.25em)
*Kuvaus:*
#v(0.12em)
#kuvauslaatikko(korvauksen_kuvaus, kentta: "korvauksen_kuvaus", korkeus: 36pt)

// 5. ERITYISEHDOT
#osio[5. Erityisehdot]
#text(style: "italic", fill: luma(70), size: 9pt)[
  Esimerkiksi työskentely vain ilmoitettuna aikana, enimmäiskäyttömäärä, varastointikäytännöt.
]
#v(0.12em)
#kuvauslaatikko(erityisehdot, kentta: "erityisehdot", korkeus: 36pt)

// 6. SOPIMUKSEN VOIMASSAOLO
#osio[6. Sopimuksen voimassaolo]

#valintaruutu(valittu: voimassaolo_toistaiseksi, kentta: "voimassaolo_toistaiseksi")[Toistaiseksi voimassa] \
#v(0.25em)
#valintaruutu(valittu: voimassaolo_maaraaikainen, kentta: "voimassaolo_maaraaikainen")[
  Voimassa #h(0.2em)
  #capture_field(field_name: "voimassa_asti_pv", field_type: "text", dimensions: (width: 20pt, height: 13pt))[
    #box(width: 20pt, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[]
  ] / #capture_field(field_name: "voimassa_asti_kk", field_type: "text", dimensions: (width: 20pt, height: 13pt))[
    #box(width: 20pt, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[]
  ] / #capture_field(field_name: "voimassa_asti_vuosi", field_type: "text", dimensions: (width: 32pt, height: 13pt))[
    #box(width: 32pt, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[]
  ] #h(0.2em) asti
]

#v(0.15em)
#text(size: 9pt, fill: luma(50))[Sopimus tarkistetaan tarvittaessa toiminnan muuttuessa.]

// 7. PELISÄÄNTÖJEN HYVÄKSYMINEN
#osio[7. Pelisääntöjen hyväksyminen]

#text(size: 9.5pt)[
  Jäsen vakuuttaa lukeneensa ja ymmärtäneensä "Kaupallisen käytön pelisäännöt" ja sitoutuu noudattamaan sitä.
]

// 8. SOPIMUKSEN PÄÄTTÄMINEN
#osio[8. Sopimuksen päättäminen]

#text(size: 9.5pt)[
  Tämä sopimus on voimassa kohdan 6 mukaisesti. Sekä jäsenellä että Tampere Hacklab ry:llä on oikeus päättää tämä sopimus milloin tahansa välittömästi ilmoittamalla siitä kirjallisesti toiselle osapuolelle sopimukseen merkittyjä yhteystietoja käyttäen.
]

// 9. ALLEKIRJOITUKSET
#osio[9. Allekirjoitukset]

#v(0.25em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 2cm,
  [
    *Tampere Hacklab ry:n puolesta*
    #v(2.5em)
    #line(length: 100%, stroke: 0.5pt)
    #if allekirjoitus_hacklab_nimi != "" [
      #v(0.2em)
      #text(size: 9.5pt)[#allekirjoitus_hacklab_nimi]
    ]
  ],
  [
    *Jäsen*
    #v(2.5em)
    #line(length: 100%, stroke: 0.5pt)
    #if allekirjoitus_jasen_nimi != "" [
      #v(0.2em)
      #text(size: 9.5pt)[#allekirjoitus_jasen_nimi]
    ]
  ]
)

#v(0.8em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 2cm,
  [
    *Huoltaja (alaikäinen jäsen)*
    #v(2.5em)
    #line(length: 100%, stroke: 0.5pt)
    #if allekirjoitus_huoltaja_nimi != "" [
      #v(0.2em)
      #text(size: 9.5pt)[#allekirjoitus_huoltaja_nimi]
    ]
  ],
  []
)
