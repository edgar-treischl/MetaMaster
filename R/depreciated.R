# get_templates <- function() {
#
#   master_to_template <- readxl::read_excel("data/master_to_template.xlsx")
#
#   #master_to_template <- DB_Table("master_to_template")
#
#   templates <- master_to_template |>
#     dplyr::arrange(surveyls_title) |>
#     dplyr::pull(template)
#
#   return(templates)
# }



# get_master <- function(templatename) {
#   master_to_template <- readxl::read_excel("data/master_to_template.xlsx")
#
#   #master_to_template <- DB_Table("master_to_template")
#
#
#   mastername <- master_to_template |>
#     dplyr::filter(template == templatename) |>
#     dplyr::pull(surveyls_title)
#
#
#   return(mastername)
#
# }


# get_masters <- function() {
#
#   templates <- get_templates()
#   allmasters <- purrr::map_chr(templates, get_master)
#
#   list("template" = templates,
#        "master" = allmasters)
#
# }

#mastertemplatesList <- get_masters()





# check_meta <- function(reporttemplate) {
#   meta <- readxl::read_excel(here::here("report_meta_dev.xlsx"),
#                              sheet = "reports")
#
#
#   check <- meta |> dplyr::filter(report == reporttemplate) |>
#     dplyr::select(1:3) |>
#     dplyr::mutate(check = paste0(vars, "_", plot))
#
#
#   check$dupes <- duplicated(check$check)
#
#   check <- check |> dplyr::filter(dupes == TRUE)
#
#
#
#   if (nrow(check) > 0) {
#     cli::cli_inform("Check duplicates:")
#     return(check)
#   }
#
#
#   if (nrow(check) == 0) {
#     meta_vars <- meta |> dplyr::filter(report == sreports[1]) |>
#       dplyr::pull(vars)
#
#     return(meta_vars)
#   }
# }
#
# # meta_vars <- check_meta(reporttemplate = sreports[1])
#
#
#
#
# get_limeVars <- function(limetemp) {
#   #LimeSurvey Template
#   file <- paste0(limetemp, ".lss")
#   limesurvey_master <- xml2::read_xml(here::here(file))
#
#   limesurvey_vars <- xml2::xml_text(xml2::xml_find_all(limesurvey_master, ".//title"))
#
#   #notlisted <- limesurvey_vars[1:15]
#   #Next we drop all strings from limesurvey_vars if they are not in notlisted
#   #limesurvey_vars <- limesurvey_vars[!limesurvey_vars %in% notlisted]
#   return(limesurvey_vars)
# }
#
#
#
# limesurvey_vars <- get_limeVars(limetemp = limesurvey_mname)
#
#

