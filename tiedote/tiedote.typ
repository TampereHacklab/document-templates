#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#set document(
  title: [$if(tyyppi)$$tyyppi$$else$Tiedote$endif$ --- $if(otsikko)$$otsikko$$else$Tiedote$endif$]
)

#set page(
  paper: "a4",
  margin: 2.5cm,
  header: [
      #smallcaps[
        #grid(
          columns: (1fr, auto, 1fr),
          align(left)[*Tampere Hacklab ry*],
          align(center)[$if(tyyppi)$$tyyppi$$else$Tiedote$endif$],
          align(right)[$päivä$]
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

// Set global text properties (Finnish hyphenation, 11pt size)
#set text(lang: "$if(lang)$$lang$$else$fi$endif$", size: 11pt)
#set par(justify: true)

// --- FIRST PAGE HEADER SECTION ---
#grid(
  columns: (1fr, auto),
  align: (left, horizon),
  [
    *Tampere Hacklab ry* \
    Ahlmanintie 56, 33800 Tampere \
    Y-tunnus: 2419748-5 \
    info\@tampere.hacklab.fi
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

#v(0.5cm)
#align(center)[
    #text(hyphenate: false)[#title([$if(otsikko)$$otsikko$$else$Tiedote$endif$])]
]
#v(0.5cm)

// --- BULLETIN METADATA ---
#grid(
  columns: (3cm, 1fr),
  row-gutter: 0.8em,
  $if(päivä)$[*Päiväys:*], [$päivä$],$endif$
  $if(laatija)$[*Laatija:*], [$laatija$],$endif$
  $if(jakelu)$[*Jakelu:*], [$jakelu$],$endif$
  $if(lisätietoja)$[*Lisätietoja:*], [$lisätietoja$]$endif$
)

#v(0.5cm)
#line(length: 100%, stroke: 0.4pt)
#v(0.5cm)

// --- MAIN CONTENT (Markdown text is injected here) ---
$body$

// --- END MATTER (Optional sign-off) ---
$if(allekirjoittaja)$
#v(1.5cm)
#block(breakable: false)[
  #let signoff = (
    [$allekirjoittaja$],
    $if(rooli)$[$rooli$],$endif$
    $if(yhteystieto)$[$yhteystieto$],$endif$
  )
  #signoff.join([\ ])
]
$endif$
