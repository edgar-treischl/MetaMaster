
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



utils::globalVariables(c("survey", "text", "n", "template"))

