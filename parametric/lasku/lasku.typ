// Tampere Hacklab ry — Lasku. Based on ../muistiotosite/muistiotosite.typ.
// typst compile tools/lasku/lasku.typ lasku.pdf
// typst compile --root . --input invoice=../../data/laskut/2026-001.json tools/lasku/lasku.typ lasku.pdf
#import "pankkiviivakoodi.typ": pad-zero, validate-iban, complete-reference, bank-payload, bank-barcode

#let invoice = json(sys.inputs.at("invoice", default: "esimerkki.json"))
#let sender = invoice.sender
#let recipient = invoice.recipient
#let optional(key) = invoice.at(key, default: "")
#let parse-date(value) = {
  assert(value.match(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")) != none,
    message: "Date must use the YYYY-MM-DD format")
  let parts = value.split("-").map(int)
  datetime(year: parts.at(0), month: parts.at(1), day: parts.at(2))
}
#let date = parse-date(invoice.date)
#let due-date = parse-date(invoice.due_date)
#let iban = validate-iban(sender.iban)
#let reference = complete-reference(invoice.reference)
#let money(cents) = {
  let amount = calc.abs(cents)
  (if cents < 0 { "−" } else { "" }) + str(calc.quo(amount, 100)) + "," + pad-zero(calc.rem(amount, 100), 2) + " €"
}
#let number(value) = str(value).replace(".", ",")
#let lines(values) = values.map(value => [#value]).join(linebreak())
#let field(label, value) = [#text(size: 8pt, fill: luma(90))[#label] \ #value]

#assert(invoice.items.len() > 0, message: "Invoice must contain at least one line item")
#assert(due-date >= date, message: "Due date cannot precede the invoice date")
#let items = invoice.items.map(item => {
  assert(type(item.unit_price_cents) == int and item.unit_price_cents >= 0,
    message: "Unit price must be a non-negative integer in cents")
  assert(item.quantity > 0, message: "Quantity must be positive")
  assert(item.vat_percent >= 0 and item.vat_percent <= 100, message: "VAT percentage must be between 0 and 100")
  let net = int(calc.round(item.quantity * item.unit_price_cents))
  let vat = int(calc.round(net * item.vat_percent / 100))
  (..item, net: net, vat: vat, gross: net + vat)
})
#let net-total = items.map(item => item.net).sum()
#let vat-total = items.map(item => item.vat).sum()
#let total = net-total + vat-total
#let payload = if invoice.at("barcode", default: true) { bank-payload(iban, reference, total, due-date) }

#set document(title: [Lasku #invoice.number — #sender.name], author: sender.name)
#set text(lang: "fi", size: 10pt)
#set par(justify: false, leading: 0.45em, spacing: 0.6em)
#set page(
  paper: "a4",
  margin: (top: 16mm, bottom: 18mm, x: 18mm),
  header: context {
    if counter(page).get().first() > 1 [
      #smallcaps[#sender.name #h(1fr) Lasku #invoice.number]
      #line(length: 100%, stroke: 0.4pt)
    ]
  },
  footer: context align(center, text(size: 8pt)[
    #sender.name · Y-tunnus: #sender.business_id · #sender.email
    #if sender.at("phone", default: "") != "" [ · #sender.phone]
    \
    Lasku #invoice.number · Sivu #counter(page).display("1/1", both: true)
  ]),
)

// The original voucher's vector logo, including its ring of lettering.
#let logo = scale(x: 65%, y: 65%, origin: right + top, reflow: true)[
  #box(width: 124pt, height: 124pt, stroke: 1.5pt + black)[
    #align(center + horizon)[
      #box(width: 38pt, height: 62pt)[
        #polygon(
          fill: black,
          (10pt, 0pt), (10pt, 16pt), (0pt, 16pt), (0pt, 20pt), (24pt, 20pt),
          (24pt, 16pt), (14pt, 16pt), (14pt, 4pt), (34pt, 4pt), (34pt, 58pt),
          (14pt, 58pt), (14pt, 26pt), (21pt, 26pt), (21pt, 22pt), (3pt, 22pt),
          (3pt, 26pt), (10pt, 26pt), (10pt, 62pt), (38pt, 62pt), (38pt, 0pt),
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

// First-page address zone, in absolute A4 coordinates:
// recipient x=23..103 mm, y=48..72 mm; no other content in
// x=0..118 mm, y=0..110 mm. Fold at y=148.5 mm, lower half behind.
// Fixed-height blocks are measured so long input cannot silently leak into
// the envelope window or overlap the invoice body.
#let fitted(width, height, body) = context {
  assert(measure(block(width: width, body)).height <= height,
    message: "Header or address details do not fit in the reserved space; shorten the text")
  block(width: width, height: height, body)
}

