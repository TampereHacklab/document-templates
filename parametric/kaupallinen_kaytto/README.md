# Commercial use agreement / Kaupallisen käytön sopimus

Finnish and English two-page A4 agreement templates for Tampere Hacklab ry.

## Generate fillable PDFs

Requires Python 3.10+ and the packages below (install in a virtual environment).
Run these commands from the repository root:

```sh
python3 -m pip install -r parametric/kaupallinen_käyttö/requirements.txt
python3 parametric/kaupallinen_käyttö/generate_fillable_sopimus.py
```

This creates both PDFs alongside the templates:

- `kaupallisen_kayton_sopimus_fillable.pdf` (Finnish)
- `kaupallisen_kayton_sopimus_fillable_en.pdf` (English)

Use `--language fi` or `--language en` to generate just one version, and
`--output-dir PATH` to choose another destination. The script works from any
working directory.

Each PDF has 26 interactive fields: agreement number, dates, party/company details,
four multiline descriptions, and eight checkboxes.
The compensation choices use a three-column, two-row layout; the validity choices
share one row. Sections 4 and 5 each have a 72pt-high text area.
The fields are transparent overlays made with **typst-fillable**; they do not
move or resize the printed document. The generator checks the two-page limit.
Use a PDF reader with form support to fill, save and print the document.
Signature lines are non-interactive and reserved for handwritten signatures.
Fields stay fixed-size; keep entries within the visible area when printing.

### Prefill values

Repeat `--input KEY=VALUE` to supply the templates' existing Typst inputs.
Values remain editable, including preselected checkboxes:

```sh
python3 parametric/kaupallinen_käyttö/generate_fillable_sopimus.py --language fi \
  --input 'jasen_nimi=Matti Meikäläinen' \
  --input 'jasen_yritys=Esimerkki Oy' \
  --input 'paivays=2026-10-18' \
  --input 'korvaus_rahallinen=true' \
  --input 'voimassa_asti=31.12.2026'
```

The English template accepts English input names (e.g. `member_name`, `member_company`, `date`,
`comp_financial`, `valid_until`) as well as the Finnish aliases. Dates accept
`YYYY-MM-DD` or `DD.MM.YYYY` (also `DD/MM/YYYY`).

## Printable, non-interactive PDFs

Normal Typst compilation still works; it does **not** add interactive widgets:

```sh
typst compile parametric/kaupallinen_käyttö/kaupallisen_kayton_sopimus_fillable.typ
typst compile parametric/kaupallinen_käyttö/kaupallisen_kayton_sopimus_fillable_en.typ
```

## Implementation note

The generator uses typst-fillable's overlay API and imports
the complete form catalog with pypdf to avoid invalid references in
typst-fillable 0.0.1's high-level merge function.
