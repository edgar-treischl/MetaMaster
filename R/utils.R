#' Extract Text from HTML formated Survey Text
#'
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @param input HTML code
#' @examples \dontrun{
#' extract_html(input = "Html code here")
#' }
#' @export
extract_html <- function(input) {
  rvest::minimal_html(input) |>
    rvest::html_elements("p") |>
    rvest::html_elements("b") |>
    rvest::html_text2()
}


#' Remove white spaces and combine text
#'
#' @description Some master templates have white spaces in between words. This
#'  function removes the white spaces and combines the text again.
#' @param input_vector A character vector.
#' @examples \dontrun{
#  remove_and_combine(input_vector = "What   a difference  a day makes.")
#' }
#' @export

remove_and_combine <- function(input_vector) {
  # Use strsplit to split each string by one or more whitespace characters
  split_text <- strsplit(input_vector, "\\s+")

  # Use sapply to collapse the split strings with exactly one space between words
  result <- sapply(split_text, function(x) paste(x, collapse = " "))

  return(result)
}




#' Test if a Character Vector is HTML Code
#'
#' @description Some, but not all texts in Lime Survey are formated as HTML.
#'  This function uses the `xml2` package to parse the input as HTML.
#' @param x A character string
#' @examples \dontrun{
#' extract_html(input = "Html code here")
#' }
#' @export
is_html <- function(x) {
  tryCatch({
    # Try parsing the string as HTML
    xml2::read_html(x)
    TRUE  # If successful, it's HTML
  }, error = function(e) {
    FALSE  # If there's an error, it's not HTML
  })
}


#' Create Test Schools
#'
#' @description This function creates a data frame to test all master templates.
#'  It creates example surveys for each master template to upload in a test environment.
#' @examples \dontrun{
#' create_TestSchools()
#' }
#' @export

create_TestSchools <- function() {

  if (!Sys.getenv("R_CONFIG_ACTIVE") == "test") {
    cli::cli_abort("Please set the environment variable R_CONFIG_ACTIVE to 'test'")
  }


  #Get masterlist
  mastertemplates <- LS_GetMasterTemplates(template = TRUE)

  #Get unique values of surveyls_title
  mastertemplates <- mastertemplates |>
    dplyr::distinct(surveyls_title, .keep_all = TRUE)


  #list all files with ending .lss
  lssfiles <- list.files(path = "Master_Templates", pattern = ".lss$", full.names = TRUE)

  #extract digits from lssfiles
  lss_digits <- gsub("\\D", "", lssfiles)

  #make a dataframe with the lssfiles and the extracted digits
  lssfiles_df <- data.frame(file = lssfiles, sid = as.integer(lss_digits))
  lssfiles_df

  #Leftjoin mastertemplates with lssfiles_df by sid
  test_data <- mastertemplates |> dplyr::left_join(lssfiles_df, by = "sid")
  test_data


  #Extract school from template
  template <- test_data$template

  #Split after each _ and make a dataframe out of it
  template_df <- data.frame(do.call(rbind, strsplit(template, "_")))

  #combine x3 and x4
  schooltype <- paste0(template_df$X3, "_", template_df$X4)

  #Remove "allg_" from strings
  school <- gsub("allg_", "", schooltype)
  test_data$school <- school


  #Create a new name that we will replace with SNR according to the school
  test_data$new_name <- gsub("tmpl_", "", template)

  #Replace strings in test_data$school
  test_data$snr <- gsub("gm", "8934", test_data$school)
  test_data$snr <- gsub("gs", "1208", test_data$snr)
  test_data$snr <- gsub("zspf_fz", "6009", test_data$snr)
  test_data$snr <- gsub("beru_fb", "0850", test_data$snr)
  test_data$snr <- gsub("gy", "0001", test_data$snr)
  test_data$snr <- gsub("ms", "2101", test_data$snr)
  test_data$snr <- gsub("rs", "0423", test_data$snr)
  test_data$snr <- gsub("beru_bq", "5018", test_data$snr)
  test_data$snr <- gsub("zspf_bq", "5165", test_data$snr)

  #Create a new column with the new name for test schools
  test_data$test_school <- paste0(test_data$snr, "_", "202425_", test_data$new_name)

  #Reduce output to needed stuff
  #test_data <- test_data |> dplyr::select(-school, -new_name, -snr)
  return(test_data)

}


#' Create a Config File
#'
#' @description This function creates a YAML config file with default values.
#' @examples \dontrun{
#' create_config()
#' }
#' @export

create_config <- function(file = "config.yml") {
  # Check if the YAML file already exists
  if (file.exists(file)) {
    # Ask the user if they want to overwrite the file
    overwrite <- readline(prompt = paste("The file", file, "already exists. Do you want to overwrite it? (y/n): "))

    # Proceed only if the user confirms 'y'
    if (tolower(overwrite) != "y") {
      message("The file was not overwritten.")
      return(NULL)  # Exit the function if user does not want to overwrite
    }
  }

  # Define the content of the YAML file as a list
  content <- list(
    default = list(
      tmp.server = "server",
      api_url = "url",
      tmp.user = "user",
      tmp.credential = "cred",
      db = "dbname",
      db_host = "host",
      db_port = "port",
      db_user = "db user",
      db_password = "password",
      db_mode = "require"
    )
  )

  # Write the list to a YAML file
  yaml::write_yaml(content, file)
  message("YAML file created successfully: ", file)
}






