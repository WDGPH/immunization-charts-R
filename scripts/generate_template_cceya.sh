#!/bin/bash

INDIR=${1}
FILENAME=${2}
LOGO=${3}
SIGNATURE=${4}
PARAMETERS=${5}

CLIENTIDFILE=${FILENAME}_client_ids.csv
JSONFILE=${FILENAME}.json
OUTFILE=${INDIR}/${FILENAME}_immunization_notice.typ

echo "
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
#let vax = (\"⬤\")

// Font formatting
#set text(
  font: \"FreeSans\",
  size: 10pt
)

// Read diseases from yaml file 
#let diseases_yaml(contents) = {
    contents.chart_diseases_header
}
  
#let diseases = diseases_yaml(yaml(\"parameters.yaml\"))

// Immunization Notice Section
#let immunization_notice(client, client_id) = block[


#v(0.5cm)

// Logo and immunization notice formatting
#grid(
  
  columns: (50%,50%), 
  gutter: 5%, 
  [#image(\"${LOGO}\", width: 8.5cm)],
  [#set align(center + bottom)
    #text(size: 22pt, fill: darkblue)[*Request for immunization record*]]
  
)

#v(1cm)

// Chart with client information

#align(center)[
  #table(
    columns: (0.5fr, 0.5fr),
    inset: 10pt,
    align(left)[
      To Parent/Guardian of: \
      *#client.name* \
      #linebreak()

      Address: \
      #linebreak()

      #smallcaps[*#client.address*] \
      #smallcaps[*#client.city*],
      #smallcaps[*#client.province*], \
      #smallcaps[*#client.postal_code*] \
    ],
    align(left)[
      Client ID: #smallcaps[*#client_id*]\
      #linebreak()
      Ontario Immunization ID: *#client.ontario_immunization_id*\
      #linebreak()

      Date of Birth: *#client.date_of_birth*\
      #linebreak()

      Childcare Centre:
      #smallcaps[*#client.school*]
    ]
  )
]


#v(0.5cm)

// Notice for immunizations
Wellington-Dufferin-Guelph (WDG) Public Health does not have up-to-date vaccination records for your child. Please review the Immunization Record on page 2 and update your child's record by using one of the following options:

#v(0.25cm)

1.	By visiting #text(fill:linkcolor)[#link(\"www.immunizewdg.ca\")]
2.	By emailing #text(fill:linkcolor)[#link(\"vaccine.records@wdgpublichealth.ca\")]
3.	By mailing a photocopy of your child’s immunization record to Vaccine Records, 160 Chancellors Way, Guelph, Ontario N1G 0E1
4.	By Phone: 1-800-265-7293 ext. 7006


#v(0.25cm)

// Text

Please update Public Health and your childcare centre every time your child receives a vaccine. By keeping your child's vaccinations up to date, you are not only protecting their health but also the health of other children and staff at the childcare centre.  

*If you are choosing not to immunize your child*, a valid medical exemption or statement of conscience or religious belief must be completed and submitted to Public Health. Links to these forms can be located at #text(fill:wdgteal)[#link(\"https://wdgpublichealth.ca/your-kids/vaccination\")]. Please note this exemption is for childcare only and a new exemption will be required upon enrollment in elementary school.

If there is an outbreak of a vaccine-preventable disease, Public Health may require that children who are not adequately immunized (including those with exemptions) be excluded from the childcare centre until the outbreak is over. 

If you have any questions about your child’s vaccines, please call 1-800-265-7293 ext. 7006 to speak with a Public Health Nurse.

Sincerely,

#image(\"${SIGNATURE}\", width: 4cm)

Matthew Tenenbaum, MD, CCFP, MPH, FRCPC

Associate Medical Officer of Health

#set align(center + bottom)
#text(size: 12pt, fill: darkblue)[*Every time your child gets a vaccine, please update their immunization record with Public Health. For more information visit* #text(fill:linkcolor)[*#link(\"www.immunizewdg.ca\")*]]

]

