#import "@preview/wrap-it:0.1.0": wrap-content

#show link: underline
#set page(numbering: "Page 1 of 2")

#set page(margin: (top: 1cm, bottom: 2cm, left: 2cm, right: 2cm))
#set par(justify: false)

#let wdgteal = rgb(0, 85, 104)
#let darkred = rgb(153, 0, 0)

#set align(center)
#set text(fill: darkred)
#heading[Bring this notice to your family doctor or healthcare provider]

#set align(left)
#image("logo.svg", width: 40%)

#set align(right)

Immunization Notice

#set align(left)
#set text(fill: black)
As of {date} our files show that {name} has not received the following immunization(s):

{list of immunizations}

It is the responsibility of the student or their parent/guardian to update this immunization record by reporting the
vaccines received to Public Health. For your reference, a record of all immunizations on file with Public Health for the
student, excluding seasonal vaccinations against influenza and COVID-19, has been included below.

For more information on immunization exemptions, please visit: #link("https://wdgpublichealth.ca/your-kids/vaccination")

#pagebreak()

The information in this notice was collected under the authority of the Health Protection and Promotion Act in accordance with the Municipal Freedom of Information and Protection of Privacy Act and the Personal Health Information Protection Act. This information is used for the delivery of public health programs and services; the administration of the agency; and the maintenance of healthcare databases, registries and related research, in compliance with legal and regulatory requirements. Any questions about the management of this information should be addressed to the Chief Privacy Officer at 1-800-265-7293 ext. 2975 or #link("privacy@wdgpublichealth.ca").