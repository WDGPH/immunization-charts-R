// --- IMMUNIZATION NOTICE TABLE FUNCTION --- //
// Description: A typst template that dynamically generates immunization history tables.
// Author: Kassy Raymond
// Date Created: 2025-05-22
// Date Last Updated: 2025-05-22
// ----------------------------------------- //

// Link formatting
#show link: underline

// Custom header formatting
#let header_text_size = 10pt

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
  font: "Fira Sans",
  size: 10pt
)

// Diseases - FIXME these should actually be read in from the yaml file
#let diseases =(
  "Diphtheria",
  "Tetanus",
  "Pertussis",
  "Polio",
  "Hib",
  "Pneumococcal",
  "Rotavirus",
  "Measles",
  "Mumps",
  "Rubella",
  "Meningococcal",
  "Varicella",
  "Hepatitis B",
  "HPV"
)

#let data = json("client_data.json").at("1110246921")

#let received = data.received

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

  // --- Create the table ---
  align(center)[
    #table(
        columns: (53pt, 42pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 15pt, 180pt),
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
          [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Varicella]]]],
          [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Hepatitis]]]],
          [#align(bottom)[#text(size: 10pt)[#rotate(-90deg, reflow: true)[Other]]]],
          [#align(bottom + left)[#text(size: 10pt)[Vaccine(s)]]],
        ),
      stroke: 1pt,
      inset: 5pt,
      align: center + horizon, 
      ..table_rows.flatten(), 
    )
  ]
}

#immunization-table(received, diseases)