#!/bin/bash

INDIR=${1}
FILENAME=${2}
PARAMETERS=${3}
LOGO=${4}

CLIENTIDFILE=${INDIR}/${FILENAME}_client_ids.csv
JSONFILE=${INDIR}/${FILENAME}.json
OUTFILE=${INDIR}/${FILENAME}_immunization_notice.typ

echo "
// --- IMMUNIZATION NOTICE TEMPsATE --- //
// Description: A typst template that dynamically generates immunization notices and immunization history tables.
// Author: Kassy Raymond
// Date Created: 2025-05-22
// Date Last Updated: 2025-05-29
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
  
#let diseases = diseases_yaml(yaml(\""${PARAMETERS}"\"))

// Immunization table 
#let immunization-table(data, diseases) = {

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

      let cell_content = ""
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
      record.vaccine.join(", ") 
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

// Immunization Notice Section
#let immunization_notice(client, client_id, immunizations_due) = block[

// Begin content
#align(center)[
#text(size: 14pt, fill: darkred)[*Bring this notice to your family doctor or healthcare provider*]
]

#v(0.5cm)

// Logo and immunization notice formatting
#grid(
  
  columns: (50%,40%), 
  gutter: 5%, 
  [#image(\""${LOGO}"\", width: 6.5cm)],
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
*#client.name* \
\
*#client.address*  \
*#client.city*  ]]
, 
  [#align(left)[
    Client ID: #smallcaps[*#client_id*]\
    \
    Date of Birth: *#client.date_of_birth*\
    \
    School: #smallcaps[*#client.school*]
  ]],
)
]


#v(0.5cm)

// Notice for immunizations

As of *April 01, 2025* our files show that *#client.name* has not received the following immunization(s):

#v(0.25cm)

#for vaccine in immunizations_due [
  - *#vaccine*
]


#v(0.25cm)

// Text


It is the responsibility of the student or their parent/guardian to update this immunization record by reporting the
vaccines received to Public Health. For your reference, a record of all immunizations on file with Public Health for the
student, excluding seasonal vaccinations against influenza and COVID-19, has been included below.

For more information on immunization exemptions, please visit: #text(fill:wdgteal)[*#link("https://wdgpublichealth.ca/your-kids/vaccination")*]
]

#let end_of_immunization_notice() = [
  #set align(center)
  End of immunization record
  
  
  
  
  #v(0.5cm)
  
  // End notice 
  
  #set align(left)
  #set align(bottom)
  #text(size: 8pt)[
  The information in this notice was collected under the authority of the _Health Protection and Promotion Act_ in accordance with the _Municipal Freedom of Information and Protection of Privacy Act_ and the _Personal Health Information Protection Act_. This information is used for the delivery of public health programs and services; the administration of the agency; and the maintenance of healthcare databases, registries and related research, in compliance with legal and regulatory requirements. Any questions about the management of this information should be addressed to the Chief Privacy Officer at 1-800-265-7293 ext. 2975 or #link("privacy@wdgpublichealth.ca").]

]

// Read in data from client_ids 
#let client_ids = csv(\""${CLIENTIDFILE}"\", delimiter: ",", row-type: array)


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
  let data = json(\""${JSONFILE}"\").at(value)
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
    immunization-table(received, diseases)
    end_of_immunization_notice()
  }

  section([] + page-numbers)

}
" > "${OUTFILE}"