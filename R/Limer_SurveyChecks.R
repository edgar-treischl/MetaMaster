
#' Check if All Variables of the Meta Data are Distinct
#'
#' @description This function checks if all variables names of the meta data
#'  are distinct. It counts if a variable name is used more than once and returns
#'    a data frame with the results.
#' @param ubb Logical value indicating if UBB or survey will be checked.
#' @param export Export results to an Excel file (default is FALSE).
#' @export

check_distinct <- function(ubb, export = FALSE) {
  # Ensure 'ubb' is logical
  if (!is.logical(ubb)) {
    stop("'ubb' must be a logical value (TRUE or FALSE).")
  }

  # Load the raw data
  meta_raw <- DB_Table("metadata_raw")
  #meta_raw <- DB_Table("all_mastertemplates")

  # Add the 'ubb' column based on the 'template' column
  meta_raw$survey <- stringr::str_detect(meta_raw$template, pattern = "_ubb_")


  check_df <- meta_raw |>
    dplyr::filter(survey == ubb)

  check_df$text <- remove_and_combine(input_vector = check_df$text)

  # Define column names using `sym()` for tidy evaluation
  #variable_col <- rlang::sym("variable")
  #text_col <- rlang::sym("text")


  # # Check for duplicates within 'variable' and 'text' using `add_count()`
  # check <- check_df |>
  #   dplyr::select(!!variable_col, !!text_col) |>
  #   dplyr::arrange(!!variable_col) |>
  #   dplyr::distinct() |>
  #   dplyr::group_by(!!variable_col) |>
  #   dplyr::mutate(n = dplyr::n()) |>
  #   #dplyr::add_count(name = "n") |>
  #   dplyr::filter(n > 1)

  #Old version
  check <- check_df |>
    dplyr::select(variable, text) |>
    dplyr::arrange(variable) |>
    dplyr::distinct() |>
    dplyr::group_by(variable) |>
    dplyr::mutate(n = dplyr::n()) |>
    dplyr::filter(n > 1)

  # Output results to the console
  if (nrow(check) == 0) {
    cli::cli_alert_success("All distinct, great!")
  } else {
    cli::cli_alert_danger("Thou shalt not pass! Please check these duplicates:")
    print(check)
  }

  # If export is TRUE, save the results to an Excel file
  if (export) {
    output_file <- paste0("distinct_", format(Sys.Date(), "%Y_%m_%d"), ".xlsx")
    writexl::write_xlsx(check, output_file)
    cli::cli_alert_info(paste("Results have been exported to:", output_file))
  }


}




#' Check Master Templates
#'
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @export

check_MasterTemplates <- function() {
  #allMasters <- get_MasterTemplate()
  #Masters_LimeSurvey <- allMasters$surveyls_title
  #Masters_LimeSurvey

  Masters_LimeSurvey <- LS_GetMasterTemplates(template = FALSE)
  Masters_LimeSurvey <- Masters_LimeSurvey$surveyls_title

  df <- DB_Table("master_to_template")
  Masters_Template <- df$surveyls_title
  Masters_Template

  LimeMastersOnly <- dplyr::setdiff(Masters_LimeSurvey, Masters_Template)
  checkL <- rlang::is_empty(LimeMastersOnly)

  TemplateMastersOnly <- dplyr::setdiff(Masters_Template, Masters_LimeSurvey)
  checkT <- rlang::is_empty(TemplateMastersOnly)


  template_list <- list("From LimeSurvey" = LimeMastersOnly,
                        "From Template" = TemplateMastersOnly)

  check <- c(checkL, checkT)

  if (all(check) == TRUE) {
    cli::cli_alert_success("All Masters templates found in LimeSurvey (et vice versa).")
  }else {
    cli::cli_alert_danger("Thou shalt not pass! Some templates are NOT available in Limesurvey or in the template file. Please check:")
    return(template_list)
  }
}



#' Check Survey Templates
#'
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @export

