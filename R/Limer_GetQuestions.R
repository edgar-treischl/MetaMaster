#' Get master templates from LimeSurvey
#'
#' @description This function gets the master templates from Lime Survey.
#' @param sart School type.
#' @return Results from the API.
#' @examples \dontrun{
#' get_MasterTemplate(sart = "gs")
#' }
#' @export

get_MasterTemplate <- function(sart = NULL) {

  #Get specs from config
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential
  #Connect
  tmp.session <- surveyConnectLs(user = tmp.user,
                                 credential = tmp.credential,
                                 server = tmp.server)


  allsurveys <- call_limer(method = "list_surveys")

  release_session_key()

  if (missing(sart) == FALSE) {
    allsurveys$sart <- stringr::str_detect(allsurveys$surveyls_title,
                                           pattern = paste0("_", sart, "_"))

    allsurveys <- allsurveys |> dplyr::filter(sart == TRUE)

  }

  allsurveys$master <- stringr::str_detect(allsurveys$surveyls_title, pattern = "master_")


  mastertemplates <- allsurveys |>
    dplyr::filter(master == TRUE) |>
    dplyr::select(sid, surveyls_title) |>
    dplyr::arrange(surveyls_title)

  df <- tibble::as_tibble(mastertemplates)
  return(df)
}



#' Get meta data from LimeSurvey master templates.
#'
#' @description This function gets the meta data from LimeSurvey master templates.
#' @param id Survey ID.
#' @param name Survey name (surveyls_title).
#' @return Results from the API.
#' @examples \dontrun{
#' get_MasterMeta()
#' }
#' @export


get_MasterMeta <- function(id, name) {

  #Get specs from config
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential
  #Connect
  tmp.session <- surveyConnectLs(user = tmp.user,
                                 credential = tmp.credential,
                                 server = tmp.server)

  fucktemplates <- c("master_08_bfr_allg_gs_sus_02_2022_v4",
                     "master_07_bfr_allg_gs_sus_00_2022_v4",
                     "master_28_bfr_zspf_fz_sus_05_2022_v4",
                     "master_37_bfr_allg_gs_sus_00_2022_v4",
                     "master_38_bfr_zspf_fz_sus_05_2022_v4",
                     "master_bfr_zspf_fz_sus_05_2022_v0")


  lslist <- call_limer(method = "list_questions",
                       params = list(iSurveyID = id))

  release_session_key()

  if (rlang::is_empty(lslist$status) == FALSE) {
    problem <- paste0("Error in get_MasterMeta(): ", lslist$status)
    cli::cli_abort(problem)
  }

  # if (purrr::is_empty(titles) == TRUE) {
  #   cli::cli_abort("No questions found in survey.")
  # }


  if (name %in% fucktemplates == TRUE) {
    varname <- lslist$title
    plot <- substr(varname, 1, 3)
    varname <- substr(varname, 4, nchar(varname))


    #cli::cli_abort("Fuck.")
  }else {
    df <- lslist |>
      dplyr::select(parent_qid, title)


    # Create the new_title column using dplyr and tidyr
    new_title <- df |>
      dplyr::mutate(new_title = ifelse(parent_qid == 0, title, NA)) |>
      tidyr::fill(new_title) |>
      dplyr::mutate(new_title = ifelse(parent_qid == 0, new_title, paste0(new_title, title))) |>
      dplyr::select(parent_qid, title = new_title) |>
      dplyr::pull(title)


    lslist$title <- new_title



    titles <- lslist |>
      dplyr::filter(parent_qid != 0) |>
      #dplyr::filter(parent_qid != 0) |>
      dplyr::pull(title)

    #The first four characters
    plot <- substr(titles, 1, 3)

    #The rest of the string
    varname <- substr(titles, 4, nchar(titles))
  }


  if (name %in% fucktemplates == TRUE) {
    questions <- "lslist$question"

    q1 <- rvest::minimal_html(questions[1]) |>
      rvest::html_elements("span") |>
      rvest::html_elements("b") |>
      rvest::html_text2()

    questions_rest <- questions[-1]

    q_rest <- purrr::map(questions_rest, extract_html) |>
      purrr::flatten_chr()

    q_rest <- q_rest[q_rest != " "]

    questions <- c(q1, q_rest)
    questions <- stringr::str_trim(questions)

    if (length(questions) != length(lslist$question)) {
      questions <- "Error: Questions not extracted correctly"
    }


  }else {
    questions <- lslist |>
      dplyr::filter(parent_qid != "0") |>
      dplyr::pull(question)

    questions <- stringr::str_trim(questions)
  }

  #stringr::str_detect(name, pattern = "_ubb_")
  #lslist$str_length <- stringr::str_length(lslist$question)





  template <- tibble::tibble(surveyID = id,
                             template = name,
                             plot = plot,
                             variable = varname,
                             text = questions)

  return(template)
}


#' Get ALL meta data from LimeSurvey master templates.
#'
#' @description This function gets the meta data from LimeSurvey master templates.
#' @param export Export the data to an Excel file.
#' @return Results from the API.
#' @examples \dontrun{
#' get_AllMasterMeta(export = FALSE)
#' }
#' @export


