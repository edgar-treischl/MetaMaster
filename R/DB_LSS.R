# library(MetaMaster)
#
# DB_Table("lss_surveys")


#' Delete Observations From a Table
#'
#' @description This function deletes all observations from a table in a PostgreSQL database.
#' @param table Data frame or table that will be uploaded.
#' @return A message indicating if the table was successfully deleted.
#' @usage DB_send(table = readxl::read_excel("myfile.xlsx"), name = "myname")
#' @export


DB_DeleteFrom <- function(table) {
  # Connect to the PostgreSQL database
  get <- config::get()
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

  if (!DBI::dbIsValid(con)) {
    cli::cli_abort("Failed to connect to the database. Please check your credentials and network.")
  }


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
    cli::cli_alert_warning("The table still contains records.")
  }

  on.exit(DBI::dbDisconnect(con), add = TRUE)
}



#DB_DeleteFrom(table = "lss_surveys")


#' Upload All LSS Survey Files to the Database
#'
#' @description This function uploads all .lss files in a directory to a PostgreSQL database.
#' @param dir Directory where the .lss files are stored.
#' @return A message indicating if the .lss files were successfully uploaded.
#' @usage DB_send(table = readxl::read_excel("myfile.xlsx"), name = "myname")
#' @export


DB_UploadLSS <- function(dir) {

  # Set the directory where the .lss files are stored
  lss_dir <- dir

  # List all .lss files in the directory
  lss_files <- list.files(lss_dir, pattern = ".lss$", full.names = TRUE)

  # Connect to the PostgreSQL database
  get <- config::get()
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


  purrr::walk(lss_files, process_lss_file, .progress = TRUE)
  cli::cli_alert_success("All .lss files have been uploaded to the database.")
  # Disconnect from PostgreSQL
  on.exit(DBI::dbDisconnect(con), add = TRUE)
}


#DB_UploadLSS(dir = here::here("Master_2024_18_11"))
