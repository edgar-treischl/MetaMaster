#' Extract Text from HTML
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @param input HTML code
#' @export
extract_html <- function(input) {
  rvest::minimal_html(input) |>
    rvest::html_elements("p") |>
    rvest::html_elements("b") |>
    rvest::html_text2()
}


#' Update all Masters LimeSurvey
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @export

update_allMastersLimeSurvey <- function() {
  allMasters <- get_MasterTemplate()
  writexl::write_xlsx(allMasters, "data/allMastersLimeSurvey.xlsx")
}

#update_allMastersLimeSurvey()





#' Get individual surveys from Overallreports
#' @description This helper function extracts the individual surveys (parents, kids, etc.)
#'  for the overall reports.
#'
# get_Overallsurveys <- function() {
#   overalltemplate <- readxl:: read_excel(here::here("data/report_meta_dev.xlsx"),
#                                          sheet = "overallreports")
#
#
#   unique_overalls <- overalltemplate |>
#     dplyr::pull(overall) |>
#     unique()
#
#   return(unique_overalls)
#
# }



#' Append overall reports
#' @description This helper function appends the overall reports for one
#'  survey package
#' @param overalls List of indivudal surveys
#' @param data Meta data

#
# append_overall <- function(overalls, data) {
#   overalltemplate <- readxl:: read_excel(here::here("data/report_meta_dev.xlsx"),
#                                          sheet = "overallreports")
#
#
#   # unique_overalls <- overalltemplate |>
#   #   dplyr::pull(overall) |>
#   #   unique()
#
#
#   reports <- overalltemplate |>
#     dplyr::filter(overall == overalls) |>
#     dplyr::pull(reports)
#
#
#   #meta_data <- readxl::read_excel("meta_data.xlsx")
#
#   meta_data <- data
#
#
#   metaoverall <- meta_data |> dplyr::filter(report_template %in% reports) |>
#     dplyr::arrange(variable)
#
#
#   metaoverall$report_template <- overalls
#   return(metaoverall)
# }



#' Get a list with unique meta data
#' @description This function creates a list with unique meta data based on the
#'  input from the Master to template file.
#'
#' @export

get_metalist <- function() {
  #Read master data
  mastertemplate <- readxl::read_excel(here::here("data/Edgar_master_to_template.xlsx"))
  mastertemplate <- mastertemplate |> dplyr::select(4:6)

  templates_unique <- unique(mastertemplate$template)


  #Create a stringified version of the template names
  fromString <- as.data.frame(stringr::str_split_fixed(templates_unique,
                                                       pattern = "_",
                                                       n = 8))

  #bring survey type back together
  fromString$sart <- paste0(fromString$V3, "_", fromString$V4)
  fromString$sart <- stringr::str_replace_all(fromString$sart,
                                              pattern = "allg_",
                                              replacement = "")

  #Select the relevant columns
  stringified <- fromString |>
    dplyr::select(ubb = V2,
                  stype = sart,
                  type = V5,
                  ganztag = V8)

  #Add template
  stringified$template <- templates_unique

  #Replace the strings with the correct values
  stringified$ganztag <- stringr::str_replace_all(stringified$ganztag, pattern = "p1",
                                                  replacement = "FALSE")
  stringified$ganztag <- stringr::str_replace_all(stringified$ganztag, pattern = "p2",
                                                  replacement = "TRUE")

  #Some for UBB
  stringified$ubb <- stringr::str_replace_all(stringified$ubb, pattern = "bfr",
                                              replacement = "FALSE")

  stringified$ubb <- stringr::str_replace_all(stringified$ubb, pattern = "ubb",
                                              replacement = "TRUE")


  #Some Gisla checks
  # surveyls_title <- stringified$surveyls_title
  # report_meta_dev <- readxl::read_excel("data/report_meta_dev.xlsx", na = "NA")
  # report_meta_dev <- na.omit(report_meta_dev)
  # giselasurvey <- report_meta_dev |>
  #   dplyr::pull(surveys)
  #
  # dplyr::setdiff(giselasurvey, surveyls_title)
  # dplyr::setdiff(surveyls_title, giselasurvey)

  #Join the stringified data to the master data
  mastertemplate <- mastertemplate |>
    dplyr::left_join(stringified, by = "template") |>
    dplyr::rename(master = surveyls_title) |>
    dplyr::arrange(master)



  return(mastertemplate)
}


#' Append all overall reports
#' @description This wrapper function appends all overall reports for
#'  the final meta data.
#' @param overalls List of individual reports
#' @param data Meta data
#'
#'
# appendAllOveralls <- function(overalls, data) {
#   #append_overall(overalls = overall_list)
#
#   purrr::map(overalls, append_overall, data = data)
#
# }


#' Add report template
#' @description Bla bla


add_report_template <- function() {
  mastertmp <- MetaMaster::MasterToTemplates

  template <- mastertmp$template


  report_template <- template |>
    stringr::str_replace_all("tmpl_", "rpt_")


  mastertmp$report_template <- report_template
  mastertmp

  #export to excel file

  openxlsx::write.xlsx(mastertmp, here::here("data/master_to_template.xlsx"))

}


#add_report_template()