get_AllMasterMeta <- function(export = FALSE) {

  mastertemplatesdf <- get_MasterTemplate()

  sids <- mastertemplatesdf$sid
  master_names <- mastertemplatesdf$surveyls_title




  metalist <- purrr::map2(sids,
                          master_names,
                          get_MasterMeta, .progress = TRUE)


  MasterMetaList <- metalist |>  dplyr::bind_rows()


  if (export == TRUE) {
    writexl::write_xlsx(MasterMetaList, here::here("data/meta_raw.xlsx"))
    cli::cli_alert_success("RAW Master Data Exported")
  }else {
    #cli::cli_progress_done()
    return(MasterMetaList)
  }

}










#Start here##############

#' Split template string.
#'
#' @description This function splits the template text string from LimeSurvey.
#' @param variables Variables.
#' @return Text string.

# splitTemplateString <- function(variables) {
#
#   MasterMetaList <- readxl::read_excel(here::here("data/meta_raw.xlsx"))
#
#   templates_unique <- unique(MasterMetaList$template)
#
#
#   fromString <- as.data.frame(stringr::str_split_fixed(templates_unique, pattern = "_", n = 9))
#
#
#   stringified <- fromString |>
#     dplyr::select(master = V2,
#                   survey = V3,
#                   type = V4,
#                   sart = V5,
#                   audience = V6,
#                   gnztag = V7,
#                   year = V8,
#                   version = V9)
#
#
#   stringified$template <- templates_unique
#   stringified
#
#   MasterMetaList <- MasterMetaList |>
#     dplyr::left_join(stringified, by = "template")
#
#   return(MasterMetaList)
# }


#' Get report templates.
#'
#' @description This function gets the master templates.
#' @param reports Reports as vector.
#' @examples \dontrun{
#' get_ReportTemplates()
#' }

# get_ReportTemplates <- function(reports = FALSE) {
#
#   #Check if a unique report template is in the master list
#   check <- readxl::read_excel(here::here("data/Edgar_master_to_template.xlsx"),
#                               sheet = "pckg_master_tmpl") |>
#     dplyr::select(template = surveyls_title, report_template = report) |>
#     dplyr::pull(report_template) |>
#     unique()
#
#
#   df <- readxl::read_excel(here::here("data/Edgar_master_to_template.xlsx"),
#                              sheet = "Liste master") |>
#     dplyr::select(template = surveyls_title, report_template = report) |>
#     dplyr::arrange(template)
#
#
#   test <- df |>
#     dplyr::pull(report_template) |>
#     unique()
#
#   checkval <- dplyr::setdiff(test, check)
#
#   #stop if not
#   if (length(checkval) > 0) {
#     cli::cli_abort(paste0("The following report templates are not in the master list: ", checkval))
#   }
#
#   if (reports == FALSE) {
#     # reports <- readxl::read_excel(here::here("data/Edgar_master_to_template.xlsx")) |>
#     #   dplyr::select(template = surveyls_title, report_template = report) |>
#     #   dplyr::distinct()
#
#     reports <- df
#
#   }else {
#     reports <- df |>
#       dplyr::pull(report_template) |>
#       unique()
#   }
#
#
#   return(reports)
# }


#' Merge Meta Data with Lime Survey Data
#'
#' @description This function merges the meta data with the Lime Survey data.
#' @param mastertemplate Master Template.
#' @param rpttemplate Report Template.
#' @return Data frame.

# merge_MetaLime <- function(mastertemplate, rpttemplate) {
#
#   reports <- get_ReportTemplates()
#   MasterMetaList <- splitTemplateString()
#
#   #Now merge MasterMetaList with reports
#   MasterMerged <- MasterMetaList |>
#     dplyr::left_join(reports, by = "template", relationship = "many-to-many")
#
#   #return(MasterMerged)
#
#
#   report <- MasterMerged |>
#     dplyr::filter(template == mastertemplate) |>
#     dplyr::filter(report_template == rpttemplate) |>
#     dplyr::select(report_template, variable, var_text) |>
#     dplyr::arrange(variable)
#
#   #return(report)
#   #Giselas Meta Liste
#   report_meta_dev <- readxl::read_excel(here::here("data/report_meta_dev.xlsx"),
#                                         sheet = "reports")
#
#   gisela <- report_meta_dev |>
#     dplyr::filter(report == rpttemplate) |>
#     dplyr::select(variable = vars, plot, label_short, sets, report)
#
#
#   #giselas <- unique(gisela$variable)
#   #dplyr::setdiff(report$variable, giselas)
#   #dplyr::setdiff(giselas, report$variable)
#
#
#   finalrep <- report |>
#     dplyr::left_join(gisela, dplyr::join_by(report_template == report,
#                                             variable == variable))
#
#
#   notmatched <- finalrep |> dplyr::filter(is.na(plot) == TRUE)
#
#   if (nrow(notmatched) == 0) {
#     return(finalrep)
#   }else {
#     cli::cli_alert_danger(paste0("Some variables cannot be matched, check: ", rpttemplate))
#     return(notmatched)
#   }
#
# }






