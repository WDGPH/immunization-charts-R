// --- CCEYA NOTICE TEMPLATE --- //
// Description: A typst template that dynamically generates cceya templates.
// Author: Kassy Raymond
// Date Created: 2025-05-22
// Date Last Updated: 2025-06-11
// ----------------------------------------- //

// Link formatting
#show link: underline

// Custom header formatting
#let header_text_size = 10pt

// General document formatting 
#set text(fill: black)
#set par(justify: false)

// Custom colours
#let wdgteal = rgb(0, 85, 104)
#let darkred = rgb(153, 0, 0)
#let darkblue = rgb(0, 83, 104)
#let linkcolor = rgb(0, 0, 238)

// Formatting links 
#show link: underline

// Custom shortcuts
#let vax = ("⬤")

// Font formatting
#set text(
  font: "Fira Sans",
  size: 10pt
)

// Read diseases from yaml file 
#let diseases_yaml(contents) = {
    contents.chart_diseases_header
}
  
#let diseases = diseases_yaml(yaml("parameters.yaml"))

// Immunization Notice Section
#let immunization_notice(client, client_id, immunizations_due) = block[


#v(0.5cm)

// Logo and immunization notice formatting
#grid(
  
  columns: (50%,50%), 
  gutter: 5%, 
  [#image("logo.svg", width: 8.5cm)],
  [#set align(center + bottom)
    #text(size: 22pt, fill: darkblue)[*Request for immunization record*]]
  
)

#v(1cm)

// Chart with client information

#align(center)[
#table(
  columns: (0.5fr, 0.5fr),
  inset: 10pt,
  [#align(left)[
    To Parent/Guardian of: \
*#client.name* \
\

Address: \

*#client.address*  \
*#client.city*  ]]
, 
  [#align(left)[
    Client ID: #smallcaps[*#client_id*]\
    \
    Date of Birth: *#client.date_of_birth*\
    \
    Childcare Centre: #smallcaps[*#client.school*]
  ]],
)
]


#v(0.5cm)

// Notice for immunizations
Wellington-Dufferin-Guelph (WDG) Public Health does not have up-to-date vaccination records for your child. Please review the Immunization Record on page 2 and update your child's record by using one of the following options:

#v(0.25cm)

1.	By visiting #text(fill:linkcolor)[#link("www.immunizewdg.ca")]
2.	By emailing #text(fill:linkcolor)[#link("vaccine.records@wdgpublichealth.ca")]
3.	By mailing a photocopy of your child’s immunization record to Vaccine Records, 160 Chancellors Way, Guelph, Ontario N1G 0E1
4.	By Phone: 1-800-265-7293 ext. 7006


#v(0.25cm)

// Text

Please update Public Health and your childcare centre every time your child receives a vaccine. By keeping your child's vaccinations up to date, you are not only protecting their health but also the health of other children and staff at the childcare centre.  

*If you are choosing not to immunize your child*, a valid medical exemption or statement of conscience or religious belief must be completed and submitted to Public Health. Links to these forms can be located at #text(fill:wdgteal)[#link("https://wdgpublichealth.ca/your-kids/vaccination")]. Please note this exemption is for childcare only and a new exemption will be required upon enrollment in elementary school.

If there is an outbreak of a vaccine-preventable disease, Public Health may require that children who are not adequately immunized (including those with exemptions) be excluded from the childcare centre until the outbreak is over. 

If you have any questions about your child’s vaccines, please call 1-800-265-7293 ext. 7006 to speak with a Public Health Nurse.

Sincerely,

#image("20250611_MatthewTenebaum_Signature.jpg", width: 4cm)

Matthew Tenenbaum, MD, CCFP, MPH, FRCPC

Associate Medical Officer of Health

#set align(center + bottom)
#text(size: 12pt, fill: darkblue)[*Every time your child gets a vaccine, please update their immunization record with Public Health. For more information visit* #text(fill:linkcolor)[*#link("www.immunizewdg.ca")*]]

]

#let vaccine_table(client_id) = block[

  #align(right + top)[
  #text(size: 10pt, fill: black)[Client ID: #client_id]]
  
  #v(0.5cm)

  #grid(
  
  columns: (50%,50%), 
  gutter: 5%, 
  [#image("logo.svg", width: 6cm)],
  [#set align(center + bottom)
    #text(size: 20.5pt, fill: black)[*Immunization Record*]]
  
)

  #v(0.5cm)

  Below is a record of all immunizations received by the student on file with Public Health, excluding seasonal vaccinations against influenza and COVID-19. We appreciate your cooperation in ensuring this student immunization record is complete and accurate.

  #align(center)[
#table(
  columns: (53pt, 42pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 180pt),
  rows: (auto, 15pt),
  table.header(
    [#align(bottom + left)[#text(size: 10pt)[Date Given]]],
    [#align(bottom + left)[#text(size: 10pt)[At Age]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Diptheria]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Tetanus]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Pertussis]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Polio]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Hib]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Pneumococcal]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Rotavirus]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Measles]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Mumps]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Rubella]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Meningococcal]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Vericella]]]],
    [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Hepatitis B]]]],
    [#align(bottom + left)[#text(size: 10pt)[Vaccine(s)]]],
  ),
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
  [],[#align(left)[]],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[#align(left)[]],
)]
  
]


// Read in data from client_ids 
#let client_ids = csv("client_ids.csv", delimiter: ",", row-type: array)


#for row in client_ids {

  let reset = <__reset>
  let subtotal() = {
  let loc = here()
  let list = query(selector(reset).after(loc))
  if list.len() > 0 { 
    counter(page).at(list.first().location()).first() - 1
  } else {
    counter(page).final().first() 
  }
}

  let page-numbers = context numbering(
  "1 / 1",
  ..counter(page).get(),
  subtotal(),
  )

  set page(margin: (top: 1cm, bottom: 2cm, left: 2cm, right: 2cm),
  footer: align(center, page-numbers))

  let value = row.at(0) // Access the first (and only) element of the row
  let data = json("client_data.json").at(value)
  let received = data.received

  // get vaccines due, split string into an array of sub strings
  let vaccines_due = data.vaccines_due

  let vaccines_due_array = vaccines_due.split(", ")

  let section(it) = {
    [#metadata(none)#reset]
    pagebreak(weak: true)
    counter(page).update(1) // Reset page counter for this section
    pagebreak(weak: true)
    immunization_notice(data, value, vaccines_due_array)
    pagebreak()
    vaccine_table(value)
  }

  section([] + page-numbers)

}
