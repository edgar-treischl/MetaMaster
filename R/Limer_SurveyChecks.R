
#' Check if All Variables of the Meta Data are Distinct
#' @description This function checks if all variables names of the meta data
#'  are distinct. It counts if a variable name is used more than once and returns
#'    a data frame with the results.
#'@examples
#'\dontrun{
#' check_distinct(ubb = TRUE)
#'}
#' @export


check_distinct <- function(ubb) {
  cli::cli_abort("This function is not ready yet. Adjust paths!")
  #We have a raw data set
  meta_raw <- readxl::read_excel(here::here("data/meta_raw.xlsx"))


  #We need to check for each template within the raw data set if there are any duplicates
  meta_raw$ubb <- stringr::str_detect(meta_raw$template, pattern = "_ubb_")

  #Check for duplicates
  if (ubb == TRUE) {
    check_df <- meta_raw |>
      dplyr::filter(ubb == TRUE)

  }else {
    check_df <- meta_raw |>
      dplyr::filter(ubb == FALSE)
  }

  check <- check_df |> dplyr::select(variable, text) |>
    dplyr::arrange(variable) |>
    dplyr::distinct() |>
    dplyr::group_by(variable) |>
    dplyr::mutate(n = dplyr::n()) |>
    dplyr::filter(n > 1)

  if (nrow(check) == 0) {
    cli::cli_alert_success("All distinct, great!")
  }else {
    cli::cli_alert_danger("Thou shalt not pass! Please check if these buggers:")
    return(check)
  }






  #Export this file as excel
  #writexl::write_xlsx(check, "data/checkoverallUBB.xlsx")
}

#check_limeMeta(ubb = TRUE)



#' Get the templates
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#'@examples
#' check_MasterTemplates()
#' @export



check_MasterTemplates <- function() {
  allMasters <- get_MasterTemplate()
  Masters_LimeSurvey <- allMasters$surveyls_title
  Masters_LimeSurvey

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

#check_mastertemplates()

# From Gisla To Master
#' Get the templates
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @export


check_SurveyTemplates <- function() {
  #df <- MetaMaster::MasterToTemplates
  df <- DB_Table("master_to_template")
  MastersTemplates <- df$template

  report_meta <- readxl::read_excel(here::here("data/report_meta_dev.xlsx"),
                                    sheet = "templates") |>
    dplyr::select(surveys)

  surveys <- report_meta$surveys

  SurveyDifferences <- dplyr::setdiff(surveys, MastersTemplates)

  if (rlang::is_empty(SurveyDifferences) == TRUE) {
    cli::cli_alert_success("All templates found template-to-master file.")
  }else {
    cli::cli_alert_danger("Thou shalt not pass! These templates are not listed in the template-to-master file:")
    SurveyDifferences
  }
}

#check_templates()


