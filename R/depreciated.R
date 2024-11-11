# get_AllMasterMeta <- function(export = FALSE) {
#
#   mastertemplatesdf <- get_MasterTemplate()
#
#   sids <- mastertemplatesdf$sid
#   master_names <- mastertemplatesdf$surveyls_title
#
#
#
#
#   metalist <- purrr::map2(sids,
#                           master_names,
#                           get_MasterMeta, .progress = TRUE)
#
#
#   MasterMetaList <- metalist |>  dplyr::bind_rows()
#
#
#   if (export == TRUE) {
#     writexl::write_xlsx(MasterMetaList, here::here("data/meta_raw.xlsx"))
#     cli::cli_alert_success("RAW Master Data Exported")
#   }else {
#     #cli::cli_progress_done()
#     return(MasterMetaList)
#   }
#
# }

# get_metalist <- function() {
#   #Read master data
#   mastertemplate <- readxl::read_excel(here::here("data/Edgar_master_to_template.xlsx"))
#   mastertemplate <- mastertemplate |> dplyr::select(4:6)
#
#   templates_unique <- unique(mastertemplate$template)
#
#
#   #Create a stringified version of the template names
#   fromString <- as.data.frame(stringr::str_split_fixed(templates_unique,
#                                                        pattern = "_",
#                                                        n = 8))
#
#   #bring survey type back together
#   fromString$sart <- paste0(fromString$V3, "_", fromString$V4)
#   fromString$sart <- stringr::str_replace_all(fromString$sart,
#                                               pattern = "allg_",
#                                               replacement = "")
#
#   #Select the relevant columns
#   stringified <- fromString |>
#     dplyr::select(ubb = V2,
#                   stype = sart,
#                   type = V5,
#                   ganztag = V8)
#
#   #Add template
#   stringified$template <- templates_unique
#
#   #Replace the strings with the correct values
#   stringified$ganztag <- stringr::str_replace_all(stringified$ganztag, pattern = "p1",
#                                                   replacement = "FALSE")
#   stringified$ganztag <- stringr::str_replace_all(stringified$ganztag, pattern = "p2",
#                                                   replacement = "TRUE")
#
#   #Some for UBB
#   stringified$ubb <- stringr::str_replace_all(stringified$ubb, pattern = "bfr",
#                                               replacement = "FALSE")
#
#   stringified$ubb <- stringr::str_replace_all(stringified$ubb, pattern = "ubb",
#                                               replacement = "TRUE")
#
#
#   #Some Gisla checks
#   # surveyls_title <- stringified$surveyls_title
#   # report_meta_dev <- readxl::read_excel("data/report_meta_dev.xlsx", na = "NA")
#   # report_meta_dev <- na.omit(report_meta_dev)
#   # giselasurvey <- report_meta_dev |>
#   #   dplyr::pull(surveys)
#   #
#   # dplyr::setdiff(giselasurvey, surveyls_title)
#   # dplyr::setdiff(surveyls_title, giselasurvey)
#
#   #Join the stringified data to the master data
#   mastertemplate <- mastertemplate |>
#     dplyr::left_join(stringified, by = "template") |>
#     dplyr::rename(master = surveyls_title) |>
#     dplyr::arrange(master)
#
#
#
#   return(mastertemplate)
# }


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


# get_MasterTemplate <- function(sart = NULL) {
#
#   #Get specs from config
#   get <- config::get()
#   tmp.server <- get$tmp.server
#   tmp.user <- get$tmp.user
#   tmp.credential <- get$tmp.credential
#   #Connect
#   tmp.session <- surveyConnectLs(user = tmp.user,
#                                  credential = tmp.credential,
#                                  server = tmp.server)
#
#
#   allsurveys <- call_limer(method = "list_surveys")
#
#   release_session_key()
#
#   if (missing(sart) == FALSE) {
#     allsurveys$sart <- stringr::str_detect(allsurveys$surveyls_title,
#                                            pattern = paste0("_", sart, "_"))
#
#     allsurveys <- allsurveys |> dplyr::filter(sart == TRUE)
#
#   }
#
#   allsurveys$master <- stringr::str_detect(allsurveys$surveyls_title, pattern = "master_")
#
#
#   mastertemplates <- allsurveys |>
#     dplyr::filter(master == TRUE) |>
#     dplyr::select(sid, surveyls_title) |>
#     dplyr::arrange(surveyls_title)
#
#   df <- tibble::as_tibble(mastertemplates)
#   return(df)
# }


# get_TemplateDF <- function(mastername) {
#
#   allMasters <- readxl::read_excel(here::here("data/allMastersLimeSurvey.xlsx"))
#
#   MasterID <- allMasters |>
#     dplyr::filter(surveyls_title == mastername) |>
#     dplyr::pull(sid)
#
#
#   master01 <- get_MasterMeta(id = MasterID,
#                              name = mastername)
#
#
#   #rename columns variable to vars
#   master01 <- master01 |> dplyr::rename(vars = variable)
#   master01
# }


# joinMetaGisela <- function(templatename,
#                            mastername,
#                            mistakes = TRUE,
#                            update = FALSE) {
#   gisela_report <- gisela_report(template = templatename)
#   master <- get_TemplateDF(mastername = mastername)
#
#   report_template <- gisela_report$reporttemplate
#   report <- gisela_report$report
#
#   #match master with report by variable: vars
#   master_universe <- master |> dplyr::left_join(report,
#                                                 by = "vars")
#
#   #Stefan fragen`?`
#   # dplyr::setdiff(master$vars, report$vars)
#   # dplyr::setdiff(report$vars, master$vars)
#
#   # master_universe <- master |> dplyr::left_join(report,
#   #                                                 by = "vars",
#   #                                                 relationship = "one-to-one",
#   #                                                 unmatched = "error")
#
#   if (nrow(master_universe) == 0) {
#     cli::cli_abort("No matching variables between master and report")
#   }
#
#   if (mistakes == TRUE) {
#     master_universe <- master_universe |> dplyr::filter(is.na(report) == TRUE)
#
#     if (nrow(master_universe) > 0) {
#       excel_name <- dplyr::setdiff(report$vars, master$vars)
#       master_universe$report <- report_template
#       if (length(master_universe$vars) == length(excel_name)) {
#         master_universe$excel_name <- excel_name
#
#       }
#     }
#
#   }
#
#
#
#
#
#   master_universe$surveytemplate <- templatename
#   #master_universe |> dplyr::select(surveyID, template, vars, plot, report, surveytemplate)
#
#   return(master_universe)
#
# }



# gisela_report <- function(template) {
#   report_meta_dev <- readxl::read_excel("data/report_meta_dev.xlsx")
#
#   report_template <- report_meta_dev |>
#     dplyr::filter(surveys == template) |>
#     dplyr::pull(report_tmpl)
#
#   report_meta_rep <- readxl::read_excel("data/report_meta_dev.xlsx",
#                                         sheet = "reports")
#
#
#
#
#   reportdf <- report_meta_rep |>
#     dplyr::filter(report == report_template) |>
#     dplyr::select(-label)
#
#   gisela_report <- list("reporttemplate" = report_template,
#                         "report" = reportdf)
#
#   return(gisela_report)
# }



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

