#' Connect to the Database
#'
#' @description This function connects to the database using the credentials
#'  provided in the config file.
#' @return Return the connection object.
#' @examples
#' \dontrun{
#' connect_DB()
#' }
#'
#' @export

connect_DB <- function() {
  get <- config::get(file = here::here("config.yml"))
  db <- get$db
  db_host <- get$db_host
  db_port <- get$db_port
  db_user <- get$db_user
  db_password <- get$db_password
  db_mode <- get$db_mode

  # Connect to the database
  con <- DBI::dbConnect(RPostgres::Postgres(),
                        dbname = db,
                        host = db_host,
                        port = db_port,
                        user = db_user,
                        sslmode = db_mode,
                        password = db_password)

  # Check if connection is valid
  if (!DBI::dbIsValid(con)) {
    cli::cli_abort("Failed to connect to the database. Please check your credentials and network.")
  }

  return(con)
}




#' Send a Table to the Database
#'
#' @description This function sends a table to the database.
#' @param table Data frame or table that will be uploaded.
#' @param name Name of the table.
#' @return A message indicating if the table was successfully uploaded.
#' @examples
#' \dontrun{
#' DB_send(table, name)
#' }
#'
#' @export


DB_send <- function(table, name) {

  # #Get config
  # get <- config::get(file = here::here("config.yml"))
  # db <- get$db
  # db_host <- get$db_host
  # db_port <- get$db_port
  # db_user <- get$db_user
  # db_password <- get$db_password
  # db_mode <- get$db_mode
  #
  # # Connect to the database
  # con <- DBI::dbConnect(RPostgres::Postgres(),
  #                       dbname = db,
  #                       host = db_host,
  #                       port = db_port,
  #                       user = db_user,
  #                       sslmode = db_mode,
  #                       password = db_password)
  #
  # # Check if connection is valid
  # if (!DBI::dbIsValid(con)) {
  #   cli::cli_abort("Failed to connect to the database. Please check your credentials and network.")
  # }

  con <- connect_DB()

  #Add timestamp
  table$timestamp <- Sys.time()
  #Copy the table to the database
  dplyr::copy_to(con, table, overwrite = TRUE, temporary = FALSE, name = name)


  # Check if the table was successfully uploaded
  tableslisted <- DBI::dbListTables(con)

  #Give feedback
  if (name %in% tableslisted) {
    cli::cli_alert_success(glue::glue("The table '{name}' has been successfully uploaded to the database."))
  } else {
    cli::cli_alert_warning(glue::glue("Failed to upload the table '{name}' to the database."))
  }

  # Disconnect from the database
  on.exit(DBI::dbDisconnect(con), add = TRUE)


}







#' Upload Metadata to the Database
#'
#' @description This function reads the manual metadata and uploads
#'  each sheet as a table in the database.
#' @param path Path to the Excel sheet
#' @return A message if successful
#' @examples
#' \dontrun{
#' DB_MetaUpdate(path)
#' }
#'
#' @export


DB_MetaUpdate <- function(path) {

  # Check if the file exists
  if (!file.exists(path)) {
    cli::cli_abort(glue::glue("The file '{path}' does not exist. Please check the path and try again."))
  }

  #Make consistency checks and abort if necessary
  check_manualmeta()

  # Get sheet names from the Excel file
  #metadata_sheets <- readxl::excel_sheets(path)
  metadata_sheets <- c("set_data", "sets", "plots_headers", "plots_headers_ubb")


  # Check if there are sheets to process
  if (length(metadata_sheets) == 0) {
    cli::cli_abort("The Excel file has no sheets. Please ensure this is the right meta data.")
  }

  # Process each sheet
  metadata_sheets |>
    purrr::walk(~ {
      # Read the sheet
      metadata <- readxl::read_excel(path, sheet = .x)

      # If the sheet was successfully read, call DB_send
      if (!is.null(metadata)) {
        DB_send(table = metadata, name = .x)
      } else {
        # If reading the sheet failed, show an error
        cli::cli_alert_danger(glue::glue("Failed to read sheet {.x}"))
      }
    })
}





