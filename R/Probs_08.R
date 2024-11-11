# library(MetaMaster)
# library(tidyverse)
#
# Sys.setenv(R_CONFIG_ACTIVE = "default")
#
# allMasters <- get_MasterTemplate()
# allMasters |> print(n=39)
#
# # #
# master <- get_MasterMeta(id = "943467",
#                name = "master_02_bfr_allg_gm_elt_01_2022_v4")
#
#
# View(master)
#
# #
# #
# #
# #
# # # master01 <- get_MasterMeta(id = "513353",
# # #                            name = "master_29_ubb_allg_gm_eva_00_2022_v4")
# #
# #
# # #Get specs from config
# # get <- config::get()
# # tmp.server <- get$tmp.server
# # tmp.user <- get$tmp.user
# # tmp.credential <- get$tmp.credential
# # #Connect
# # tmp.session <- surveyConnectLs(user = tmp.user,
# #                                credential = tmp.credential,
# #                                server = tmp.server)
# #
# # # fucktemplates <- c("master_07_bfr_allg_gs_sus_00_2022_v4",
# # #                    "master_08_bfr_allg_gs_sus_02_2022_v4",
# # #                    "master_28_bfr_zspf_fz_sus_05_2022_v4")
# #
# # #Master01: Befragung 197865
# # #Master08: 956526
# # #Master29: 513353
# # lslist <- call_limer(method = "list_questions",
# #                      params = list(iSurveyID = "478917"))
# #
# #
# #
# #
# # release_session_key()
# #
# #
# # View(lslist)
# #
# # name <- "master_08_bfr_allg_gs_sus_02_2022_v4"
# # name <- "master_29_ubb_allg_gm_eva_00_2022_v4"
# #
# #
# # stringr::str_detect(name, pattern = "_ubb_")
# #
# #
# # lslist$str_length <- stringr::str_length(lslist$question)
# #
# #
# # lslist$title
# #
# # nmvars <- lslist |>
# #   dplyr::filter(type != "T") |>
# #   dplyr::arrange(title) |>
# #   dplyr::pull(title)
# #
# # titles <- stringr::str_sub(nmvars, 4)
# #
# # lslist |>
# #   dplyr::filter(str_length != 0) |>
# #   dplyr::arrange(title) |>
# #   dplyr::pull(title)
# #
# #
# #
# #
# #
# # questions <- lslist$question
# #
# # q1 <- rvest::minimal_html(questions[1]) |>
# #   rvest::html_elements("span") |>
# #   rvest::html_elements("b") |>
# #   rvest::html_text2()
# #
# # questions_rest <- questions[-1]
# #
# # #q_rest <- map_html(questions_rest)
# #
# # q_rest <- purrr::map(questions_rest, extract_html) |>
# #   purrr::flatten_chr()
# #
# # questions <- c(q1, q_rest)
# #
# #
# #
# #
# #
