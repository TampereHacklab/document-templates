#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

// Evaluate the configurable background from the YAML front matter
#let margin_style = lower("$if(tausta)$$tausta$$else$solid$endif$")

// Define the background fill: solid yellow, diagonal stripes, or transparent
#let bg-fill = if margin_style == "stripes" {
  tiling(size: (40pt, 40pt))[
    #place(line(start: (-50%, -50%), end: (150%, 150%), stroke: 15pt + rgb("#FFED1F")))
    #place(line(start: (-50%, -150%), end: (150%, 50%), stroke: 15pt + rgb("#FFED1F")))
    #place(line(start: (-50%, 50%), end: (150%, 250%), stroke: 15pt + rgb("#FFED1F")))
  ]
} else if margin_style == "none" {
  none
} else {
  rgb("#FFED1F")
}

#set document(title: [$if(otsikko)$$otsikko$$else$ILMOITUS$endif$])

#set page(
  paper: "a4",
  // The actual text area is padded 1cm inside the white box.
  // Visual white box starts at: L/R: 1cm, Top: 6cm, Bottom: 2cm
  // Text area starts at: L/R: 2cm, Top: 7cm, Bottom: 3cm
  margin: (top: 7cm, bottom: 3cm, left: 2cm, right: 2cm),
  background: [
    
    // 1. Draw the configured margin pattern over the entire A4 page
    #rect(width: 100%, height: 100%, fill: bg-fill, stroke: none)

    // 2. Draw the White Main Content Area over the background
    #place(top + left, dx: 1cm, dy: 6cm)[
      #rect(
        width: 100% - 2cm, 
        height: 100% - 8cm, 
        fill: white, 
        stroke: if margin_style == "none" { 0.5pt + black } else { none }
      )
    ]

    // 3. The Large Title
    #set par(justify: false)
    #place(top + left, dx: 2cm, dy: 1cm)[
      #box(width: 100% - 7.5cm, height: 4.5cm, align(left + horizon)[
        #layout(size => context {
          let title-content = text(size: 36pt, weight: "bold", hyphenate: false, fill: black)[$if(otsikko)$$otsikko$$else$ILMOITUS$endif$]
          
          // Wrap the text in a block matching the available width to allow natural line breaks
          let wrapped = block(width: size.width, title-content)
          let measured-height = measure(wrapped).height
          
          // If the wrapped text is taller than our 4.5cm box, scale it down
          if measured-height > size.height {
            let ratio = size.height / measured-height
            // Inverse-scale the block width so it still utilizes the full horizontal space when scaled down
            scale(ratio * 100%, origin: left + horizon)[
              #block(width: size.width / ratio, title-content)
            ]
          } else {
            wrapped
          }
        })
      ])
    ]
    #set par(justify: true)

    // Logo
    #place(top + right, dx: -1cm, dy: 1cm)[
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
        
        #set text(size: 5pt, font: "Dejavu Sans Mono", tracking: 0.2pt, fill: black)
        
        #place(top + center, dy: 6pt)[Tampere Hacklab, Ahlmanintie 56,]
        #place(right + horizon, dx: 38pt)[#rotate(90deg)[33800 Tampere FINLAND, phone ]]
        #place(bottom + center, dy: -6pt)[#rotate(180deg)[+358 93157 6905, info\@tampere]]
        #place(left + horizon, dx: -38pt - 5pt)[#rotate(270deg)[.hacklab.fi, tampere.hacklab.fi]]
      ]
    ]

    // 5. Association Info Footer (Bottom Margin)
    #place(bottom + center, dy: -0.8cm)[
      #text(size: 11pt, weight: "bold", fill: black)[
        Tampere Hacklab ry ~|~ Ahlmanintie 56, 33800 Tampere ~|~ +358 93157 6905 ~|~ info\@tampere.hacklab.fi
      ]
    ]
  ]
)

// Set global text properties. Uses the configurable font size.
#set text(lang: "$if(lang)$$lang$$else$fi$endif$", size: $if(fontsize)$$fontsize$$else$14pt$endif$)
#set par(justify: true)

// Wrap the entire content area in a fixed, unbreakable block to force single-page spill-off
#block(height: 100%, width: 100%, breakable: false, clip: false)[

  // Date placed in the top right, exactly on the same vertical line as the body content.
  // Font size is locked to 14pt so it remains unaffected by the 'fontsize' variable.
  #place(top + right, dy: -0.6cm, dx: 0.6cm)[
    #text(size: 14pt, weight: "bold")[$päivä$]
  ]

  // --- MAIN CONTENT ---
  $body$

  // --- END MATTER (Optional Signature) ---
  $if(allekirjoittaja)$
  #v(1fr) // Pushes the signature block exactly to the bottom of the white area
  #block(breakable: false)[
    #let signoff = (
      [$allekirjoittaja$],
      $if(rooli)$[$rooli$],$endif$
      $if(yhteystieto)$[$yhteystieto$],$endif$
    )
    #signoff.join([\ ])
  ]
  $endif$
]
