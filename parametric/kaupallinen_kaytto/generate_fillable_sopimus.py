"""Generate two-page Finnish and English agreements using typst-fillable."""

import argparse
from io import BytesIO
import json
from pathlib import Path

from pypdf import PdfReader, PdfWriter
from pypdf.generic import DictionaryObject, NameObject, NumberObject, TextStringObject
from reportlab.lib.utils import simpleSplit
import typst
from typst_fillable import FieldMetadata, FieldStyle, create_form_overlay


SOURCE = Path(__file__).resolve().parent
TEMPLATES = {
    "fi": SOURCE / "kaupallisen_kayton_sopimus_fillable.typ",
    "en": SOURCE / "kaupallisen_kayton_sopimus_fillable_en.typ",
}


def generate_pdf(language="fi", inputs=None):
    """Return a fillable PDF, keeping both compilation and query inputs identical."""
    template = str(TEMPLATES[language])
    inputs = dict(inputs or {}, fillable="true")
    base = PdfReader(BytesIO(typst.compile(template, sys_inputs=inputs)))
    if len(base.pages) != 2:
        raise ValueError("The agreement must fit on exactly two pages")

    # Query directly to pass sys.inputs (the library's extractor cannot do so).
    metadata = json.loads(typst.query(template, "metadata", sys_inputs=inputs))
    values = [item["value"] for item in metadata
              if isinstance(item.get("value"), dict) and "fieldName" in item["value"]]
    fields = [FieldMetadata(**value) for value in values]
    if len(fields) != 26 or len({field.fieldName for field in fields}) != 26:
        raise ValueError("Expected 26 uniquely named form fields")

    overlay = create_form_overlay(
        fields=fields,
        page_count=len(base.pages),
        page_size=(float(base.pages[0].mediabox.width), float(base.pages[0].mediabox.height)),
        style=FieldStyle(fill_color="#ffffff", border_width=0, font_size=8),
    )

    # Import the form document first so pypdf clones its AcroForm and all indirect
    # references together. typst-fillable 0.0.1's make_fillable/merge_with_overlay
    # copies the catalog without cloning, leaving invalid field/font references.
    writer = PdfWriter()
    writer.append(PdfReader(overlay))
    for page, background in zip(writer.pages, base.pages):
        page.merge_page(background, over=False)
    if base.metadata:
        writer.add_metadata(base.metadata)

    defaults = {}
    for field in values:
        value = field["defaultValue"]
        if field["fieldType"] == "checkbox":
            value = "/Yes" if value else "/Off"
        defaults[field["fieldName"]] = value
    appearances = defaults.copy()
    cleaned_appearances = set()
    widgets = []
    for page in writer.pages:
        for ref in page.get("/Annots", []):
            widget = ref.get_object()
            if widget.get("/Subtype") != "/Widget":
                continue
            widgets.append(widget)
            value = defaults[widget["/T"]]
            widget[NameObject("/DV")] = (
                NameObject(value) if widget["/FT"] == "/Btn" else TextStringObject(value)
            )
            # Keep the template's lines, rounded boxes and shading visible.
            widget["/MK"].pop("/BG", None)
            widget[NameObject("/BS")] = DictionaryObject({NameObject("/W"): NumberObject(0)})
            # ReportLab defaults to 100 characters even for large textareas.
            if widget["/FT"] == "/Tx":
                widget.pop("/MaxLen", None)
                if widget.get("/Ff", 0) & 4096:
                    # pypdf honours explicit newlines but does not word-wrap
                    # multiline appearances. Wrap the display, not the value.
                    width = float(widget["/Rect"][2] - widget["/Rect"][0]) - 6
                    appearances[widget["/T"]] = "\n".join(
                        "\n".join(simpleSplit(line, "Helvetica", 8, width))
                        for line in value.split("\n")
                    )
            else:
                widget[NameObject("/Ff")] = NumberObject(0)  # Checkboxes are optional.
                # ReportLab paints a background/border graphics group even at
                # border_width=0. Retain only the checkmark in every appearance.
                for states in widget["/AP"].values():
                    for appearance in states.values():
                        if appearance in cleaned_appearances:
                            continue
                        cleaned_appearances.add(appearance)
                        stream = appearance.get_object()
                        _, separator, mark = stream.get_data().partition(b"\nQ")
                        if not separator:
                            raise ValueError("Unexpected checkbox appearance from ReportLab")
                        stream.set_data(mark)

    writer.update_page_form_field_values(None, appearances, auto_regenerate=False)
    for widget in widgets:
        if widget["/FT"] == "/Tx":
            widget[NameObject("/V")] = TextStringObject(defaults[widget["/T"]])

    output = BytesIO()
    writer.write(output)
    return output.getvalue()


def input_pair(value):
    key, separator, text = value.partition("=")
    if not separator or not key:
        raise argparse.ArgumentTypeError("Inputs must be KEY=VALUE")
    return key, text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--language", choices=("fi", "en", "both"), default="both")
    parser.add_argument("--output-dir", type=Path, default=SOURCE)
    parser.add_argument("--input", action="append", type=input_pair, default=[], metavar="KEY=VALUE",
                        help="Prefill a Typst input; may be repeated")
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    for language in (TEMPLATES if args.language == "both" else (args.language,)):
        output = args.output_dir / TEMPLATES[language].with_suffix(".pdf").name
        output.write_bytes(generate_pdf(language, dict(args.input)))
        print(f"Generated {output} (2 pages, 26 fillable fields)")


if __name__ == "__main__":
    main()
