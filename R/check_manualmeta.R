#library(MetaMaster)

# plots_headers <- DBTable(table = "plots_headers")
# plots_headers_ubb <- DBTable(table = "plots_headers_ubb")
#reports <- DBTable(table = "reports")
# set_data <- DBTable(table = "set_data")
# sets <- DBTable(table = "sets")
#templates <- DBTable(table = "templates")

# # Check if the file exists
# if (!file.exists(path)) {
#   cli::cli_abort(glue("The file '{path}' does not exist. Please check the path and try again."))
# }

#' Check the manual data
#' @description This function reads an Excel file with metadata and uploads
#'  each sheet as a table in the database.
#' @return A message from the DB_send function indicating if the table was
#'  successfully uploaded to the database
#' @export


check_manualmeta <- function() {
  plots_headers <- readxl::read_excel(here::here("data", "report_meta_dev.xlsx"),
                                      sheet = "plots_headers")

  plots_headers_ubb <- readxl::read_excel(here::here("data", "report_meta_dev.xlsx"),
                                          sheet = "plots_headers_ubb")

  reports <- readxl::read_excel(here::here("data", "report_meta_dev.xlsx"),
                                sheet = "reports")

  set_data <- readxl::read_excel(here::here("data", "report_meta_dev.xlsx"),
                                 sheet = "set_data")

  sets <- readxl::read_excel(here::here("data", "report_meta_dev.xlsx"),
                             sheet = "sets")

  templates <- readxl::read_excel(here::here("data", "report_meta_dev.xlsx"),
                                  sheet = "templates")



  #sets_data##########

  #Check column names
  usednames <- names(set_data)
  rightnames <- c("plot", "set", "timestamp")
  check_names <- all(usednames %in% rightnames)

  if (check_names == FALSE) {
    cli::cli_alert_danger("Check column of set_data data. It should be: {.val {rightnames} } ")
  }



  if (sum(is.na(set_data)) > 0) {
    cli::cli_abort("There are missing values in the set_data table.")
  }


  if (any(duplicated(set_data$plot)) == TRUE) {
    cli::cli_abort("There are duplicated plot names in the set_data table. Please check the data.")
  }


  set_unique <- set_data$set |> unique()

  reportsets <- reports |>
    tidyr::drop_na(sets) |>
    dplyr::pull(sets) |>
    unique()


  not_defined_set <- dplyr::setdiff(reportsets, set_unique)


  if (rlang::is_empty(not_defined_set) == FALSE) {
    cli::cli_alert_danger("Some sets (set_data table) that are not defined but listed in the reports table. Check: {.val {not_defined_set} } ")

  }



  #sets##########
  usednames <- names(sets)
  rightnames <- c("set", "code", "labels", "sort", "colors", "text_color", "timestamp" )
  check_names <- all(usednames %in% rightnames)

  if (check_names == FALSE) {
    cli::cli_alert_danger("Check column of set_data data. It should be: {.val {rightnames} } ")
  }



  if (sum(is.na(sets)) > 0) {
    cli::cli_abort("There are missing values in the sets table.")
  }


  set_unique <- sets$set |> unique()
  not_defined_set <- dplyr::setdiff(reportsets, set_unique)


  if (rlang::is_empty(not_defined_set) == FALSE) {
    cli::cli_alert_danger("Some sets (sets table) that are not defined but listed in the reports table. Check: {.val {not_defined_set} } ")

  }


  #plots_headers############

  usednames <- names(plots_headers)
  rightnames <- c("sort", "plot", "header1", "header2", "timestamp")
  check_names <- all(usednames %in% rightnames)

  if (check_names == FALSE) {
    cli::cli_alert_danger("Check column of plots_headers data. It should be: {.val {rightnames} } ")
  }




  #NA
  if (sum(is.na(plots_headers)) > 0) {
    cli::cli_abort("There are missing values in the plots_headers table.")
  }

  #Duplicates
  if (any(duplicated(plots_headers$plot)) == TRUE) {
    cli::cli_abort("There are duplicated plot names in the plots_headers table.")
  }

  #In reports
  all_plots <- reports$plot |> unique()
  plots_header <- plots_headers$plot

  check_headers <- dplyr::setdiff(plots_header, all_plots)
  headerdefined <- rlang::is_empty(check_headers)

  if (headerdefined == FALSE) {
    cli::cli_alert_danger("Some headers are not in the report table. Check: {.val {check_headers} } ")
  }

  #Sorting?
  header_sorting <- plots_headers |>
    dplyr::arrange(sort) |>
    dplyr::pull(sort)

  header_isSequence <- header_sorting == seq(min(plots_headers$sort):max(plots_headers$sort))
  #header_isSequence <- c(TRUE, FALSE)

  if (all(header_isSequence) == FALSE) {
    cli::cli_abort("Check the sorting of plots_headers table.")
  }



  plots_headers$header1 <- stringr::str_trim(plots_headers$header1)
  plots_headers$header1 <- stringr::str_replace_all(plots_headers$header1,
                                                    pattern = "  ", " ")

  plots_headers$header2 <- stringr::str_trim(plots_headers$header2)
  plots_headers$header2 <- stringr::str_replace_all(plots_headers$header2,
                                                    pattern = "  ", " ")


  #plots_headers_ubb##########
  usednames <- names(plots_headers_ubb)
  rightnames <- c("sort", "plot", "header1", "timestamp")
  check_names <- all(usednames %in% rightnames)

  if (check_names == FALSE) {
    cli::cli_alert_danger("Check column of plots_headers_ubb data. It should be: {.val {rightnames} } ")
  }



  #NA
  if (sum(is.na(plots_headers_ubb)) > 0) {
    cli::cli_abort("There are missing values in the plots_headers_ubb table.")
  }

  #Duplicates
  if (any(duplicated(plots_headers_ubb$plot)) == TRUE) {
    cli::cli_abort("There are duplicated plot names in the plots_headers_ubb table.")
  }

  #In reports
  all_plots <- reports$plot |> unique()
  plots_header <- plots_headers_ubb$plot

  check_headers <- dplyr::setdiff(plots_header, all_plots)
  headerdefined <- rlang::is_empty(check_headers)

  if (headerdefined == FALSE) {
    cli::cli_alert_danger("Some headers are not in the report table. Check: {.val {check_headers} } ")
  }

  #Sorting?
  header_sorting <- plots_headers_ubb |>
    dplyr::arrange(sort) |>
    dplyr::pull(sort)

  header_isSequence <- header_sorting == seq(min(plots_headers_ubb$sort):max(plots_headers_ubb$sort))
  #header_isSequence <- c(TRUE, FALSE)

  if (all(header_isSequence) == FALSE) {
    cli::cli_abort("Check the sorting of plots_headers_ubb table.")
  }



  plots_headers_ubb$header1 <- stringr::str_trim(plots_headers_ubb$header1)
  plots_headers_ubb$header1 <- stringr::str_replace_all(plots_headers_ubb$header1,
                                                        pattern = "  ", " ")
}




#checks <- check_manualmeta()





# extraplots <- get_AllExtraPlots(export = FALSE, filter = FALSE)
# extraplots








