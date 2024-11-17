#' Send a Table to the Database
#' @description This function send a table to the database from a data frame.
#' @param table Data frame to be uploaded to the database
#' @param name Name of the table in the database
#' @return A message indicating if the table was successfully uploaded to the database
#' @export


DB_send <- function(table, name) {

  get <- config::get()
  db <- get$db
  db_host <- get$db_host
  db_port <- get$db_port
  db_user <- get$db_user
  db_password <- get$db_password
  db_mode <- get$db_mode

  con <- DBI::dbConnect(RPostgres::Postgres(),
                        dbname = db,
                        host = db_host,
                        port = db_port,
                        user = db_user,
                        sslmode = db_mode,
                        password = db_password)

  # Check if connection is valid
  if (!DBI::dbIsValid(con)) {
    cli_abort("Failed to connect to the database. Please check your credentials and network connection.")
  }

  table$timestamp <- Sys.time()

  dplyr::copy_to(con, table, overwrite = TRUE, temporary = FALSE, name = name)



  tableslisted <- DBI::dbListTables(con)

  if (name %in% tableslisted) {
    cli::cli_alert_success(glue::glue("The table '{name}' has been successfully uploaded to the database."))
  } else {
    cli::cli_alert_error(glue::glue("Failed to upload the table '{name}' to the database."))
  }


  on.exit(DBI::dbDisconnect(con), add = TRUE)


}


# DB_send(table = readxl::read_excel("data/master_to_template.xlsx"),
#         name = "master_to_template")




#' Upload Metadata to the Database
#' @description This function reads an Excel file with metadata and uploads
#'  each sheet as a table in the database.
#' @param path Path to the Excel file with metadata
#' @return A message from the DB_send function indicating if the table was
#'  successfully uploaded to the database
#' @export


DB_MetaUpdate <- function(path) {

  # Check if the file exists
  if (!file.exists(path)) {
    cli::cli_abort(glue("The file '{path}' does not exist. Please check the path and try again."))
  }

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
        cli::cli_alert_danger(glue("Failed to read sheet {.x}"))
      }
    })
}



#DB_MetaUpdate(path = "data/report_meta_dev.xlsx")



#' Get a Table from the Database
#' @description This function fetches a table from the database and returns it as a data frame.
#'  If no table is specified, it returns a list of all available tables in the database.
#' @param table The name of the table to fetch from the database
#' @return A data frame with the table data or a list of all available tables in the database
#' @export


DB_Table <- function(table = NULL) {
  get <- config::get()
  db <- get$db
  db_host <- get$db_host
  db_port <- get$db_port
  db_user <- get$db_user
  db_password <- get$db_password
  db_mode <- get$db_mode

  con <- DBI::dbConnect(RPostgres::Postgres(),
                        dbname = db,
                        host = db_host,
                        port = db_port,
                        user = db_user,
                        sslmode = db_mode,
                        password = db_password)

  # Check if connection is valid
  if (!DBI::dbIsValid(con)) {
    cli_abort("Failed to connect to the DB. Please check credentials and network.")
  }

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

#DB_Table()
#DB_Table(table = "master_to_template")