check_SurveyTemplates <- function() {
  # #df <- MetaMaster::MasterToTemplates
  # df <- DB_Table("master_to_template")
  # MastersTemplates <- df$template
  #
  # report_meta <- readxl::read_excel(here::here("data/report_meta_dev.xlsx"),
  #                                   sheet = "templates") |>
  #   dplyr::select(surveys)
  #
  # surveys <- report_meta$surveys

  df <- DB_Table("master_to_template")
  MastersTemplates <- df$template

  # MetaMasterMeta <- readxl::read_excel(here::here("metadata_raw.xlsx")) |>
  #   dplyr::pull(template) |>
  #   unique()

  MetaMasterMeta <- readxl::read_excel("MetaMaster.xlsx",
                                       sheet = "templates") |>
    dplyr::pull(template)

  SurveyDifferences <- dplyr::setdiff(MetaMasterMeta, MastersTemplates)

  if (rlang::is_empty(SurveyDifferences) == TRUE) {
    cli::cli_alert_success("All survey templates found in meta data.")
  }else {
    cli::cli_alert_danger("Thou shalt not pass! These templates are not listed in the template-to-master file:")
    SurveyDifferences
  }
}


#' Check if All Extra Variables are Ploted Distinctly
#'
#' @description There are several extra plots, which means that some variables
#'  of LimeSurvey appear in more than one plot. This function checks how often
#'    the variable appears in a report and if distinct number of plots are used.
#' @export

check_ExtraPlot <- function() {
  cli::cli_alert_info("Let's check if all extra variables are listed the same number of times as they appear in distinct plots.")

  extraplots <- DB_Table("extraplots")
  # For an update
  # extraplots <- get_AllExtraPlots(export = FALSE, filter = FALSE)

  # Count how often each var appears in each report and count distinct plots
  result <- extraplots |>
    dplyr::group_by(report, vars) |>
    dplyr::summarise(
      n = dplyr::n(),
      distinct_plots = dplyr::n_distinct(plot),
      .groups = "drop"
    ) |>
    dplyr::mutate(check = n == distinct_plots) |>
    dplyr::filter(check == FALSE)

  #Check else condition
  #dplyr::filter(report == "Fuck")


  # Check if any issues were found and display appropriate message
  if (nrow(result) > 0) {
    cli::cli_alert_danger("This check found variables that are listed more times than they appear in distinct plots. Please review:")
    purrr::walk(1:nrow(result), function(i) {
      cli::cli_text(glue::glue("Report '{result$report[i]}' and vars '{result$vars[i]}'"))
    })
  } else {
    cli::cli_alert_success("Great, check successfully passed!")
  }
}


#' Consistency Checks for SETS data
#'
#' @description This function runs consistency checks for the SETS data.
#'
#' @export

check_Sets <- function() {
  cli::cli_alert_info("Checking sets data.")

  sets <- DB_Table("sets")
  reports <- DB_Table("reports")

  # Check column names
  check_column_names <- function(sets, rightnames) {
    usednames <- names(sets)
    if (!all(usednames %in% rightnames)) {
      cli::cli_alert_danger("Check column of sets data. It should be: {.val {rightnames}}.")
      return(FALSE)
    }
    return(TRUE)
  }

  # Check for missing values
  check_missing_values <- function(sets) {
    if (sum(is.na(sets)) > 0) {
      cli::cli_alert_danger("There are missing values in the sets data.")
      return(FALSE)
    }
    return(TRUE)
  }

  # Check if all plots have one distinct set
  check_distinct_sets <- function(reports) {
    distinct_sets_check <- reports |>
      dplyr::group_by(report, plot) |>
      dplyr::summarise(distinct_sets = dplyr::n_distinct(sets), .groups = "drop") |>
      dplyr::filter(distinct_sets > 1)

    if (nrow(distinct_sets_check) > 0) {
      cli::cli_alert_danger("Some plots have more than one distinct set. Check: {.val {distinct_sets_check$report}}.")
      return(FALSE)
    }
    return(TRUE)
  }

  # Check if all sets in reports are defined in sets
  check_defined_sets <- function(reports, sets) {
    reportsets <- reports |>
      dplyr::pull(sets) |>
      unique()

    set_unique <- sets$set |>
      unique()

    not_defined_set <- dplyr::setdiff(reportsets, set_unique)

    if (length(not_defined_set) > 0) {
      cli::cli_alert_danger("Some sets are not defined but are listed in the reports data. Check: {.val {not_defined_set}}.")
      return(FALSE)
    }
    return(TRUE)
  }

  # Define the correct column names
  rightnames <- c("set", "code", "labels", "sort", "colors", "text_color", "timestamp")

  # Perform all checks
  is_columns_ok <- check_column_names(sets, rightnames)
  is_missing_vals_ok <- check_missing_values(sets)
  is_distinct_sets_ok <- check_distinct_sets(reports)
  is_sets_defined_ok <- check_defined_sets(reports, sets)

  # Final check: If all tests passed, return success
  if (is_columns_ok & is_missing_vals_ok & is_distinct_sets_ok & is_sets_defined_ok) {
    cli::cli_alert_success("Sets data is correct.")
  }
}