#let vaccine_table(client_id) = block[

  #align(right + top)[
  #text(size: 10pt, fill: black)[Client ID: #client_id]]
  
  #v(0.5cm)

  #grid(
  
  columns: (50%,50%), 
  gutter: 5%, 
  [#image(\"${LOGO}\", width: 6cm)],
  [#set align(center + bottom)
    #text(size: 20.5pt, fill: black)[*Immunization Record*]]
  
)

  #v(0.5cm)

  Below is a record of all immunizations received by the student on file with Public Health, excluding seasonal vaccinations against influenza and COVID-19. We appreciate your cooperation in ensuring this student immunization record is complete and accurate.
  
]

#let immunization-table-padded(diseases) = {

  let table_rows = ()

  let empty_rows_content = ()
  for _ in range(6) {
  table_rows.push((\"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\"))
  }

  let dynamic_headers = ()
  dynamic_headers.push([#align(bottom + left)[#text(size: 10pt)[Date Given]]])
  dynamic_headers.push([#align(bottom + left)[#text(size: 10pt)[At Age]]])

  for disease in diseases {
    dynamic_headers.push([#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[#disease]]]])
  }

  dynamic_headers.push([#align(bottom + left)[#text(size: 10pt)[Vaccine(s)]]])
  
  // --- Create the table ---
  align(center)[
    #table(
        columns: (57pt, 46pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 190pt),
        table.header(
          ..dynamic_headers
        ),
      stroke: 1pt,
      inset: 5pt,
      align: (
        left,
        left,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        left
      ), 
      ..table_rows.flatten(), 
    )
  ]
  
  
}

#let immunization-table-dynamic(data, diseases) = {

  // Prepare table rows ---
  let table_rows = ()
  for record in data {
    // Start row with Date Given and At Age
    let row_cells = (
      record.date_given,
      record.age,
    )

    // Populate disease columns with #vax or empty
    for disease_name in diseases {

      let cell_content = \"\"
      for record_disease in record.diseases {
        if record_disease == disease_name { 
          cell_content = vax
          // Found a match, no need to check other diseases for this cell
          break 
        }
      }
      row_cells.push(cell_content)
    }

    // Add the Vaccine(s) column content
    let vaccine_content = if type(record.vaccine) == array {
      record.vaccine.join(\", \") 
    } else {
      record.vaccine
    }
    row_cells.push(vaccine_content)

    table_rows.push(row_cells)
  }

  // Create dynamic headers based on the diseases
  let dynamic_headers = ()

  dynamic_headers.push([#align(bottom + left)[#text(size: 10pt)[Date Given]]])
  dynamic_headers.push([#align(bottom + left)[#text(size: 10pt)[At Age]]])

  for disease in diseases {
    dynamic_headers.push([#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[#disease]]]])
  }

  dynamic_headers.push([#align(bottom + left)[#text(size: 10pt)[Vaccine(s)]]])
  
  // --- Create the table ---
  align(center)[
    #table(
        columns: (57pt, 46pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 190pt),
        table.header(
          ..dynamic_headers
        ),
      stroke: 1pt,
      inset: 5pt,
      align: (
        left,
        left,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        center,
        left
      ), 
      ..table_rows.flatten(), 
    )
  ]
}

#let client_ids = csv(\"${CLIENTIDFILE}\", delimiter: \",\", row-type: array)

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
  \"1 / 1\",
  ..counter(page).get(),
  subtotal(),
  )

  set page(margin: (top: 1cm, bottom: 2cm, left: 2cm, right: 2cm),
  footer: align(center, page-numbers))

  let value = row.at(0) // Access the first (and only) element of the row
  let data = json(\"${JSONFILE}\").at(value)
  let received = data.received

  // get vaccines due, split string into an array of sub strings
  // let vaccines_due = data.vaccines_due

  // let vaccines_due_array = vaccines_due.split(\", \")

  let section(it) = {
    [#metadata(none)#reset]
    pagebreak(weak: true)
    counter(page).update(1) // Reset page counter for this section
    pagebreak(weak: true)
    immunization_notice(data, value) //, vaccines_due_array)
    pagebreak()
    vaccine_table(value)
    if received.len() == 0 {
      immunization-table-padded(diseases)
    } else {
      immunization-table-dynamic(received, diseases) 
    }
  }

  section([] + page-numbers)

}
}


}

" > "${OUTFILE}"