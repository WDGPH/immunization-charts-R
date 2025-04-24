// --- IMMUNIZATION NOTICE TYPST TEMPLATE --- //
// Description: A typst template for dynamically created immunization reports for WDGPH. Template uses mock data about Peter Parker. 
// Author: Kassy Raymond
// Date Created: 2025-04-24
// Date Last Updated: 2025-04-24
// ----------------------------------------- //

// Link formatting
#show link: underline

// General document formatting 
#set text(fill: black)
#set page(numbering: "1 of 1")
#set page(margin: (top: 1cm, bottom: 2cm, left: 2cm, right: 2cm))
#set par(justify: false)

// Custom colours
#let wdgteal = rgb(0, 85, 104)
#let darkred = rgb(153, 0, 0)

// Custom shortcuts
#let vax = ("⬤")

// Font formatting
#set text(
  font: "PT Sans",
  size: 10pt
)

// Begin content
#align(center)[
#text(size: 14pt, fill: darkred)[*Bring this notice to your family doctor or healthcare provider*]
]

#v(0.5cm)

// Logo and immunization notice formatting
#grid(
  
  columns: (50%,40%), 
  gutter: 5%, 
  [#image("assets/logo.svg", width: 6.5cm)],
  [#set align(right + bottom)
    #text(size: 20pt, fill: black)[*Immunization Notice*]
  ]
  
)

#v(1cm)

// Chart with client information

#align(center)[
#table(
  columns: (0.5fr, 0.5fr),
  inset: 10pt,
  [#align(left)[
    To: \
*PETER PARKER* \
\
*20 INGRAM STREET* \
*FOREST HILLS, NEW YORK 11375*]
  ], 
  [#align(left)[
    Client ID: *SPDR0001*\
    \
    Date of Birth: *August 10, 2001*\
    \
    School: *MIDTOWN SCHOOL OF SCIENCE AND TECHNOLOGY*
  ]],
)
]


#v(0.5cm)

// Notice for immunizations

As of *April 01, 2025* our files show that *PETER PARKER* has not received the following immunization(s):

#v(0.25cm)

- *Goblin Fever*
- *Radioactive Bite*

#v(0.25cm)

// Text

It is the responsibility of the student or their parent/guardian to update this immunization record by reporting the
vaccines received to Public Health. For your reference, a record of all immunizations on file with Public Health for the
student, excluding seasonal vaccinations against influenza and COVID-19, has been included below.

For more information on immunization exemptions, please visit: #text(fill:wdgteal)[*#link("https://wdgpublichealth.ca/your-kids/vaccination")*]

// Table of immunization records
// Symbol for circle: #sym.circle.filled

#align(center)[
#table(
  columns: (53pt, 42pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 180pt),
  table.header(
    [#align(bottom + left)[#text(size: 10pt)[Date Given]]],
    [#align(bottom + left)[#text(size: 10pt)[At Age]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Goblin Fever]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Radioactive Bite]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Parkerosis]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Octo-Flu]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Symbiote Rash]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Arachnopox]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Multiverse Virus]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Webpox]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Stinger Syndrome]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Spider Sense Loss]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Clone Spots]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Venomitis]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Web Wart]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Other]]]],
    [#align(bottom + left)[#text(size: 10pt)[Vaccine(s)]]],
  ),
  [2010-08-10],[#align(left)[#text[0Y 6M]]],[#vax],[#vax],[#vax],[#vax],[#vax],[#vax],[#vax],[],[],[],[],[],[],[],[#align(left)[#text[Webserum-1, Spider-Vax]]],
  [2010-11-15],[#align(left)[#text[0Y 9M]]],[#vax],[#vax],[#vax],[#vax],[#vax],[#vax],[#vax],[],[],[],[],[],[],[],[#align(left)[#text[Webserum-2, Spider-Vax]]],
  [2011-05-02],[#align(left)[#text[1Y 3M]]],[#vax],[#vax],[#vax],[#vax],[#vax],[#vax],[#vax],[],[],[],[],[],[],[],[#align(left)[#text[Webserum-3, Spider-Vax]]],
  [2011-08-12],[#align(left)[#text[1Y 6M]]],[],[],[],[],[],[],[],[#vax],[#vax],[#vax],[#vax],[],[],[],[#align(left)[#text[Spidey-MMR, Men-Sting-C]]],
  [2011-11-22],[#align(left)[#text[1Y 9M]]],[#vax],[#vax],[#vax],[#vax],[#vax],[],[],[#vax],[#vax],[#vax],[],[],[],[],[#align(left)[#text[Webserum-Booster, Spidey-MMR]]],
  [2022-11-01],[#align(left)[#text[12Y 3M]]],[],[],[],[],[],[#vax],[],[],[],[],[#vax],[],[],[],[#align(left)[#text[Spider-Pneu-C, Wallcrawl-VAR]]],
  [2023-06-15],[#align(left)[#text[13Y 0M]]],[#vax],[#vax],[#vax],[#vax],[],[],[],[],[],[],[#vax],[],[],[],[#align(left)[#text[Tingle-Tdap, Wallcrawl-VAR]]],
  [2024-12-20],[#align(left)[#text[14Y 6M]]],[],[],[],[],[],[],[],[],[],[#vax],[],[#vax],[#vax],[],[#align(left)[#text[Venom-B, Spider-Guard-9]]],
)]

#set align(center)
End of immunization record




#v(0.5cm)

// End notice 

#set align(left)
#set align(bottom)
#text(size: 8pt)[
The information in this notice was collected under the authority of the _Health Protection and Promotion Act_ in accordance with the _Municipal Freedom of Information and Protection of Privacy Act_ and the _Personal Health Information Protection Act_. This information is used for the delivery of public health programs and services; the administration of the agency; and the maintenance of healthcare databases, registries and related research, in compliance with legal and regulatory requirements. Any questions about the management of this information should be addressed to the Chief Privacy Officer at 1-800-265-7293 ext. 2975 or #link("privacy@wdgpublichealth.ca").]