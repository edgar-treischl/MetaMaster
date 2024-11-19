# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")


#' Build Meta Master Data
#'
#' @description This function builds the MetaMaster from a given Excel file.
#' @param path The path to the Excel file.
#' @param export If TRUE, the MetaMaster will be exported as an Excel file.
#' @export


buildMetaMaster <- function(path, export = FALSE) {
  df <- readxl::read_excel(path) |>
    dplyr::rename(master_template = template)


  mtt <- DB_Table("master_to_template")
  mtt <- mtt |> dplyr::select(master_template = surveyls_title, template, report = rpt)

  #masterlist <- Limer_GetMasterTemplates(template = TRUE)



  df <- mtt |> dplyr::left_join(df, by = "master_template",
                                relationship = "many-to-many")

  sart <- V2 <- V5 <- V8 <- NULL

  fromString <- as.data.frame(stringr::str_split_fixed(df$template,
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

  stringified$type <- stringr::str_replace_all(stringified$type, pattern = "eva",
                                               replacement = "ubb")



  stringified$template <- df$template




  mastertemplate <- df |>
    dplyr::left_join(stringified, by = "template",
                     relationship = "many-to-many")




  #01templates#############

  templates <- NULL

  varlist <- c("surveyID", "master_template", "report", "template", "ubb", "stype", "type", "ganztag")

  templates <- mastertemplate |>
    dplyr::select(dplyr::all_of(varlist)) |>
    dplyr::distinct()

  templates$timestamp <- Sys.time()


  #02reports#############

  reports <- NULL

  varlist <- c("report", "plot", "variable", "text", "type")

  reports <- mastertemplate |>
    dplyr::select(dplyr::all_of(varlist)) |>
    dplyr::group_by(report) |>
    dplyr::distinct() |>
    dplyr::ungroup()

  reports$timestamp <- Sys.time()



  #Give me some rules to shorten your strings#####################################
  reports$text <- stringr::str_remove_all(reports$text, "\\s*\\([^\\)]*\\)")

  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Schülerinnen und Schüler",
                                           replacement = "SuS")

  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Ausbilderinnen und Ausbilder",
                                           replacement = "Ausbildungspartner")

  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Lehrinnen und Lehrer",
                                           replacement = "Lehrkräfte")

  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Schulleitung",
                                           replacement = "SL")

  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Schulpersonal",
                                           replacement = "Personal")


  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Lehrerkonferenzen bzw. Teamkonferenzen",
                                           replacement = "Lehrer-/Teamkonferenzen")



  set_data <- sets <- plots_headers <- plots_headers_ubb <- extraplots <- NULL

  #03set data#############
  set_data <- DB_Table("set_data")
  sets <- DB_Table("sets")

  plots_headers <- DB_Table("plots_headers")
  plots_headers_ubb <- DB_Table("plots_headers_ubb")
  extraplots <- DB_Table(table = "extraplots")


  mydfs <- list(
    templates = templates,
    reports = reports,
    set_data = set_data,
    sets = sets,
    plots_headers = plots_headers,
    headers_ubb = plots_headers_ubb,
    extra_plots = extraplots
  )


  if (export == TRUE) {
    cli::cli_alert_success("MetaMaster exported.")
    writexl::write_xlsx(mydfs, path = "MetaMasterMeta.xlsx")
  }else {
    return(mydfs)

  }
}


#buildMetaMaster(path = "MasterData_2024_11_11.xlsx", export = TRUE)














