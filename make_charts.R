##############
# Parameters #
##############

# Input file
clients = readxl::read_xlsx("input//Daycare_overdue_June4_2025.xlsx", sheet=2, col_types = "text")

# Output folder
output_folder = paste0("output-", stringr::str_remove_all(Sys.time(), "\\W"))

# Expected columns in input files
expected_columns = c(
  "Language",
  "School",
  "Client ID",
  "First Name",
  "Last Name",
  "Date of Birth",
  "Street Address",
  "City",
  "Province",
  "Postal Code",
  "Vaccines Due",
  "Received Agents"
  )

# Diseases, in order, to include immunization history chart
# Mark as 'F' to collapse the disease into the 'Other' column
chart_diseases = c(
  'Diphtheria'    = T,
  'Tetanus'       = T,
  'Pertussis'     = T,
  'Polio'         = T,
  'Hib'           = T,
  'Pneumococcal'  = T,
  'Rotavirus'     = T,
  'Measles'       = T,
  'Mumps'         = T,
  'Rubella'       = T,
  'Meningococcal' = T,
  'Varicella'     = T,
  'Hepatitis B'   = T,
  'HPV'           = T
  )

# Vaccines or agents to ignore in/drop from immunization history
ignore_agents = c(
  'RSVAb',
  'VarIg',
  'HBIg',
  'RabIg',
  'Ig')

# To include in notice text as date that immunization history is reflective of
data_date = as.Date('2025-06-05')

# Minimum number of rows to show in immunization history chart
# Charts will be padded with rows as appropriate
min_rows = 5L

# Number of clients to include in a single PDF
# Note: 10 PDFs with 10 clients each will run slower than 1 PDF with 100 clients
# Use a batch size of 1 if you would like a single client per PDF file.
batch_size = 100L

##################
# End parameters #
##################

# Create output folder
dir.create(path = output_folder)

# Don't warn about package conflicts
options(conflicts.policy = list("warn" = F))

library(tidyr)
library(stringr)
library(dplyr)
library(purrr)
library(furrr)
library(magrittr)
library(kableExtra)

plan(multisession)

# Load vaccine - disease reference table
# Collapse as desired
vax_ref = readxl::read_xlsx(
  "vaccine_reference.xlsx",
  col_types = c("text", rep("logical", 15))) |>
  rowwise() |>
  mutate(`Other` = any(
    c_across(
      all_of(c(
        names(chart_diseases[chart_diseases == F]),
        "Other"))))) |>
  ungroup() |> 
  select(all_of(c(
    "Vaccine",
    names(chart_diseases[chart_diseases == T]),
    "Other")))

chart_num_diseases = sum(chart_diseases)

# Format column header information for LaTeX
chart_col_header = c(names(chart_diseases[chart_diseases == T]), "Other") |> 
  str_replace_all(
    pattern = "^([\\w\\s]+)$",
    replacement = "\\\\rotatebox{90}{\\1}")

chart_col_header_english = c("Date Given", "At Age", chart_col_header, "Vaccine(s)") |>
  paste(collapse = " & ")

chart_col_header_french = c("Date", "Âge", chart_col_header, "Vaccin(s)") |>
  paste(collapse = " & ")

#Y M age formatting
diff_ym = function(date1, date2){
  ym_paste = function(x){paste0(floor(x / 12), "Y ", floor(x %% 12), "M")}
  lubridate::time_length(date1 - date2, unit = "month") |>
  ym_paste()
  }

#A M age formatting
diff_am = function(date1, date2){
  am_paste = function(x){paste0(floor(x / 12), "A ", floor(x %% 12), "M")}
  lubridate::time_length(date1 - date2, unit = "month") |>
  am_paste()
  }

# Function to parse vaccination history
source("parse_vaccination_history.R")

# Latex utility functions
source("latex_utilities.R")

# Create a vector which will track vaccine occurrences
vaccine_occurrences = character(0)

