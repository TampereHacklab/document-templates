# document-templates

Document templates for various Hacklab documents, primarily in Typst and LaTeX.
Some are for Pandoc (under `pandoc/`), others parametric, others static.

## Usage

To convert using LaTeX:

`pandoc poytakirja_example.md --template=poytakirja.tex -o poytakirja.pdf`

To convert using Typst:

`pandoc poytakirja_example.md --pdf-engine=typst --template=poytakirja.typ -o poytakirja.pdf`

## Available templates

### Pandoc

These allow converting Markdown into nice documents via Pandoc.
They have a bunch of metadata that is configured in a YAML front matter block,
and the main document is written in plain Markdown.

- **poytakirja**: template for official meeting memos (see `poytakirja_example.md` for syntax)
- **huomio**: template for short eye-catching notices for the bulletin board
- **tiedote**: template for official-looking bulletins
