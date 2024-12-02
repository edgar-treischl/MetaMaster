# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")




#' Build the Meta Data
#'
#' @description This function create the meta data based on the raw
#'    data fetched from Lime Survey.
#' @param send_report A logical value indicating if the report should be sent.
#' @param update Update database.
#' @return A message indicating the completion of the process.
#' @examples
#' \dontrun{
#' build(send_report = TRUE)
#' }
#' @export

build <- function(send_report = FALSE,
                  update = FALSE)  {

  # Ensure that the environment variable R_CONFIG_ACTIVE is set to "test"
  if (!Sys.getenv("R_CONFIG_ACTIVE") == "test") {
    cli::cli_abort("Please set the environment variable R_CONFIG_ACTIVE to 'test'.")
  }

  # Inform the user that the function is starting the process
  cli::cli_alert_info("Starting the build process...")

  # Fetch the master data
  cli::cli_alert_info("Fetching raw meta data from Lime Survey")
  LS_GetMasterData(export = TRUE)

  # Build metadata for the master data
  cli::cli_alert_info("Building metadata for the master data...")
  prepare_RawMeta(path = "metadata_raw.xlsx", export = TRUE)


  if (update) {
    metadata_raw <- readxl::read_excel("metadata_raw.xlsx")
    DB_send(metadata_raw, "metadata_raw")

    # templates <- readxl::read_excel("MetaMaster.xlsx", sheet = "templates")
    # DB_send(templates, "templates")
    #
    # reports <- readxl::read_excel("MetaMaster.xlsx", sheet = "reports")
    # DB_send(reports, "reports")
  }else {
    cli::cli_alert_warning("Skipping the update step. To update the DB, set update = TRUE.")
  }
  cli::cli_alert_info("Keep in mind that the sets and plots_headers* tables are not updated. Use DB_MetaUpdate to update them.")
  # Optionally send a report if the parameter send_report is TRUE
  if (send_report) {
    cli::cli_alert_info("Sending the report...")
    send_Report()
  } else {
    cli::cli_alert_warning("Skipping the report send step. To send the report, set send_report = TRUE.")
  }

  # Final message indicating completion
  cli::cli_alert_success("By the power of Grayskull: Building process completed.")
}


#build(send_report = TRUE)





#' Prepare the Raw Meta Data
#'
#' @description This function builds the MetaMaster from a given Excel file.
#' @param path The path to the Excel file.
#' @param export If TRUE, the MetaMaster will be exported as an Excel file.
#' @export

prepare_RawMeta <- function(path, export = FALSE) {
  df <- readxl::read_excel(path) |>
    dplyr::rename(master_template = template)


  mtt <- DB_Table("master_to_template")
  mtt <- mtt |> dplyr::select(master_template = surveyls_title,
                              rpt_overall,
                              template,
                              report = rpt)

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




  #01templates

  templates <- NULL

  varlist <- c("surveyID", "master_template", "report", "template", "ubb", "stype", "type", "ganztag", "rpt_overall")

  templates <- mastertemplate |>
    dplyr::select(dplyr::all_of(varlist)) |>
    dplyr::distinct()

  templates$timestamp <- Sys.time()


  #02reports

  reports <- NULL

  varlist <- c("report", "plot", "variable", "text", "type", "filter")

  reports <- mastertemplate |>
    dplyr::select(dplyr::all_of(varlist)) |>
    dplyr::group_by(report) |>
    dplyr::distinct() |>
    dplyr::ungroup()

  reports$timestamp <- Sys.time()



  #Give me some rules to shorten your strings#####################################
  reports$text <- stringr::str_remove_all(reports$text, "\\s*\\([^\\)]*\\)")

  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Sch\u00FChlerinnen und Sch\u00F6ler",
                                           replacement = "SuS")

  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Ausbilderinnen und Ausbilder",
                                           replacement = "Ausbildungspartner")

  reports$text <- stringr::str_replace_all(reports$text,
                                           pattern = "Lehrinnen und Lehrer",
                                           replacement = "LK")

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

  #03set data
  set_data <- DB_Table("set_data")
  sets <- DB_Table("sets")

  plots_headers <- DB_Table("plots_headers")
  plots_headers_ubb <- DB_Table("plots_headers_ubb")
  extraplots <- DB_Table(table = "extraplots")

  master_to_template <- DB_Table("master_to_template")
  report_packages <- master_to_template |>
    dplyr::filter(rpt_overall != "NA") |>
    dplyr::pull(rpt_overall) |>
    unique()


  overallreports <- purrr::map(report_packages,
                               prepare_OverallReport, .progress = TRUE) |>
    dplyr::bind_rows()



  mydfs <- list(
    templates = templates,
    reports = reports,
    overallreports = overallreports,
    set_data = set_data,
    sets = sets,
    plots_headers = plots_headers,
    headers_ubb = plots_headers_ubb,
    extra_plots = extraplots
  )


  if (export == TRUE) {
    cli::cli_alert_success("MetaMaster exported.")
    writexl::write_xlsx(mydfs, path = "MetaMaster.xlsx")
  }else {
    return(mydfs)

  }
}


