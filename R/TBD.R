# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")
#
# #build(send_report = TRUE, update = FALSE)
#
#
#
#
# #Länge der Textstrings
# report_meta_dev <- readxl::read_excel("C:/Users/di35haz/Desktop/ISB/eval_report_test/orig/report_meta_dev.xlsx",
#                               sheet = "reports")
#
# report_meta_dev$txtLength <- stringr::str_length(report_meta_dev$label_short)
#
#
#
# summary(report_meta_dev$txtLength)
#
#
#
# #Vergleich der Längen:
#
# MetaMaster <- readxl::read_excel("metadata_raw.xlsx")
#
#
# MetaMaster$txtLength <- stringr::str_length(MetaMaster$text)
#
# summary(MetaMaster$txtLength)
#
#
# long_var_txt <- MetaMaster |>
#   dplyr::filter(txtLength > 78)|>
#   dplyr::select(plot, variable, text) |>
#   unique()
#
#
# MetaMaster$text |> unique()
#
#
#
#
#
#
#
#
# # test <- "Wir lernen: Was ist wichtig, wenn wir digitale Inhalte nutzen und verbreiten?  Digitale Inhalte sind zum Beispiel:  Videos im Internet, Online-Artikel und Posts von anderen."#
# #
# # stringr::str_remove_all(test, "\\s*\\([^\\)]*\\)")
# #
# # stringr::str_remove_all(test, "\\s*\\([^\\)]*\\)")
# reports <- MetaMaster |>
#   dplyr::select(text) |>
#   unique()
#
# all(is.na(reports$text))
#
# reports$text2 <- stringr::str_replace_all(reports$text, "\\.{3}", "...")
#
# all(is.na(reports$text2))
#
#
# #Remove Bla bla (...)
# reports$text2 <- stringr::str_remove_all(reports$text2, "\\s*\\([^\\)]*\\)")
# all(is.na(reports$text2))
#
#
# # Extract the first question, !, or . and remove the rest of the text
# reports$text2 <- stringr::str_extract(reports$text2, "^[^.?!]*[.?!]{0,1}")
# all(is.na(reports$text2))
#
#
#
# # reports$text2 <- stringr::str_replace_all(reports$text2,
# #                                          pattern = "Sch\u00FChlerinnen und Sch\u00F6ler",
# #                                          replacement = "SuS")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Schülerinnen und Schüler",
#                                          replacement = "SuS")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "einer Schülerin oder einem Schüler",
#                                          replacement = "SuS")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "jede Schülerin und jeden Schüler",
#                                          replacement = "alle SuS")
#
#
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Ausbilderinnen und Ausbilder",
#                                          replacement = "Ausbildungspartner")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Lehrinnen und Lehrer",
#                                          replacement = "LK")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Die Lehrerin oder der Lehrer",
#                                          replacement = "Die LK")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "die Lehrerin oder der Lehrer",
#                                          replacement = "die LK")
#
#
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Lehrkräfte",
#                                          replacement = "LK")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Schulleitung",
#                                          replacement = "SL")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Schulpersonal",
#                                          replacement = "Personal")
#
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Lehrerkonferenzen bzw. Teamkonferenzen",
#                                          replacement = "Lehrer-/Teamkonferenzen")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Kolleginnen und Kollegen meiner Schule",
#                                          replacement = "Kolleg/Innen")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Kolleginnen und Kollegen",
#                                          replacement = "Kolleg/Innen")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Mein Sohn/meine Tochter",
#                                          replacement = "Mein/e Sohn/Tochter")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "unseren Sohn/unsere Tochter",
#                                          replacement = "unsere/n Tochter/Sohn")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "unsere Tochter/unseren Sohn",
#                                          replacement = "unsere/n Tochter/Sohn")
#
# reports$text2 <- stringr::str_replace_all(reports$text2,
#                                          pattern = "Meine Klassenlehrerin oder mein Klassenlehrer",
#                                          replacement = "Mein Klassenlehrer")
#
# all(is.na(reports$text2))
#
#
# txt <- reports |>
#   dplyr::select(text, text2)|>
#   unique()
#
#
# txt$length <- stringr::str_length(txt$text)
# txt$length2 <- stringr::str_length(txt$text2)
#
#
#
# View(txt)
#
# #Ich bringe den SuSn bei, die Glaubwürdigkeit ermittelter Informationen richtig einschätzen zu können.
#
#
#
#
