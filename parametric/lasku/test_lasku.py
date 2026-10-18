"""Integration checks for the invoice and the published Finnish barcode vectors."""

import copy
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET


SOURCE = Path(__file__).resolve().parent


@unittest.skipUnless(shutil.which("typst") and shutil.which("pdftotext"),
                     "typst and pdftotext are required")
class InvoiceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="lasku-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for path in SOURCE.glob("*.typ"):
            shutil.copy2(path, self.root)
        self.invoice = json.loads((SOURCE / "esimerkki.json").read_text())

    def compile(self, invoice=None, success=True):
        (self.root / "input.json").write_text(
            json.dumps(invoice or self.invoice, ensure_ascii=False))
        result = subprocess.run(
            ["typst", "compile", "--input", "invoice=input.json", "lasku.typ", "out.pdf"],
            cwd=self.root, capture_output=True, text=True)
        if success:
            self.assertEqual(result.returncode, 0, result.stderr)
            return subprocess.check_output(
                ["pdftotext", "-layout", str(self.root / "out.pdf"), "-"], text=True)
        self.assertNotEqual(result.returncode, 0)
        return result.stderr

    def query(self, expression):
        (self.root / "probe.typ").write_text(
            '#import "pankkiviivakoodi.typ": *\n'
            f'#metadata({expression}) <test>\n')
        result = subprocess.run(
            ["typst", "query", "probe.typ", "<test>", "--field", "value"],
            cwd=self.root, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)[0]

    def test_example_is_one_page_and_only_recipient_is_in_window(self):
        text = self.compile()
        self.assertEqual(text.count("\f"), 1)
        self.assertIn("130,00", text)
        self.assertIn("20260011", text)
        bbox = subprocess.check_output(
            ["pdftotext", "-bbox", str(self.root / "out.pdf"), "-"], text=True)
        doc = ET.fromstring(bbox)
        words = doc.findall(".//{*}page/{*}word")
        mm = 72 / 25.4
        # Check the entire reserved top-left area, not just one envelope window.
        reserved = [word for word in words
                    if float(word.attrib["xMin"]) < 118 * mm
                    and float(word.attrib["yMin"]) < 110 * mm]
        expected = " ".join([self.invoice["recipient"]["name"],
                             *self.invoice["recipient"]["address"]])
        self.assertEqual(" ".join(word.text for word in reserved), expected)
        for word in reserved:
            self.assertGreaterEqual(float(word.attrib["xMin"]), 23 * mm - 1)
            self.assertLessEqual(float(word.attrib["xMax"]), 103 * mm + 1)
            # Font ascent can extend slightly above Typst's block origin.
            self.assertGreaterEqual(float(word.attrib["yMin"]), 48 * mm - 3)
            self.assertLessEqual(float(word.attrib["yMax"]), 72 * mm + 1)
        # The logo's lettering must also be at the right, inside the A4 sheet.
        for word in words:
            self.assertGreaterEqual(float(word.attrib["xMin"]), 0)
            self.assertLessEqual(float(word.attrib["xMax"]), 210 * mm + 1)

    def test_published_barcode_vectors(self):
        # Finance Finland v5.3, sections 13.1 and 13.2, invoice no. 1.
        for reference, pairs, checksum in [
            ("86851 62596 19897",
             "47 94 40 52 02 00 36 08 20 04 88 31 50 00 00 00 08 68 51 62 59 61 98 97 10 06 12", 40),
            ("RF09 8685 1625 9619 897",
             "57 94 40 52 02 00 36 08 20 04 88 31 50 90 00 00 08 68 51 62 59 61 98 97 10 06 12", 74),
        ]:
            with self.subTest(reference=reference):
                expr = ('bank-payload("FI79 4405 2020 0360 82", '
                        f'"{reference}", 488315, datetime(year: 2010, month: 6, day: 12))')
                self.assertEqual(self.query(expr), pairs.replace(" ", ""))
                self.assertEqual(self.query(f"code128-symbols({expr})"),
                                 [105, *map(int, pairs.split()), checksum, 106])

    def test_sender_contacts_are_in_upper_right_and_bottom_margin(self):
        self.compile()
        bbox = subprocess.check_output(
            ["pdftotext", "-bbox", str(self.root / "out.pdf"), "-"], text=True)
        words = ET.fromstring(bbox).findall(".//{*}page/{*}word")
        mm = 72 / 25.4
        for contact in (self.invoice["sender"]["business_id"], self.invoice["sender"]["email"]):
            matches = [word for word in words if word.text == contact]
            self.assertEqual(len(matches), 2)
            header, footer = sorted(matches, key=lambda word: float(word.attrib["yMin"]))
            self.assertGreaterEqual(float(header.attrib["xMin"]), 125 * mm - 1)
            self.assertLess(float(header.attrib["yMax"]), 55 * mm)
            self.assertGreaterEqual(float(footer.attrib["yMin"]), 279 * mm)
            self.assertLess(float(footer.attrib["yMax"]), 297 * mm)

    def test_domestic_reference_check_digit_is_appended(self):
        for base, expected in [
            ("123", "1232"),
            ("118", "1180"),
            ("123456", "1234561"),
            ("2026 001", "20260011"),
            ("9" * 19, "9" * 19 + "3"),
        ]:
            with self.subTest(base=base):
                self.assertEqual(self.query(f'complete-reference("{base}")'), expected)
        # Finance Finland v5.3, domestic test invoice no. 1, without its check digit.
        payload = self.query(
            'bank-payload("FI79 4405 2020 0360 82", '
            'complete-reference("86851625961989"), 488315, '
            'datetime(year: 2010, month: 6, day: 12))')
        self.assertEqual(payload, "479440520200360820048831500000000868516259619897100612")

    def test_rf_reference_is_not_modified(self):
        invoice = dict(self.invoice, reference="RF09 8685 1625 9619 897")
        self.assertIn("RF09868516259619897", self.compile(invoice))
        self.assertEqual(self.query('complete-reference("RF09 8685 1625 9619 897")'),
                         "RF09868516259619897")

    def test_mixed_vat_and_fractional_quantities(self):
        invoice = copy.deepcopy(self.invoice)
        invoice["items"] = [
            {"description": "Test A", "quantity": 2.5, "unit": "h",
             "unit_price_cents": 1200, "vat_percent": 25.5},
            {"description": "Test B", "quantity": 1, "unit": "kpl",
             "unit_price_cents": 1000, "vat_percent": 14},
            {"description": "Test C", "quantity": 1, "unit": "kpl",
             "unit_price_cents": 100, "vat_percent": 25.5},
        ]
        text = self.compile(invoice)
        for amount in ("41,00", "37,65", "11,40", "1,26", "7,91", "1,40", "50,31"):
            self.assertIn(amount, text)
        self.assertEqual(text.count("ALV 25,5 %"), 1)

    def test_many_rows_repeat_headers_and_keep_payment_on_last_page(self):
        invoice = copy.deepcopy(self.invoice)
        invoice["items"] = [dict(invoice["items"][0], description=f"Rivi {i}")
                            for i in range(1, 81)]
        pages = self.compile(invoice).split("\f")[:-1]
        self.assertGreater(len(pages), 1)
        self.assertIn("Rivi 80", "".join(pages))
        self.assertIn("Viitenumero", pages[-1])
        self.assertIn("8000,00", pages[-1])
        for page in pages[1:]:
            self.assertNotIn(invoice["recipient"]["name"], page)
            if "Rivi " in page:
                self.assertIn("Kuvaus", page)
        for page in pages:
            self.assertIn(invoice["sender"]["email"], page)
            self.assertIn(invoice["sender"]["business_id"], page)

    def test_invalid_payment_data_is_rejected(self):
        for field, value, error in [
            ("reference", "2026X", "Domestic reference base must contain"),
            ("reference", "12", "Domestic reference base must contain"),
            ("reference", "1" * 20, "Domestic reference base must contain"),
            ("reference", "0123", "Domestic reference base must contain"),
            ("reference", "", "Domestic reference base must contain"),
            ("reference", 123, "Reference must be provided as a string"),
            ("reference", "RF10 8685 1625 9619 897", "RF reference checksum does not match"),
            ("due_date", "2026-02-30", "day"),
        ]:
            with self.subTest(field=field):
                invoice = dict(self.invoice, **{field: value})
                self.assertIn(error, self.compile(invoice, success=False))
        invoice = copy.deepcopy(self.invoice)
        invoice["sender"]["iban"] = "FI59 1017 1000 0001 22"
        self.assertIn("IBAN checksum does not match", self.compile(invoice, success=False))

    def test_overlong_address_is_rejected(self):
        invoice = copy.deepcopy(self.invoice)
        invoice["recipient"]["address"] = ["Osoiterivi"] * 12
        self.assertIn("do not fit in the reserved space", self.compile(invoice, success=False))

    def test_no_barcode_and_optional_fields(self):
        invoice = copy.deepcopy(self.invoice)
        invoice["barcode"] = False
        invoice["sender"]["iban"] = "DE89 3704 0044 0532 0130 00"
        for key in ("service_period", "customer_reference", "late_interest",
                    "message", "tax_note", "notes"):
            del invoice[key]
        text = self.compile(invoice)
        self.assertIn("DE89", text)
        self.assertIn("130,00", text)
        self.assertIn("20260011", text)
        self.assertNotIn("Viivästyskorko", text)


if __name__ == "__main__":
    unittest.main()
