#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#set document(
  title: [$if(tyyppi)$$tyyppi$$else$Pöytäkirja$endif$ --- $if(otsikko)$$otsikko$$else$Kokous$endif$]
)

#set page(
  paper: "a4",
  margin: 2.5cm,
  header: [
      #smallcaps[
        #grid(
          columns: (1fr, auto, 1fr),
          align(left)[*Tampere Hacklab ry*],
          align(center)[$if(tyyppi)$$tyyppi$$else$Pöytäkirja$endif$],
          align(right)[$päivä$]
        )
        #v(-0.5em)
        #line(length: 100%, stroke: 0.4pt)
      ]
  ],
  footer: context [
    // Uses context to evaluate the total page count dynamically
    #align(center)[Sivu #counter(page).display("1/1", both: true)]
  ]
)

// Set global text properties (Finnish hyphenation, 11pt size)
#set text(lang: "$if(lang)$$lang$$else$fi$endif$", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.")

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
    #text(hyphenate: false)[#title([$if(otsikko)$$otsikko$$else$Kokous$endif$])]
]
#v(0.5cm)

// --- MEETING DETAILS ---
#grid(
  columns: (3cm, 1fr),
  row-gutter: 0.8em,
  [*Aika:*], [$päivä$ klo $aloitus$],
  [*Paikka:*], [$paikka$],
  [*Läsnä:*], [$for(paikalla)$$paikalla$$sep$, $endfor$],
  $if(poissa)$
  [*Poissa:*], [$for(poissa)$$poissa$$sep$, $endfor$]
  $endif$
)

#v(0.5cm)

$if(asialista)$
*Asialista:*
#set enum(numbering: "1.", indent: 1em)
$for(asialista)$
+ $asialista$
$endfor$
#v(0.5cm)
$endif$

#line(length: 100%, stroke: 0.4pt)
#v(0.5cm)

// --- MAIN CONTENT (Markdown text is injected here) ---
$body$

// --- END MATTER ---
$if(lopetus)$
#v(1cm)
#block(breakable: false)[
  *Kokouksen päättäminen:* \
  Kokous päätettiin klo $lopetus$.
]
$endif$

// --- SIGNATURES ---
$if(tarkastajat)$
#v(1cm)
#block(breakable: false)[
  *Pöytäkirjan vakuudeksi:*

  #v(0.5cm)
  #grid(
    columns: 2, // Creates a 2-column grid. Signatures will automatically wrap to the next row if there are more than 2.
    column-gutter: 2cm,
    row-gutter: 2cm,
    $for(tarkastajat)$
    [
      #v(1.5cm)
      #line(length: 100%, stroke: 0.5pt)
      #v(0.2cm)
      $tarkastajat$ \
      Pöytäkirjantarkastaja
    ]$sep$,
    $endfor$
  )
]
$endif$
