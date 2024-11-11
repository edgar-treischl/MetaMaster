# library(readxl)
# df <- readxl::read_excel("TestRun_2024_11_02.xlsx")
#
#
# # string <- df$surveytemplate[3522]
# # string <- df$surveytemplate[1]
#
# fromString <- as.data.frame(stringr::str_split_fixed(df$surveytemplate,
#                                                      pattern = "_",
#                                                      n = 8))
#
# #bring survey type back together
# fromString$sart <- paste0(fromString$V3, "_", fromString$V4)
# fromString$sart <- stringr::str_replace_all(fromString$sart,
#                                             pattern = "allg_",
#                                             replacement = "")
#
# #Select the relevant columns
# stringified <- fromString |>
#   dplyr::select(ubb = V2,
#                 stype = sart,
#                 type = V5,
#                 ganztag = V8)
#
# #Replace the strings with the correct values
# stringified$ganztag <- stringr::str_replace_all(stringified$ganztag, pattern = "p1",
#                                                 replacement = "FALSE")
# stringified$ganztag <- stringr::str_replace_all(stringified$ganztag, pattern = "p2",
#                                                 replacement = "TRUE")
#
#
# #Some for UBB
# stringified$ubb <- stringr::str_replace_all(stringified$ubb, pattern = "bfr",
#                                             replacement = "FALSE")
#
# stringified$ubb <- stringr::str_replace_all(stringified$ubb, pattern = "ubb",
#                                             replacement = "TRUE")
#
# stringified$type <- stringr::str_replace_all(stringified$type, pattern = "eva",
#                                             replacement = "ubb")
#
#
#
# stringified$surveytemplate <- df$surveytemplate
#
#
#
#
# mastertemplate <- df |>
#   dplyr::left_join(stringified, by = "surveytemplate",
#                    relationship = "many-to-many")
#
#
#
#
# #01templates#############
#
# varlist <- c("surveyID", "template", "report", "surveytemplate", "ubb", "stype", "type", "ganztag")
#
# templates <- mastertemplate |>
#   dplyr::select(dplyr::all_of(varlist)) |>
#   dplyr::distinct()
#
#
# #02reports#############
#
# varlist <- c("report", "vars", "text", "plot", "label_short")
#
# reports <- mastertemplate |>
#   dplyr::select(dplyr::all_of(varlist)) |>
#   dplyr::group_by(report) |>
#   dplyr::distinct() |>
#   dplyr::ungroup()
#
#
#
#
#
#
# #03set data#############
#
# # set_data <- readxl::read_excel("data/report_meta_dev.xlsx",
# #                               sheet = "set_data")
# #
# #
# # set_data <- set_data |> dplyr::select(1:2)
# #
# # checkna <- sum(is.na(set_data))
# # check <- duplicated(set_data$plot)
#
#
#
# #03sets#############
#
# # sets <- readxl::read_excel("data/report_meta_dev.xlsx",
# #                                sheet = "sets")
# #
# #
# # check_sets <- sets$set |> unique()
# #
# #
# # dplyr::setdiff(set_data$set, check_sets)
#
#
# #04plots_headers#############
#
# plots_headers <- readxl::read_excel("data/report_meta_dev.xlsx",
#                            sheet = "plots_headers")
#
#
#
#
#
#
#
#
# #Check plot in allplots
#
#
# #05plots_headers_ubb#############
#
# headers_ubb <- readxl::read_excel("data/report_meta_dev.xlsx",
#                                   sheet = "plots_headers_ubb")
#
#
#
#
#
#
#
# library(MetaMaster)
#
#
#
#
#
# # plots_headers <- DBTable(table = "plots_headers")
# # plots_headers_ubb <- DBTable(table = "plots_headers_ubb")
# # reports <- DBTable(table = "reports")
# # set_data <- DBTable(table = "set_data")
# # sets <- DBTable(table = "sets")
# # templates <- DBTable(table = "templates")
# #extraplots <- DBTable(table = "extraplots")
#
#
# #export two data sets in one excel file
# writexl::write_xlsx(list(templates = templates,
#                          reports = reports,
#                          set_data = set_data,
#                          sets = sets,
#                          plots_headers = plots_headers,
#                          headers_ubb = headers_ubb,
#                          extra_plots = extraplots),
#                     path = "data/MetaMasterMeta.xlsx")
#
#
# txts <- unique(reports$text)
#
# dataframe <- data.frame(limesurveytxt = txts)
#
# #write to excel file
# writexl::write_xlsx(txts, path = "data/texts.xlsx")
#
#
#
#
# #Give me some rules to shorten your strings#####################################
#
# teststring <- "Schülerinnen und Schüler haben bei uns viele Möglichkeiten Verantwortung zu übernehmen (z. B. Mentoren, Projekte in Schülerverantwortung, Streitschlichter)."
#
# teststringshort <- stringr::str_replace_all(teststring, pattern = "Schülerinnen und Schüler",
#                                        replacement = "SuS")
#
#
# teststringshort <- stringr::str_remove_all(teststringshort, "\\s*\\([^\\)]*\\)")
#
# teststring
# teststringshort
#
#
#
# stringr::str_replace_all(teststring, pattern = "Ausbilderinnen und Ausbilder",
#                          replacement = "Ausbildungspartner")
#
# stringr::str_replace_all(teststring, pattern = "Lehrinnen und Lehrer",
#                          replacement = "Lehrkräfte")
#
# stringr::str_replace_all(teststring, pattern = "Schulleitung",
#                          replacement = "SL")
#
# stringr::str_replace_all(teststring, pattern = "Schulpersonal",
#                          replacement = "Personal")
#
#
# stringr::str_replace_all(teststring, pattern = "Lehrerkonferenzen bzw. Teamkonferenzen",
#                          replacement = "Lehrer-/Teamkonferenzen")
#
#
# stringr::str_length(teststring)
#
#
#
#
#
