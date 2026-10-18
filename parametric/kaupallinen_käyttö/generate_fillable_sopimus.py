import sys
from typst_fillable import make_fillable
from typst_fillable.models import FieldStyle

template = "kaupallisen_kayton_sopimus_fillable_en.typ"
output_pdf = "kaupallisen_kayton_sopimus_fillable_en.pdf"

# Blank white background with no border for clean printing
style = FieldStyle(fill_color="#ffffff", border_width=0)

pdf_bytes = make_fillable(
    template=template,
    style=style,
    context={},
)

with open(output_pdf, "wb") as f:
    f.write(pdf_bytes)

print(f"Generated {output_pdf} successfully with blank white form fields.")

