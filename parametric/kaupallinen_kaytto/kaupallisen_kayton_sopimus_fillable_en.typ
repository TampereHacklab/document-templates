// Tampere Hacklab ry — Commercial Use Agreement (Kaupallisen käytön sopimus)
//
// Instructions:
// 1. You can enter agreement details directly into the variables below
//    or pass them from command line, e.g.:
//    typst compile --input member_name="John Doe" kaupallisen_kayton_sopimus_fillable_en.typ
// 2. Compile to regular PDF:
//    typst compile kaupallisen_kayton_sopimus_fillable_en.typ
// 3. Generate interactive fillable PDF with typst-fillable:
//    python3 generate_fillable_sopimus.py --language en
// 4. Blank form: Leaving variables empty ("") generates a clean printable form
//    for manual handwriting and signing.

#import "form_fields.typ": capture_field, table_field, date_fields, printed, fillable

// ==========================================
// 1. AGREEMENT DETAILS AND VARIABLES
// ==========================================

// Basic information
#let agreement_number = sys.inputs.at("agreement_number", default: sys.inputs.at("sopimusnumero", default: ""))
#let date_str = sys.inputs.at("date", default: sys.inputs.at("paivays", default: ""))

// 1. Contracting Parties
#let board_representative_name = sys.inputs.at("board_representative_name", default: sys.inputs.at("hallituksen_edustajan_nimi", default: ""))

#let member_name = sys.inputs.at("member_name", default: sys.inputs.at("jasen_nimi", default: ""))
#let membership_number = sys.inputs.at("membership_number", default: sys.inputs.at("jasennumero", default: ""))
#let member_company = sys.inputs.at("member_company", default: sys.inputs.at("jasen_yritys", default: ""))
#let member_business_id = sys.inputs.at("member_business_id", default: sys.inputs.at("jasen_y_tunnus", default: ""))

#let guardian_name = sys.inputs.at("guardian_name", default: sys.inputs.at("huoltaja_nimi", default: ""))
#let guardian_contact = sys.inputs.at("guardian_contact", default: sys.inputs.at("huoltaja_yhteystiedot", default: ""))

// 2. & 3. Description of activity & facilities
#let activity_description = sys.inputs.at("activity_description", default: sys.inputs.at("toiminnan_kuvaus", default: ""))
#let facilities_and_equipment = sys.inputs.at("facilities_and_equipment", default: sys.inputs.at("kaytettavat_tilat_ja_laitteet", default: ""))

// 4. Agreed compensation to the community
#let comp_financial = sys.inputs.at("comp_financial", default: false) == true or sys.inputs.at("comp_financial", default: "false") == "true" or sys.inputs.at("korvaus_rahallinen", default: "false") == "true"
#let comp_volunteer = sys.inputs.at("comp_volunteer", default: false) == true or sys.inputs.at("comp_volunteer", default: "false") == "true" or sys.inputs.at("korvaus_talkootyo", default: "false") == "true"
#let comp_materials = sys.inputs.at("comp_materials", default: false) == true or sys.inputs.at("comp_materials", default: "false") == "true" or sys.inputs.at("korvaus_materiaalikorvaus", default: "false") == "true"
#let comp_workshops = sys.inputs.at("comp_workshops", default: false) == true or sys.inputs.at("comp_workshops", default: "false") == "true" or sys.inputs.at("korvaus_tyopajojen_jarjestaminen", default: "false") == "true"
#let comp_maintenance = sys.inputs.at("comp_maintenance", default: false) == true or sys.inputs.at("comp_maintenance", default: "false") == "true" or sys.inputs.at("korvaus_laitteiden_huolto", default: "false") == "true"
#let comp_other = sys.inputs.at("comp_other", default: false) == true or sys.inputs.at("comp_other", default: "false") == "true" or sys.inputs.at("korvaus_muu", default: "false") == "true"
#let compensation_description = sys.inputs.at("compensation_description", default: sys.inputs.at("korvauksen_kuvaus", default: ""))

// 5. Special terms and conditions
#let special_conditions = sys.inputs.at("special_conditions", default: sys.inputs.at("erityisehdot", default: ""))

// 6. Validity of the agreement
#let validity_indefinite = sys.inputs.at("validity_indefinite", default: false) == true or sys.inputs.at("validity_indefinite", default: "false") == "true" or sys.inputs.at("voimassaolo_toistaiseksi", default: "false") == "true"
#let validity_fixed_term = sys.inputs.at("validity_fixed_term", default: false) == true or sys.inputs.at("validity_fixed_term", default: "false") == "true" or sys.inputs.at("voimassaolo_maaraaikainen", default: "false") == "true"
#let valid_until = sys.inputs.at("valid_until", default: sys.inputs.at("voimassa_asti", default: ""))

