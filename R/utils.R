#' Extract Text from HTML
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


#' Update all Masters LimeSurvey
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @export

update_allMastersLimeSurvey <- function() {
  allMasters <- get_MasterTemplate()
  writexl::write_xlsx(allMasters, "data/allMastersLimeSurvey.xlsx")
}

#update_allMastersLimeSurvey()









#' Add report template
#' @description Bla bla


add_report_template <- function() {

  mastertmp <- DB_Table("master_to_template")


  template <- mastertmp$template


  report_template <- template |>
    stringr::str_replace_all("tmpl_", "rpt_")


  mastertmp$report_template <- report_template
  mastertmp

  #export to excel file

  openxlsx::write.xlsx(mastertmp, here::here("data/master_to_template.xlsx"))

}


#add_report_template()

#' Remove white spaces and combine text
#' @description This function removes white spaces and combines text.
#' @param input_vector A character vector.
#' @export

remove_and_combine <- function(input_vector) {
  # Use strsplit to split each string by one or more whitespace characters
  split_text <- strsplit(input_vector, "\\s+")

  # Use sapply to collapse the split strings with exactly one space between words
  result <- sapply(split_text, function(x) paste(x, collapse = " "))

  return(result)
}

#remove_and_combine(input_vector = "What   a difference a day makes.")


#' Test if String is HTML
#' @description This function tests if the input is HTML. It uses the
#'  `xml2` package to parse the input as HTML.
#' @param x A character string
#' @export


# Function to check if a string is HTML
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
#' @description This function creates test schools based on the master templates.
#' @export

create_TestSchools <- function() {

  if (!Sys.getenv("R_CONFIG_ACTIVE") == "test") {
    cli::cli_abort("Please set the environment variable R_CONFIG_ACTIVE to 'test'")
  }


  #Get masterlist
  mastertemplates <- Limer_GetMasterTemplates(template = TRUE)

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


#create_TestSchools()