#' Consistency Checks for Header Reports Data
#'
#' @description This function runs consistency checks.
#'
#' @export

check_Headers <- function() {
  cli::cli_alert_info("Checking header reports data.")

  header_reports <- DB_Table("header_reports")

  # Filter data by report type
  header_surveys <- header_reports |> dplyr::filter(report == "Survey")
  header_ubb <- header_reports |> dplyr::filter(report == "UBB") |> dplyr::select(-header2)

  # Initialize a variable to track if there were any issues
  all_checks_passed <- TRUE

  # 1. Check column names
  usednames <- names(header_reports)
  rightnames <- c("sort", "plot", "header1", "header2", "timestamp", "report")
  #check error
  #rightnames <- c("sort", "plot", "header1", "header2", "timestamp", "reporta")
  check_names <- all(usednames %in% rightnames)

  if (!check_names) {
    cli::cli_alert_danger("Check column of header_reports data. It should be: {.val {rightnames}}.")
    all_checks_passed <- FALSE
  }

  # 2. Check for missing values in surveys and UBB
  check_missing_values <- function(data, label) {
    if (sum(is.na(data)) > 0) {
      cli::cli_alert_danger("There are missing values in the {.val {label}} data.")
      all_checks_passed <<- FALSE # Update the global flag if there's an issue
    }
  }

  #Error checks
  #header_surveys$header1[1] <- NA
  check_missing_values(header_surveys, "Survey")
  check_missing_values(header_ubb, "UBB")

  # 3. Check for duplicate plot names in surveys and UBB
  check_duplicates <- function(data, label) {
    if (any(duplicated(data$plot))) {
      cli::cli_alert_danger("There are duplicated plot names in the {.val {label}} data.")
      all_checks_passed <<- FALSE # Update the global flag if there's an issue
    }
  }
  #Error checks
  #header_surveys$plot[1] <- "A12"
  check_duplicates(header_surveys, "Survey")
  check_duplicates(header_ubb, "UBB")

  # 4. Check if all header plots are defined in reports
  reports <- DB_Table("reports")
  all_plots <- unique(reports$plot)
  plots_header <- header_reports$plot

  #Error checks
  #plots_header[2] <- "Funky Name"

  check_headers <- dplyr::setdiff(plots_header, all_plots)

  if (length(check_headers) > 0) {
    cli::cli_alert_danger("Some headers are not in the reports data. Check: {.val {check_headers}}.")
    all_checks_passed <<- FALSE # Update the global flag if there's an issue
  }

  # 5. Check sorting in surveys
  check_sorting <- function(data, label) {
    sorted_values <- data |> dplyr::arrange(sort) |> dplyr::pull(sort)
    is_sequence <- sorted_values == seq(min(data$sort), max(data$sort))

    if (!all(is_sequence)) {
      cli::cli_alert_danger("The {.val {label}} data is not sorted correctly.")
      all_checks_passed <<- FALSE # Update the global flag if there's an issue
    }
  }

  #Error checks
  #header_surveys$sort[2] <- 1
  check_sorting(header_surveys, "Survey")
  check_sorting(header_ubb, "UBB")

  # Success?
  if (all_checks_passed) {
    cli::cli_alert_success("The header_reports data looks awesome!")
  }

}


utils::globalVariables(c("survey", "text", "n", "template"))