// 9. Signatures
#let signature_hacklab_name = sys.inputs.at("signature_hacklab_name", default: sys.inputs.at("allekirjoitus_hacklab_nimi", default: ""))
#let signature_member_name = sys.inputs.at("signature_member_name", default: sys.inputs.at("allekirjoitus_jasen_nimi", default: ""))
#let signature_guardian_name = sys.inputs.at("signature_guardian_name", default: sys.inputs.at("allekirjoitus_huoltaja_nimi", default: ""))


// ==========================================
// DOCUMENT SETTINGS & STYLES
// ==========================================

#set document(
  title: [Commercial Use Agreement #if agreement_number != "" [#agreement_number]],
  author: "Tampere Hacklab ry"
)

#set text(lang: "en", size: 10.5pt)
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
        align(center)[Commercial Use Agreement],
        []
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.4pt)
    ]
  ],
  footer: context [
    #align(center)[Page #counter(page).display("1/1", both: true)]
  ]
)

// Tampere Hacklab ry logo (drawn in pure Typst vector graphics)
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

// Helper: Checkbox integrated with capture_field
#let checkbox_field(checked: false, field_name: "", label_text) = {
  box(baseline: 15%)[
    #capture_field(
      field_name: field_name,
      field_type: "checkbox",
      dimensions: (width: 9.5pt, height: 9.5pt),
      value: checked,
    )[
      #box(
        width: 9.5pt,
        height: 9.5pt,
        stroke: 0.6pt + black,
        radius: 1.5pt,
        align(center + horizon)[
          #if checked and not fillable [
            #text(size: 8pt, weight: "bold")[#sym.times]
          ]
        ]
      )
    ]
    #h(6pt)
    #label_text
  ]
}

// Helper: Section title with horizontal rule
#let section_heading(number_and_title) = {
  v(0.35em)
  block(width: 100%, breakable: false)[
    #text(size: 10.5pt, weight: "bold")[#number_and_title]
    #v(0.15em)
    #line(length: 100%, stroke: 0.4pt + luma(120))
  ]
  v(0.12em)
}

// Helper: Textarea / box for descriptions
#let description_box(value, field_name: "", height: 36pt) = {
  capture_field(field_name: field_name, field_type: "textarea", dimensions: (width: 100%, height: height), value: value)[
    #rect(
      width: 100%,
      height: height,
      stroke: 0.4pt + luma(180),
      radius: 2pt,
      fill: luma(252),
      inset: (x: 8pt, y: 5pt),
    )[
      #if value != "" and value != none [
        #set par(justify: false)
        #printed(value)
      ]
    ]
  ]
}


// ==========================================
// PAGE 1
// ==========================================

// --- FIRST PAGE HEADER SECTION ---
#grid(
  columns: (1fr, auto),
  align: (left, horizon),
  [
    #set text(size: 11pt)
    *Tampere Hacklab ry* \
    Ahlmanintie 56, 33800 Tampere \
    Business ID: 2419748-5 \
    hallitus\@tampere.hacklab.fi
  ],
  [
    #hacklab_logo(mittakaava: 75%)
  ]
)

// --- MAIN HEADING & AGREEMENT METADATA ---
// Compact header spacing fits the company row without shrinking description boxes.
#v(0.1cm)
#align(center)[
  #text(size: 16pt, weight: "bold", hyphenate: false)[Commercial Use Agreement] \
  #v(0.4em)
  #text(size: 10pt)[
    *No.:* #capture_field(field_name: "agreement_number", dimensions: (width: 50pt, height: 13pt), value: agreement_number)[#box(width: 50pt, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[#printed(agreement_number)]]
    #h(2.5em) *Date:* #date_fields(("date_day", "date_month", "date_year"), date_str)
  ]
]
#v(0.3cm)
#line(length: 100%, stroke: 0.4pt)
#v(0.1cm)

// 1. CONTRACTING PARTIES
#section_heading[1. Contracting Parties]

#v(0.1em)
#table(
  columns: (auto, 1fr),
  stroke: 0.4pt + luma(180),
  inset: (x: 8pt, y: 4.5pt),
  fill: (col, row) => if col == 0 { luma(248) } else { none },
  align: (col, row) => (left + horizon),
  
  table.cell(colspan: 2, fill: luma(238))[*Tampere Hacklab ry*],
  [Board representative's name], table_field("board_representative_name", board_representative_name),
  
  table.cell(colspan: 2, fill: luma(238))[*Member*],
  [Name], table_field("member_name", member_name),
  [Membership number], table_field("membership_number", membership_number),
  [Company (if business activity)], table_field("member_company", member_company),
  [Business ID (if business activity)], table_field("member_business_id", member_business_id),
  
  table.cell(colspan: 2, fill: luma(238))[*Guardian (filled if member is a minor)*],
  [Name], table_field("guardian_name", guardian_name),
  [Contact information (phone / email)], table_field("guardian_contact", guardian_contact),
)

