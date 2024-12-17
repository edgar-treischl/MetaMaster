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
# MetaMaster$checkhtml <- purrr::map(MetaMaster$text, is_html, .progress = T) |>
#   unlist()
#
#
# MetaMaster <- MetaMaster |> dplyr::filter(checkhtml == FALSE)
#
#
#
#
#
#
#