#block(width: 100%, height: 94mm, breakable: false)[
  #place(top + left, dx: 107mm)[
    #fitted(35mm, 28mm)[
      #set text(size: 9pt)
      *#sender.name* \
      #lines(sender.address) \
      #text(size: 8pt)[Y-tunnus: #sender.business_id] \
      #text(size: 8pt)[#sender.email]
      #if sender.at("phone", default: "") != "" [\ #text(size: 8pt)[#sender.phone]]
    ]
  ]
  #place(top + right)[#logo]
  #place(top + left, dx: 5mm, dy: 32mm)[
    #fitted(80mm, 24mm)[
      #set text(size: 10pt, hyphenate: false)
      *#recipient.name* \
      #lines(recipient.address)
    ]
  ]
  #place(top + left, dx: 107mm, dy: 40mm)[
    #fitted(67mm, 50mm)[
      #text(size: 20pt, weight: "bold")[LASKU]
      #v(3mm)
      #grid(
        columns: (auto, 1fr), column-gutter: 4mm, row-gutter: 2mm,
        [Laskun numero], [*#invoice.number*],
        [Päiväys], [#date.display("[day].[month].[year]")],
        [Eräpäivä], [*#due-date.display("[day].[month].[year]")*],
        [Maksuehto], [#invoice.payment_terms],
      )
    ]
  ]
]

#text(size: 14pt, weight: "bold")[#invoice.subject]
#if optional("message") != "" [#v(2mm) #invoice.message]
#v(3mm)
#grid(
  columns: (1fr, 1fr), column-gutter: 6mm, row-gutter: 3mm,
  ..(
    if optional("service_period") != "" { field("Toimitus / laskutusjakso", invoice.service_period) },
    if optional("customer_reference") != "" { field("Asiakkaan viite", invoice.customer_reference) },
    if recipient.at("business_id", default: "") != "" { field("Asiakkaan Y-tunnus", recipient.business_id) },
    if optional("late_interest") != "" { field("Viivästyskorko", invoice.late_interest) },
  ).filter(value => value != none),
)
#v(4mm)

#table(
  columns: (1fr, auto, auto, auto, auto),
  inset: (x: 5pt, y: 7pt),
  align: (left, right, right, right, right),
  stroke: (x, y) => (bottom: 0.4pt + luma(210)),
  fill: (x, y) => if y == 0 { luma(245) },
  table.header(
    [*Kuvaus*], [*Määrä*], [*À (alv 0 %)*], [*ALV %*], [*Yht. (sis. alv)*],
  ),
  ..items.map(item => (
    [#item.description],
    [#number(item.quantity) #item.unit],
    [#money(item.unit_price_cents)],
    [#number(item.vat_percent) %],
    [#money(item.gross)],
  )).flatten(),
)

#block(width: 100%, breakable: false)[
  #v(3mm)
  #align(right)[
    #grid(
      columns: (auto, auto), column-gutter: 12mm, row-gutter: 2mm,
      align: (left, right),
      [Veroton yhteensä], [#money(net-total)],
      ..items.map(item => item.vat_percent).sorted().dedup().map(rate => (
        [ALV #number(rate) % (peruste #money(items.filter(item => item.vat_percent == rate).map(item => item.net).sum()))],
        [#money(items.filter(item => item.vat_percent == rate).map(item => item.vat).sum())],
      )).flatten(),
      [*Maksettava yhteensä*], [*#money(total)*],
    )
  ]
  #if optional("tax_note") != "" [#v(3mm) #text(size: 9pt)[#invoice.tax_note]]
]

#if optional("notes") != "" [#v(4mm) #invoice.notes]
#v(1fr)

// Keep payment details and the barcode together, also on multi-page invoices.
#block(width: 100%, breakable: false)[
  #v(5mm)
  #line(length: 100%, stroke: 0.6pt)
  #v(3mm)
  #grid(
    columns: (1fr, 1fr), column-gutter: 8mm, row-gutter: 3mm,
    field("Maksun saaja", sender.name),
    field("Viitenumero", reference),
    field("IBAN", sender.iban),
    field("Eräpäivä", due-date.display("[day].[month].[year]")),
    field("BIC / pankki", [#sender.bic / #sender.bank]),
    field("Maksettava (EUR)", strong(money(total))),
  )
  #if payload != none [
    #v(8mm)
    #align(center)[#bank-barcode(payload)]
  ]
]