#Stefan
#'
#' #' Alle Master-Umfragen aus Limesurvey abfragen
#' #'
#' #' \code{evaGetSurveyMasters()}Alle Master-Umfragen aus Limesurvey abfragen
#' #'
#' #' @param url url limesurvey-Instanz
#' #' @param user User
#' #' @param pw Passwort
#' #'
#' evaGetSurveyMasters <- function(url,user,pw){
#'   options(lime_api = url)
#'   options(lime_username = user)
#'   options(lime_password = pw)
#'
#'   tmp.session <- limer::get_session_key()
#'
#'   # Alle Master-Umfragen aus Limesurvey abfragen
#'   tmp.surveys <- limer::call_limer(method = "list_surveys") |>
#'     dplyr::filter(
#'       stringr::str_detect(surveyls_title,"master_")
#'     ) |>
#'     dplyr::mutate(
#'       surveyls_title = stringr::str_trim(surveyls_title)
#'     )
#'   return(tmp.surveys)
#' }
#'
#' #' Keytable Master zu Templates einlesen
#' #'
#' #' \code{evaGetMasterTemplateKeyTab()}Keytable Master zu Templates einlesen
#' #' @details
#' #' Keytable liegt unter orig/master_to_template.xlsx
#' #'
#' #' @param url version Datum aus der Spalte version
#' #'
#' evaGetMasterTemplateKeyTab <- function(version){
#'   # Exceldatei mit Zuordnung von Mastern zu Templates einlesen
#'   tmp.master.tmpl <- readxl::read_excel('orig/master_to_template.xlsx', sheet = 'master_tmpl') |>
#'     dplyr::mutate(
#'       surveyls_title = stringr::str_trim(surveyls_title)
#'     ) |>
#'     dplyr::filter(
#'       as.character(version) == {{version}}
#'     )
#'
#'   test <- identical(
#'     names(tmp.master.tmpl),
#'     c("id", "version", "sart", "pckg", "surveyls_title", "template", "rpt")
#'   )
#'
#'   if(test == F){
#'     cat("Die Spalten in master_to_template.xlsx im Blatt master_tmpl wurden verändert.\nDie Spaltenbezeichnungen müssen:\nid, version, sart, pckg, surveyls_title, template, rpt lauten.")
#'   }
#'
#'   return(tmp.master.tmpl)
#'
#' }
#'
#' #' Matchen der Tempales aus Excel zu Mastern aus Limesurvey
#' #'
#' #' \code{evaJoinSurveyToMasterTemplate()}Matchen der Tempales aus Excel zu Mastern aus Limesurvey
#' #'
#' #' @param surveys Surveytabelle aus Limesurvey aus evaGetSurveyMasters
#' #' @param mastertmp Keytable aus evaGetMasterTemplateKeyTab
#' #'
#' evaJoinSurveyToMasterTemplate <- function(surveys,mastertmp){
#'
#'   # Tabellen nach Master aus Limesurvey und Master aus Excel matchen
#'   tmp.surveys.master.tmpl <- mastertmp |>
#'     dplyr::left_join(
#'       surveys
#'     )
#'
#'   # Prüfen ob Templates doppelt enthalten sind
#'   tmp.master.tmpl.chk <- tmp.master.tmpl |>
#'     dplyr::group_by(
#'       template
#'     ) |>
#'     dplyr::summarise(
#'       ANZ = dplyr::n()
#'     ) |>
#'     dplyr::filter(
#'       ANZ > 1
#'     )
#'
#'   if(nrow(tmp.master.tmpl.chk) > 0){
#'     tmp.master.tmpl.chk |> View()
#'   }
#'
#'   return(tmp.surveys.master.tmpl)
#'
#' }
#'
#' #' Anlegen der Templates in Limesurvey
#' #'
#' #' \code{evaJoinSurveyToMasterTemplate()}Anlegen der Templates in Limesurvey
#' #'
#' #' @param mastertmp Tabelle aus evaJoinSurveyToMasterTemplate
#' #'
#' evaCreateTemplatesInLimesurvey <- function(mastertmp){
#'   # Iterieren über alle Templates
#'   # In Limesurvey Master zu Templates kopieren
#'   for(i in 1:nrow(mastertmp)){
#'     print(
#'       paste0(mastertmp$sid[i], ": ", mastertmp$template[i])
#'     )
#'
#'     tmp.copy.res <- limer::call_limer(
#'       method = "copy_survey",
#'       params = list(
#'         iSurveyID = mastertmp$sid[i],
#'         sNewname = mastertmp$template[i]
#'       )
#'     )
#'   }
#' }
#'
#' # Alle Master-Umfragen aus Limesurvey abfragen
#' # tmp.surveys <- evaGetSurveyMasters(
#' #   'http://www.semiotikon.de/lime2/index.php/admin/remotecontrol',
#' #   'limeremote',
#' #   'IWBD3SnMfxcu'
#' # )
#' #
#' # Keytable Master zu Templates aus
#' #   orig/master_to_template.xlsx
#' # einlesen
#' # tmp.master.tmpl <- evaGetMasterTempaleKeyTab("2024-08-12")
#' #
#' # # Matchen der Tabellen
#' # tmp.surveys.master.tmpl <- evaJoinSurveyToMasterTemplate(tmp.surveys,tmp.master.tmpl)
#' #
#' # # Anlegen der Templates in Limesurvey
#' # evaCreateTemplatesInLimesurvey(tmp.surveys.master.tmpl)
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'

