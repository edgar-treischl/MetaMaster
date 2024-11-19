















#Delete next round

# get_MasterMeta <- function(id, name) {
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
#   fucktemplates <- c("master_08_bfr_allg_gs_sus_02_2022_v4",
#                      "master_07_bfr_allg_gs_sus_00_2022_v4",
#                      "master_28_bfr_zspf_fz_sus_05_2022_v4",
#                      "master_37_bfr_allg_gs_sus_00_2022_v4",
#                      "master_38_bfr_zspf_fz_sus_05_2022_v4",
#                      "master_bfr_zspf_fz_sus_05_2022_v0")
#
#
#   lslist <- call_limer(method = "list_questions",
#                        params = list(iSurveyID = id))
#
#   release_session_key()
#
#   if (rlang::is_empty(lslist$status) == FALSE) {
#     problem <- paste0("Error in get_MasterMeta(): ", lslist$status)
#     cli::cli_abort(problem)
#   }
#
#   # if (purrr::is_empty(titles) == TRUE) {
#   #   cli::cli_abort("No questions found in survey.")
#   # }
#
#
#   if (name %in% fucktemplates == TRUE) {
#     varname <- lslist$title
#     plot <- substr(varname, 1, 3)
#     varname <- substr(varname, 4, nchar(varname))
#
#
#     #cli::cli_abort("Fuck.")
#   }else {
#     df <- lslist |>
#       dplyr::select(parent_qid, title)
#
#
#     # Step 1: Extract plot titles (where parent_qid == 0)
#
#     titles <- df |>
#       dplyr::filter(parent_qid == 0) |>
#       dplyr::mutate(row_number = dense_rank(title)) |>
#       dplyr::select(row_number, plot = title, parent = parent_qid)
#
#
#     var_titles <- df |>
#       dplyr::filter(parent_qid != 0) |>
#       dplyr::mutate(row_number = dense_rank(parent_qid)) |>
#       dplyr::select(row_number, title, parentV = parent_qid)
#
#
#     #Left join the two dataframes on row_number
#     matched_variables <- titles |>
#       dplyr::left_join(var_titles, by = "row_number")
#
#
#     plot <- matched_variables$plot
#     varname <- matched_variables$title
#
#
#     #OLD approach
#     # new_title <- df |>
#     #   dplyr::mutate(new_title = ifelse(parent_qid == 0, title, NA)) |>
#     #   tidyr::fill(new_title) |>
#     #   dplyr::mutate(new_title = ifelse(parent_qid == 0, new_title, paste0(new_title, title))) |>
#     #   dplyr::select(parent_qid, title = new_title) |>
#     #   dplyr::pull(title)
#     #
#     #
#     # lslist$title <- new_title
#     #
#     #
#     #
#     # titles <- lslist |>
#     #   dplyr::filter(parent_qid != 0) |>
#     #   #dplyr::filter(parent_qid != 0) |>
#     #   dplyr::pull(title)
#     #
#     # #The first four characters
#     # plot <- substr(titles, 1, 3)
#     #
#     # #The rest of the string
#     # varname <- substr(titles, 4, nchar(titles))
#   }
#
#
#   if (name %in% fucktemplates == TRUE) {
#     questions <- "lslist$question"
#
#     q1 <- rvest::minimal_html(questions[1]) |>
#       rvest::html_elements("span") |>
#       rvest::html_elements("b") |>
#       rvest::html_text2()
#
#     questions_rest <- questions[-1]
#
#     q_rest <- purrr::map(questions_rest, extract_html) |>
#       purrr::flatten_chr()
#
#     q_rest <- q_rest[q_rest != " "]
#
#     questions <- c(q1, q_rest)
#     questions <- stringr::str_trim(questions)
#
#     if (length(questions) != length(lslist$question)) {
#       questions <- "Error: Questions not extracted correctly"
#     }
#
#
#   }else {
#     questions <- lslist |>
#       dplyr::filter(parent_qid != "0") |>
#       dplyr::pull(question)
#
#     questions <- stringr::str_trim(questions)
#   }
#
#   #stringr::str_detect(name, pattern = "_ubb_")
#   #lslist$str_length <- stringr::str_length(lslist$question)
#
#
#
#
#
#   template <- tibble::tibble(surveyID = id,
#                              template = name,
#                              plot = plot,
#                              variable = varname,
#                              text = questions)
#
#   return(template)
# }






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