#buildMetaMaster(path = "MasterData_2024_11_11.xlsx", export = TRUE)






#' Build Overall Report based on Package Name
#' @description This function will build an overall report based on the package name.
#' @param packagename The path to the Excel file.
#' @export


prepare_OverallReport <- function(packagename) {
  master_to_template <- DB_Table("master_to_template")

  allreports <- master_to_template |>
    dplyr::filter(rpt_overall == packagename) |>
    dplyr::arrange(rpt) |>
    dplyr::pull(rpt) |>
    unique()

  rpt_overall <- master_to_template |>
    dplyr::filter(rpt_overall == packagename) |>
    dplyr::pull(rpt_overall) |>
    unique()

  reports <- DB_Table("reports")


  overallreports <- reports |>
    dplyr::filter(report %in% allreports)

  check <- overallreports |>
    dplyr::arrange(report) |>
    dplyr::pull(report) |>
    unique()

  if (identical(allreports, check) == FALSE) {
    cli::cli_abort("Reports are not the same. Check the data.")
    #return(as.list(allreports, check))

  }else {
    overallreports$report <- rpt_overall
    return(overallreports)
  }
}

# master_to_template <- DB_Table("master_to_template")
# report_packages <- master_to_template |> dplyr::pull(pckg) |> unique()
# prepare_OverallReport(packagename = report_packages[5])
# overallreports <- purrr::map(report_packages[1:4], prepare_OverallReport)

#' Send Test Results
#' @description This function send the test results to the specified email address.
#' @examples
#' \dontrun{
#' send_Report(sendto = "john.doe@johndoe.com")
#' }
#' @export

send_Report <- function() {

  #Read "MetaMasterMeta.xlsx"
  metadf <- readxl::read_excel("MetaMaster.xlsx")

  #get date and time and add it to the subject
  date <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  mailsubject <- paste("MetaMaster Update", date)

  #The mail template
  file_path <- system.file("rmarkdown/templates/mail/skeleton/skeleton.Rmd", package = "MetaMaster")
  file.copy(file_path, to = here::here("template_mail.Rmd"))

  #Build the email with the template
  email <- blastula::render_email("template_mail.Rmd")|>
    blastula::add_attachment(file = "MetaMaster.xlsx")

  #Get the mail recipient and sender from the config file
  get <- config::get(file = "config.yml")
  report_from <- get$report_from
  report_to <- get$report_to

  # Send the email with smtp_send
  email |>
    blastula::smtp_send(
      to = report_to,
      from = report_from,
      subject = mailsubject,
      credentials = blastula::creds_file("my_mail_creds")
    )

}




utils::globalVariables(c("pckg", "rpt", "report", "template"))





























