// Shared, layout-neutral metadata for typst-fillable. Normal Typst compilation
// still produces a printable form; the Python generator supplies fillable=true.
#let fillable = sys.inputs.at("fillable", default: "false") == "true"
#let printed(value) = if not fillable and value != "" { value }

#let capture_field(
  field_name: "",
  field_type: "text",
  dimensions: none,
  value: "",
  offset: (x: 0pt, y: 0pt),
  content,
) = box(width: if dimensions != none and type(dimensions.width) == ratio { dimensions.width } else { auto }, {
  place(top + left, layout(size => context {
    let measured = measure(content, width: size.width)
    let width = if dimensions != none and type(dimensions.width) == length {
      dimensions.width
    } else { size.width }
    let height = if dimensions == none { measured.height } else { dimensions.height }
    let pos = here().position()
    metadata((
      fieldName: field_name,
      fieldType: field_type,
      dimensions: (width: width / 1pt, height: height / 1pt),
      pos: (page: pos.page, x: (pos.x + offset.x) / 1pt, y: (pos.y + offset.y) / 1pt),
      // Applied as editable defaults by the generator, not static page content.
      defaultValue: value,
    ))
  }))
  content
})

// The label determines the table row's height. The widget is centred in the
// empty value cell and uses its actual available width, not a guessed width.
#let table_field(name, value) = capture_field(
  field_name: name,
  dimensions: (width: 100%, height: 11pt),
  offset: (x: 0pt, y: -5.5pt),
  value: value,
)[#printed(value)]

#let date_fields(names, value) = {
  let parts = if value == "" { ("", "", "") } else {
    let parts = value.split(regex("[-./]"))
    assert(parts.len() == 3, message: "Use YYYY-MM-DD or DD.MM.YYYY for dates")
    if parts.first().len() == 4 { parts.rev() } else { parts }
  }
  for (i, name) in names.enumerate() {
    if i > 0 { [ \/ ] }
    let width = if i == 2 { 32pt } else { 20pt }
    capture_field(
      field_name: name,
      dimensions: (width: width, height: 13pt),
      value: parts.at(i),
    )[
      #box(width: width, height: 13pt, stroke: (bottom: 0.5pt + black), inset: (bottom: 2pt))[
        #printed(parts.at(i))
      ]
    ]
  }
}
