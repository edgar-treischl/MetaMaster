#' Extract Text from HTML formated Survey Text
#'
#' @description Some text in Lime Survey are saved as HTML.
#'  This helper function extracts it from the HTML code.
#' @param input HTML code
#' @examples
#' \dontrun{
#' extract_html(input = "Html code here")
#' }
#' @noRd


extract_html <- function(input) {
  rvest::minimal_html(input) |>
    rvest::html_elements("p") |>
    rvest::html_elements("b") |>
    rvest::html_text2()
}


#' Remove White Spaces and Combine Text
#'
#' @description Some master templates have white spaces between words. This
#'  function removes the white spaces and combines the text again.
#' @param input_vector A character vector.
#' @examples remove_and_combine(input_vector = "What   a difference  a day makes.")
#' @noRd

remove_and_combine <- function(input_vector) {
  # Use strsplit to split each string by one or more whitespace characters
  split_text <- strsplit(input_vector, "\\s+")

  # Use sapply to collapse the split strings with exactly one space between words
  result <- sapply(split_text, function(x) paste(x, collapse = " "))

  return(result)
}




#' Test if a Character Vector is actually HTML
#'
#' @description Some, but not all texts in Lime Survey are formatted as HTML.
#'  This function uses the `xml2` package to parse the input as HTML.
#' @param x A character string
#' @examples extract_html(input = "Html code here")
#' @noRd

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
#' @param where The path to the directory where the master templates are stored.
#' @examples
#' \dontrun{
#' create_TestSchools()
#' }
#' @export

create_TestSchools <- function(where) {

  if (!Sys.getenv("R_CONFIG_ACTIVE") == "test") {
    cli::cli_abort("Please set the environment variable R_CONFIG_ACTIVE to 'test'")
  }
  #check required arguments
  rlang::check_required(where)

  #Get masterlist
  mastertemplates <- LS_GetMasterTemplates(template = TRUE)

  #list all files with ending .lss
  lssfiles <- list.files(path = where, pattern = ".lss$", full.names = TRUE)

  #extract digits from lssfiles
  lss_digits <- gsub("\\D", "", lssfiles)

  #make a dataframe with the lssfiles and the extracted digits
  lssfiles_df <- data.frame(file = lssfiles, sid = as.integer(lss_digits))

  #Leftjoin mastertemplates with lssfiles_df by sid
  test_data <- mastertemplates |> dplyr::left_join(lssfiles_df, by = "sid")


  #Extract school from template
  template <- test_data$template

  #Split after each _ and make a dataframe out of it
  template_df <- data.frame(do.call(rbind, strsplit(template, "_")))

  #combine x3 and x4
  schooltype <- paste0(template_df$X3, "_", template_df$X4)

  #Remove "allg_" from strings
  school <- gsub("allg_", "", schooltype)
  test_data$stype <- school
  #Add audience
  test_data$audience <- template_df$X5
  #Add ubb and ganztag
  test_data$ubb <- grepl("_ubb", test_data$template)
  test_data$ganztag <- grepl("p1$", test_data$template)

  #Create a new name that we will replace with SNR according to the school
  test_data$new_name <- gsub("tmpl_", "", template)

  #Replace strings in test_data$school
  test_data$snr <- gsub("gm", "8934", test_data$stype)
  test_data$snr <- gsub("gs", "1208", test_data$snr)
  test_data$snr <- gsub("zspf_fz", "6009", test_data$snr)
  test_data$snr <- gsub("beru_fb", "0850", test_data$snr)
  test_data$snr <- gsub("gy", "0001", test_data$snr)
  test_data$snr <- gsub("ms", "2101", test_data$snr)
  test_data$snr <- gsub("rs", "0423", test_data$snr)
  test_data$snr <- gsub("beru_bq", "5018", test_data$snr)
  test_data$snr <- gsub("zspf_bq", "5165", test_data$snr)
  test_data$snr <- gsub("beru_ws", "5105", test_data$snr)

  #Create a new column with the new name for test schools
  test_data$test_school <- paste0(test_data$snr, "_", "202425_", test_data$new_name)

  #Reduce output to needed stuff
  test_data <- test_data |> dplyr::select(-surveyls_title, -new_name, -template)
  return(test_data)

}


#' Create a Config File
#'
#' @description This function creates a YAML config file with default values.
#' @param file The name of the YAML file to create. Default is "config.yml".
#' @param export If TRUE, the function writes the YAML file. Otherwise, it returns the YAML.
#' @examples
#' \dontrun{
#' create_config()
#' }
#' @export

create_config <- function(file = "config.yml",
                          export = "TRUE") {
  # Check if the YAML file already exists
  if (file.exists(file) & export == "TRUE") {
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

  if (export) {
    # Write the list to a YAML file
    yaml::write_yaml(content, file)
    message("YAML file created successfully: ", file)
  }else {
    myyaml <- yaml::as.yaml(content)
    return(myyaml)
  }


}


#' Export XML/LSS Files from a Data Frame
#'
#' @description This function exports XML files from a data frame to the "lssfiles" directory.
#' @param data Data
#' @examples
#' \dontrun{
#' export_XML(lss_surveys)
#' }
#' @export

export_XML <- function(data) {

  # Create the "lssfiles" directory if it doesn't already exist
  if (!dir.exists("lssfiles")) {
    dir.create("lssfiles")
  }

  invisible(data |>
              purrr::pmap(function(id, file_id, master, survey_data) {
                # Convert survey_data (pq_xml) to character string
                xml_data <- as.character(survey_data)

                # Define the file path for the output file
                file_name <- paste0("lssfiles/", file_id, ".lss")

                # Write the XML data to the file
                writeLines(xml_data, file_name)

                # Optional: print a message to indicate the file has been exported
                message(paste("Exported file:", file_name))
              })
  )
}


#' Fix plotnames to length 5
#'
#' @description This function exports XML files from a data frame to the "lssfiles" directory.
#' @param data Data
#' @examples
#' \dontrun{
#' export_XML(lss_surveys)
#' }
#' @noRd

fix_plotnames <- function() {
  cli::cli_abort("This function is not implemented. Use code to fix length of plot names.")
  set_data <- DB_Table("set_data")
  set_data

  set_data$plot_new <- set_data$plot
  set_data$plot_new

  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "A1", replacement = "A01")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "A2", replacement = "A02")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "A4", replacement = "A04")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "A6", replacement = "A06")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "ZA", replacement = "ZFA")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "Zab", replacement = "ZFab")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "ZE", replacement = "ZFE")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "ZEb", replacement = "ZFEb")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "ZL", replacement = "ZFL")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "ZLb", replacement = "ZFLb")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "ZS", replacement = "ZFS")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "ZSb", replacement = "ZFSb")
  set_data$plot_new <- stringr::str_replace_all(set_data$plot_new, pattern = "Dauer", replacement = "Durat")

  set_data$plot_new <- stringr::str_pad(set_data$plot_new, width = 5, side = "right", pad = "x")



  set_data <- set_data |> dplyr::select(-timestamp, -plot)
  sets <- sets |> dplyr::left_join(set_data, by = "set", relationship = "many-to-many")
}

