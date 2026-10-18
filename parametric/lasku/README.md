# Lasku (Typst)

Suomenkielinen A4-laskupohja, jonka ulkoasu ja vektorilogo perustuvat
`../muistiotosite/muistiotosite.typ`-pohjaan. Kaikki laskukohtaiset tiedot
luetaan JSONista. Ei Typst-paketteja, erillisiä logo-/viivakoodikuvia tai verkkoyhteyttä.
Testattu Typst 0.15.0:lla.

## Käyttö

Projektin juuresta:

```bash
# Mukana tuleva esimerkkilasku:
typst compile tools/lasku/lasku.typ lasku.pdf

# Oma JSON (polku suhteessa lasku.typ-tiedostoon):
typst compile --root . --input invoice=../../data/laskut/2026-001.json tools/lasku/lasku.typ lasku.pdf
```

Kopioi `esimerkki.json` oman laskun pohjaksi. **Esimerkin IBAN on Finanssialan
testiaineistosta, ei yhdistyksen tili.** Vaihda maksutiedot ja kaikki muut
esimerkkitiedot sekä poista esimerkkilaskun varoitus ennen oikeaa käyttöä.
JSON-teksti tulostetaan sellaisenaan, eikä sitä tulkita Typst-koodiksi.

## JSON-tiedot

- `sender`: `name`, `address` (osoiterivien lista), `business_id`, `email`,
  `iban`, `bic`, `bank`; valinnainen `phone`.
- `recipient`: `name`, `address` (vain postitusosoite ja mahdollinen vastaanottava
  henkilö/osasto); valinnainen `business_id` tulostetaan ikkunan ulkopuolelle.
- `number`, `date`, `due_date`, `reference`, `payment_terms`, `subject`.
  Päivämäärät ovat muodossa `YYYY-MM-DD`. Viite annetaan **merkkijonona**;
  välilyönnit ovat sallittuja.
  - Kotimainen viite: anna **3–19 numeron pohja ilman tarkistenumeroa**, ei
    etunollaa. Pohja laskee 7–3–1-painotuksella modulo 10 -tarkisteen ja lisää sen
    sekä näkyvään viitteeseen että viivakoodiin. Esimerkiksi `"reference": "2026001"`
    tuottaa viitteen `20260011`.
  - RF-viite: anna edelleen **koko RF-viite tarkisteineen**; se tarkistetaan,
    eikä sen loppuun lisätä numeroa.
  - Jos käytät aiempaa JSONia, poista kotimaisen viitteen viimeinen tarkistenumero
    syötteestä, jottei pohja lisää toista tarkistenumeroa.
- `items`: vähintään yksi rivi, jokaisella `description`, `quantity`, `unit`,
  `unit_price_cents` ja `vat_percent`.
  Hinta on **veroton yksikköhinta kokonaisina sentteinä**, esimerkiksi `1200`
  tarkoittaa 12,00 €. Määrä voi olla desimaali (`2.5`); hinnan on oltava
  ei-negatiivinen ja määrän positiivinen. Tämä ei ole hyvityslaskupohja.
  `vat_percent` voi olla esimerkiksi `0`, `14` tai `25.5`.
- Valinnaiset `service_period`, `customer_reference`, `late_interest`,
  `message`, `tax_note`, `notes`: puuttuva tai tyhjä kenttä jätetään pois.
  Merkitse toimituspäivä/-jakso ja verottomuuden peruste laskun vaatimusten mukaan.
- `barcode`: valinnainen totuusarvo, oletuksena `true`.

Veroton rivisumma pyöristetään senttiin ja sen ALV lasketaan ja pyöristetään
senttiin rivikohtaisesti. Loppusumma ja verokantakohtainen erittely lasketaan
näistä samoista riveistä; summia ei anneta erikseen JSONissa. Valuutta on EUR.
Pitkä lasku jatkuu automaattisesti uusille sivuille; taulukon otsikot toistuvat
ja maksutiedot sekä viivakoodi pysyvät yhdessä laskun lopussa.