#' Get a Table from the Database
#'
#' @description This function fetches a table from the database and returns it as a data frame.
#'  If no table is specified, it returns a list of all available tables.
#' @param table The name of the table.
#' @return A data frame with the table data or a list of available tables.
#' @examples
#' \dontrun{
#' DB_Table()
#' }
#' @return A data frame with the table data or a list of available tables
#' @export


DB_Table <- function(table = NULL) {

  # Connect to the PostgreSQL database
  con <- connect_DB()

  # If table argument is missing, return all available tables
  if (is.null(table)) {
    tables <- DBI::dbListTables(con)
    if (interactive()) {
      cli::cli_alert_info("The following tables are available in the DB:")
    }
    DBI::dbDisconnect(con)
    return(tables)
  }

  # If table is provided, fetch data from the specified table
  if (!table %in% DBI::dbListTables(con)) {
    abort_txt <- glue::glue("The specified table '{table}' does not exist. Skip the 'table' argument to list all available tables.")
    cli::cli_abort(abort_txt)
  }

  # Fetch data from the table
  df <- dplyr::collect(dplyr::tbl(con, table))

  on.exit(DBI::dbDisconnect(con), add = TRUE)
  return(df)

}




#' Delete Observations From a Table
#'
#' @description This function deletes all observations from a table in a PostgreSQL database.
#' @param table Data frame or table that will be emptied
#' @return A message indicating if the table was successfully deleted.
#' @examples
#' \dontrun{
#' DB_DeleteFrom(table)
#' }
#'
#' @export


DB_DeleteFrom <- function(table) {

  # Connect to the PostgreSQL database
  con <- connect_DB()

  # Delete all records from the table
  sql_code <- "DELETE FROM "
  sql_code <- paste0(sql_code, table, ";")
  DBI::dbExecute(con, sql_code)

  # Check if the table is empty by counting the rows
  count_query <- paste0("SELECT COUNT(*) FROM ", table)
  row_count <- DBI::dbGetQuery(con, count_query)

  # Verify if the table is empty
  if (row_count[1, 1] == 0) {
    cli::cli_alert_success("The table is now empty.")
  } else {
    cli::cli_alert_warning("Upps..something went wrong.")
  }

  on.exit(DBI::dbDisconnect(con), add = TRUE)
}





#' Upload LSS Survey Files to the Database
#'
#' @description This function insert all .lss files in the
#'  lss_surveys table in the PostgreSQL database.
#' @param dir Directory where the .lss files are stored.
#' @return A message indicating if the .lss files were successfully uploaded.
#' @examples
#' \dontrun{
#' DB_UploadLSS(dir)
#' }
#' @export


DB_UploadLSS <- function(dir) {

  # Set the directory where the .lss files are stored
  lss_dir <- dir

  # List all .lss files in the directory
  lss_files <- list.files(lss_dir, pattern = ".lss$", full.names = TRUE)

  # Check if there are any .lss files in the directory
  if (rlang::is_empty(lss_files)) {
    cli::cli_abort("Sorry buddy, no .lss files found in the directory.")
  }

  # Connect to the PostgreSQL database
  con <- connect_DB()

  # Define the function to process each file
  process_lss_file <- function(lss_file) {
    # Extract the ID from the filename (assuming the ID is the file name without the extension)
    file_id <- tools::file_path_sans_ext(basename(lss_file))
    file_id <- stringr::str_extract(file_id, "\\d+")

    # Read the XML content of the .lss file
    xml_data <- xml2::read_xml(lss_file)

    # Extract the survey title (for example, from the <title> element in the XML file)
    master <- xml2::xml_text(xml2::xml_find_first(xml_data, "//surveyls_title"))

    # Convert the XML data to a string
    xml_string <- as.character(xml_data)

    # Insert the data into the PostgreSQL table
    DBI::dbExecute(con, "INSERT INTO lss_surveys (file_id, master, survey_data) VALUES ($1, $2, $3)",
                   params = list(file_id, master, xml_string))
  }

  # Process all .lss files
  purrr::walk(lss_files, process_lss_file, .progress = TRUE)
  cli::cli_alert_success("All .lss files have been uploaded to the database.")
  # Disconnect
  on.exit(DBI::dbDisconnect(con), add = TRUE)
}