clients = clients |>
  select(
    `Client ID`,
    `School` = `School/ Daycare ID`,
    `First Name`,
    `Last Name`,
    `Street Address`,
    `City`,
    `Province`,
    `Postal Code`,
    `Date of Birth`,
    `Received Agents` = `PEAR.Imms Given`
    ) |> 

  mutate(
    # Add Language column (English assumed as language data not provided)
    `Language` = "English",

    # Make text uppercase
    across(
    .cols = all_of(c(
      "School", "First Name", "Last Name",
      "Street Address",
      "City", "Province", "Postal Code")),
    .fns = \(x){
      x |>
        str_to_upper() |>
        str_squish() |>
        LaTeX_escape()
      })) |>
  
  mutate(
    # Formatting of fields
    across(`Date of Birth`,
      \(x) as.Date(as.integer(x), origin = "1899-12-30")),

    across(`Received Agents`,
      \(x) if_else(str_detect(x, pattern = "^- ,$"), NA_character_, x)),

    `Received Agents Table` = parse_vaccination_history(
      `Received Agents`,
      ignore_agents = ignore_agents,
      log_file = file.path(output_folder, "parse_vaccination_history.log")
      ),

    # Add `At Age` column to `Received Agents Table`
    # Track vaccine occurrences
    `Received Agents Table` = map2(
      .x = `Received Agents Table`,
      .y = `Date of Birth`,
      .f = \(x, y){
        if (nrow(x) > 0) {
          vaccine_occurrences <<- c(vaccine_occurrences, use_series(x, Vaccine))
        }

        x |>
          mutate(`At Age` = diff_ym(`Date Given`, y)) |>
          arrange(`Date Given`)
      }),
        
    # Create vaccination history chart based on `Received Agents Table`
    `Vaccine History Table` = map(
      .x = `Received Agents Table`,
      .f = \(x){x = x |>
        # Indicators for protection for diseases
        left_join(vax_ref, by = c("Vaccine"), relationship = "many-to-one") |>
    
        # Group vaccines given on same day
        group_by(`Date Given`, `At Age`) |>
        summarize(
          across(
            .cols = where(is.logical),
            .fns = \(x) any(x)),
          `Vaccine(s)` = paste(Vaccine, collapse = ", "),
          .groups = "drop") |>
        
        # Substitute "unsp" for "unspecified" in vaccines column to save space
        mutate(
          `Vaccine(s)` = str_replace_all(
            `Vaccine(s)`,
            pattern = "unspecified",
            replacement = "unsp"))}),

    # Create a LaTeX table
    `Vaccine History LaTeX` = map(
      .x = `Vaccine History Table`,
      .f = \(x){x = x |>
          
        # Use circle symbol for True, blank for false
        mutate(
          across(
          .cols = where(is.logical),
          .fns = \(x) if_else(x, "\\mycircle", "", missing = "")))  |>
          
        # Create LaTeX code
        kable("latex", escape = FALSE) |>
          
        # Trim header and footer (header and footer defined directly in Rmd)
        LaTeX_trim_lines(5L, 1L) |>
        
        # Pad table with empty rows in LaTeX
        # Number of diseases + Date Given, At Age, Other, And Vaccine(s)
        LaTeX_pad_rows(min_rows, chart_num_diseases + 4L)
      })
    )

vaccine_occurrences_table = tibble(`Vaccine` = vaccine_occurrences) |>
  group_by(Vaccine) |>
  summarize(n = n(), .groups = "drop") |>
  full_join(
    select(vax_ref, Vaccine),
    by = join_by(Vaccine),
    relationship = "one-to-one",
    keep = T) |>
  mutate(
    `Vaccine` = coalesce(`Vaccine.x`, `Vaccine.y`),
    `n` = replace_na(`n`, 0L),
    `Matched` = `n` == 0L | (!is.na(`Vaccine.x`) & !is.na(`Vaccine.y`))
  ) |>
  select(Vaccine, n, Matched) |>
  arrange(Vaccine)

readr::write_csv(
  vaccine_occurrences_table,
  paste0(output_folder, "/vaccine_occurrences.csv"))

if(filter(vaccine_occurrences_table, Matched == F) |> dim() |> extract(1) > 0L){
  warning("Unmatched vaccines detected. Review output/vaccine_occurrences.csv,
       and either make additions to ignore_agents parameter, or to
       vaccine reference file (vaccine_reference.xlsx) and re-run.")
  }

# Additional data processing for notice
clients = clients |>
  
  # Final formatting and variable selection for document creation
  rowwise() |>
  mutate(
    `Name` = paste(na.omit(c_across(ends_with("Name"))), collapse = " ")) |>
  ungroup() |>
  mutate(
    # Non-breaking spaces within name
    `Name` = str_replace_all(`Name`, "\\s", '~'),
    `Birth Year`= lubridate::year(`Date of Birth`),
    `Date of Birth` = 
      case_when(
        `Language` == "French" ~ withr::with_locale(
          c(LC_TIME = "fr_FR.UTF-8"),
          format(`Date of Birth`, "%d~%B~%Y")),
        .default = format(`Date of Birth`, "%B~%d,~%Y")
      )
    )

# Helper to split into batches
split_batches = function(data, batch_size) {
  data |>
    mutate(batch = 1 + (row_number() - 1) %/% batch_size) |>
    group_split(batch)
}

# Render batch function
render_batch = function(batch_data, lang = "EN") {
  notice_data = batch_data
  notice_filename = paste0(
    lang, "_",
    stringr::str_replace_all(notice_data$School[1], "\\W+", "_"),
    "_", notice_data$batch[1],
    ".pdf"
  )
  
  cat("Rendering:", notice_filename, "with", nrow(notice_data), "students\n")
  
  rmarkdown::render(
    input = if (lang == "EN") "chart_template_english.Rmd" else "chart_template_french.Rmd",
    output_file = notice_filename,
    output_dir = output_folder,
    params = list(
      client_data = notice_data,
      data_date = if (lang == "FR") {
        withr::with_locale(c(LC_TIME = "fr_FR.UTF-8"), format(data_date, "%d %B %Y"))
      } else {
        format(data_date, "%B %d, %Y")
      },
      chart_num_diseases = chart_num_diseases,
      chart_col_header = if (lang == "FR") chart_col_header_french else chart_col_header_english
    ),
    quiet = TRUE
  )
}

# Batch clients for PDF generation
# English Clients
{
  start_time = Sys.time()
  
  progressr::with_progress({
    p = progressr::progressor(steps = nrow(clients |> filter(Language == "English")))
    
    clients |>
      filter(Language == "English") |>
      group_split(School) |>
      purrr::map(\(school_df) split_batches(school_df, batch_size)) |>
      purrr::flatten() |>
      furrr::future_map(\(x) {
        render_batch(x, lang = "EN")
        p(amount = nrow(x))
      })
  })

  end_time = Sys.time()
  cat("Total render time:", round(difftime(end_time, start_time, units = "secs"), 2), "seconds\n")
}