## Ikkunakuori ja taitto

- Tulosta A4 **100 % / todellisessa koossa**, yksipuolisena. Älä käytä
  ”sovita sivulle” -asetusta.
- Taita poikittain puoliksi **148,5 mm** yläreunasta, **alaosa taakse**, niin
  että ensimmäisen sivun yläosa ja osoite jäävät ulospäin. Käytä C5-kuorta
  (229 × 162 mm), jossa on ikkuna vasemmalla.
- Osoitteen paikka A4:n vasemmasta yläkulmasta on **x = 23 mm, y = 48 mm**,
  leveys **80 mm**, enimmäiskorkeus **24 mm**. Nimi kuuluu tähän korkeuteen.
  Tavallinen nelirivinen osoite mahtuu hyvin. Liian korkea osoite pysäyttää
  käännöksen sen sijaan, että se valuisi muiden tietojen päälle.
- Mitoituksen kohde on **100 × 35 mm** pieni ikkuna, jonka näkyvä alue paperilla
  alkaa noin kohdasta **x = 18 mm, y = 40 mm**. Nämä ovat **paperin**, eivät
  kirjekuoren koordinaatteja. Kuoren marginaalit ja paperin asento vaikuttavat
  lopulliseen kohdistukseen.
- Koko vasen yläalue (**x = 0–118 mm, y = 0–110 mm**) on varattu vain
  vastaanottajan nimelle ja osoitteelle. Laskuttaja, logo, Y-tunnukset ja
  laskutiedot ovat sen ulkopuolella; ikkunassa ei ole edes ”Vastaanottaja”-otsikkoa.

**Tee koetulostus ja tarkista omalla kuorella**, myös paperia hieman siirtäen.
Kaikki C5-kuoret eivät käytä samaa ikkunan paikkaa/kokoa. Esimerkiksi iso
90 × 60 mm ikkuna voi vaatia osoitteen siirtämistä: säädä `lasku.typ`-tiedoston
osoitelohkon `dx`/`dy`-arvoja ja tarvittaessa leveyttä/korkeutta, pitäen muu
sisältö poissa ikkunan alueelta. Monisivuinen lasku kannattaa taittaa niin,
että ensimmäinen sivu on uloimpana.

## Pankkiviivakoodi

`pankkiviivakoodi.typ` piirtää Code 128 C -viivakoodin Typstin vektorigrafiikalla:

- suomalainen FI-IBAN, kotimainen viite → versio 4;
- suomalainen FI-IBAN, numerosisältöinen RF-viite → versio 5;
- sama laskettu loppusumma ja eräpäivä kuin näkyvissä maksutiedoissa;
- IBANin ja viitteen tarkisteiden tarkistus sekä Code 128 -tarkiste;
- viivojen leveys 105 mm, korkeus 12 mm, molemmilla sivuilla 20 mm tyhjää.

Viivakoodin tietosisältö perustuu
[Finanssialan oppaaseen v5.3](https://www.finanssiala.fi/wp-content/uploads/2021/03/Bank_bar_code_guide.pdf).
Maksutietolohko ei kuitenkaan ole pankin virallinen tilisiirtolomake; laskupohja
on tarkoitettu verkkopankissa tai mobiilipankissa maksettavaksi.
Tarkista luettavuus omalla pankkisovelluksella ennen oikeiden laskujen lähettämistä.

Aseta `"barcode": false`, jos et halua viivakoodia tai käytät ulkomaista IBANia,
kirjaimia sisältävää RF-viitettä, yli 999 999,99 € summaa tai vuosien 2000–2099
ulkopuolista eräpäivää. Näissä tapauksissa käännös muuten pysähtyy virheeseen.
IBANin ja RF-viitteen tarkisteet tarkistetaan ja kotimaisen viitteen tarkiste
lasketaan myös ilman viivakoodia.

## Testit

Vaativat Pythonin, `typst`-komennon ja Popplerin `pdftotext`-komennon:

```bash
python -m unittest discover -s tools/lasku -p 'test_*.py' -v
```