#v(0.3em)

// 2. DESCRIPTION OF ACTIVITY
#section_heading[2. Description of Activity]
#text(style: "italic", fill: luma(70), size: 9pt)[
  Describe what the commercial activity entails and estimate its scope (e.g., quantity and value of products or services per month).
]
#v(0.2em)
#description_box(activity_description, field_name: "activity_description", height: 95pt)

#v(0.3em)

// 3. FACILITIES AND EQUIPMENT USED
#section_heading[3. Facilities and Equipment Used]
#text(style: "italic", fill: luma(70), size: 9pt)[
  Describe which Hacklab facilities and equipment will be utilized in the commercial activity.
]
#v(0.2em)
#description_box(facilities_and_equipment, field_name: "facilities_and_equipment", height: 95pt)


// ==========================================
// PAGE 2
// ==========================================
#pagebreak()

// 4. AGREED COMPENSATION TO THE COMMUNITY
#section_heading[4. Agreed Compensation to the Community]

*Form of compensation:*
#v(0.15em)

#grid(
  columns: (1fr, 1.35fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 0.45em,
  [
    #checkbox_field(checked: comp_financial, field_name: "comp_financial")[Financial compensation]
  ],
  [
    #checkbox_field(checked: comp_volunteer, field_name: "comp_volunteer")[Volunteer work]
  ],
  [
    #checkbox_field(checked: comp_materials, field_name: "comp_materials")[Material compensation]
  ],
  [
    #checkbox_field(checked: comp_workshops, field_name: "comp_workshops")[Organizing workshops]
  ],
  [
    #checkbox_field(checked: comp_maintenance, field_name: "comp_maintenance")[Equipment maintenance or servicing]
  ],
  [
    #checkbox_field(checked: comp_other, field_name: "comp_other")[Other]
  ]
)

#v(0.25em)
*Description:*
#v(0.12em)
#description_box(compensation_description, field_name: "compensation_description", height: 72pt)

// 5. SPECIAL TERMS AND CONDITIONS
#section_heading[5. Special Terms and Conditions]
#text(style: "italic", fill: luma(70), size: 9pt)[
  For example, working only during specified hours, maximum usage limits, storage practices.
]
#v(0.12em)
#description_box(special_conditions, field_name: "special_conditions", height: 72pt)

// 6. VALIDITY OF THE AGREEMENT
#section_heading[6. Validity of the Agreement]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  align: bottom,
  [#checkbox_field(checked: validity_indefinite, field_name: "validity_indefinite")[Valid until further notice]],
  [
    #checkbox_field(checked: validity_fixed_term, field_name: "validity_fixed_term")[
      Fixed term until #h(0.2em)
      #date_fields(("valid_until_day", "valid_until_month", "valid_until_year"), valid_until)
    ]
  ],
)

#v(0.15em)
#text(size: 9pt, fill: luma(50))[The agreement will be reviewed as necessary if activities change.]

// 7. ACCEPTANCE OF RULES
#section_heading[7. Acceptance of Rules]

#text(size: 9.5pt)[
  The member confirms that they have read and understood the "Rules for Commercial Use" and agrees to comply with them.
]

// 8. TERMINATION OF THE AGREEMENT
#section_heading[8. Termination of the Agreement]

#text(size: 9.5pt)[
  This agreement is valid as agreed in section 6. Both the member and Tampere Hacklab ry have the right to terminate this agreement at any time with immediate effect by providing written notice to the other party using the contact details specified in the agreement.
]

// 9. SIGNATURES
#section_heading[9. Signatures]

#v(0.25em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 2cm,
  [
    *For Tampere Hacklab ry*
    #v(2.5em)
    #line(length: 100%, stroke: 0.5pt)
    #if signature_hacklab_name != "" and not fillable [
      #v(0.2em)
      #text(size: 9.5pt)[#signature_hacklab_name]
    ]
  ],
  [
    *Member*
    #v(2.5em)
    #line(length: 100%, stroke: 0.5pt)
    #if signature_member_name != "" and not fillable [
      #v(0.2em)
      #text(size: 9.5pt)[#signature_member_name]
    ]
  ]
)

#v(0.8em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 2cm,
  [
    *Guardian (minor member)*
    #v(2.5em)
    #line(length: 100%, stroke: 0.5pt)
    #if signature_guardian_name != "" and not fillable [
      #v(0.2em)
      #text(size: 9.5pt)[#signature_guardian_name]
    ]
  ],
  []
)
