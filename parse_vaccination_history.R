parse_vaccination_history = function(
  xs,
  ignore_agents    = NULL,
  log_file         = NULL,
  console_levels   = c("WARNING","ERROR"),
  log_file_levels  = c("DEBUG", "INFO","WARNING","ERROR")
) {
  # initialize log on first call
  if (!is.null(log_file) && !file.exists(log_file)) {
    writeLines("=== parse_vaccination_history log ===\n", log_file)
  }

  # unified logger: writes to file only if log_file!=NULL and level in log_file_levels,
  # prints to console if level ∈ console_levels
  log_msg = function(level, ..., id = NULL) {
    body   = paste0(..., collapse = "")
    prefix = if (!is.null(id)) sprintf("[%s] ", id) else ""
    entry  = sprintf("%s[%s] %s\n", prefix, level, body)
    
    # Write to log file if specified and level is included
    if (!is.null(log_file) && level %in% log_file_levels) {
      cat(entry, file = log_file, append = TRUE)
    }
    
    # Write to console if level is included
    if (level %in% console_levels) {
      cat(entry)
    }
  }

  # iterate over each history string (xs), track record index
  purrr::imap(xs, function(x, record_id) {

    # Replace "- ," with NA
    x = na_if(x, "- ,")

    if (is.na(x) || nchar(str_trim(x)) == 0) {
      log_msg("INFO", "empty or NA input", id = record_id)
      return(tibble(
        `Date Given` = as.Date(character(0)),
        `Vaccine`    = character(0)
      ))
    }

    log_msg("INFO", "processing '", x, "'", id = record_id)
    x_clean = str_trim(str_remove(x, ",$"))
    entries   = str_split(x_clean, ",\\s*(?=\\w{3} \\d{1,2}, \\d{4})")[[1]]
    log_msg("INFO", "split into ", length(entries), " entries", id = record_id)

    # now parse each part, tracking a sub‐index
    purrr::imap_dfr(entries, function(entry, entry_id) {
      record_entry_id = paste0(record_id, "-", entry_id)
      log_msg("DEBUG", "parsing entry: '", entry, "'", id = record_entry_id)
      
      segment = str_split(entry, "(?<=^\\w{3} \\d{1,2}, \\d{4})\\s*-\\s*")[[1]]
      # log_msg("DEBUG", "segments found: ", length(segment), id = record_entry_id)
      
      if (length(segment) != 2) {
        log_msg("WARNING", "got ", length(segment), " segments: '", paste(segment, collapse=" | "), "'", id = record_entry_id)
      }

      date_str = str_trim(if (length(segment)>=1) segment[1] else NA_character_)
      agent = str_trim(if (length(segment)>=2) segment[2] else NA_character_)
      
      log_msg("INFO", "date: '", date_str, "', vaccine: '", agent, "'", id = record_entry_id)
      
      date = suppressWarnings(as.Date(date_str, "%b %d, %Y"))
      log_msg("DEBUG", "parsed date: ", as.character(date), id = record_entry_id)

      if (is.na(date) && !is.na(date_str)) {
        log_msg("WARNING", "could not parse date '", date_str, "'", id = record_entry_id)
      }
      if (is.na(agent)) {
        log_msg("WARNING", "missing vaccine for date '", date_str, "'", id = record_entry_id)
      }

      return(tibble(
        `Date Given` = date,
        `Vaccine` = agent
      ))

    }) |>
    filter(!(`Vaccine` %in% ignore_agents))
  })
}
