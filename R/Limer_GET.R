# Sys.setenv(R_CONFIG_ACTIVE = "test")
# library(MetaMaster)
#
# mastertemplatesList <- get_masters()

#' Get Master Templates from Lime Survey
#'
#' @description This function gets the master templates from Lime Survey.
#' @param template If TRUE, the function will return the template name as well.
#' @return Results from the API.
#' @examples
#' \dontrun{
#' LS_GetMasterTemplates(template = FALSE)
#' }
#'
#' @export


LS_GetMasterTemplates <- function(template = FALSE) {
  # Step 1: Get configuration settings (no error handling)
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential

  # Step 2: Establish a session with the survey system
  tmp.session <- LS_Connect(user = tmp.user, credential = tmp.credential, server = tmp.server)

  # Step 3: Retrieve the list of surveys
  lslist <- LS_Ask(method = "list_surveys")

  # Step 4: Check for error status in the response
  if (!is.null(lslist$status) && grepl("Error", lslist$status)) {
    cli::cli_abort(
      message = "Failed to retrieve data from the API. Status: {lslist$status}",
      .call = match.call()
    )
  }

  # Step 5: Release the session key
  LS_Release()

  # Step 6: Flag surveys with "master_" in their title
  lslist$master <- stringr::str_detect(lslist$surveyls_title, pattern = "master_")

  # Step 7: Filter and arrange master surveys using native pipe
  mastertemplates <- lslist |>
    dplyr::filter(master == TRUE) |>
    dplyr::select(sid, surveyls_title) |>
    dplyr::arrange(surveyls_title)

  # Step 8: Convert to tibble for better handling
  df <- tibble::as_tibble(mastertemplates)

  # Step 9: Join with template data if requested
  if (template) {
    # Fetch the master-to-template mapping from the database
    master_to_template <- DB_Table("master_to_template")

    # If the data exists, join with the survey list
    matchdf <- master_to_template |>
      dplyr::select(surveyls_title, template)

    df <- df |>
      dplyr::left_join(matchdf, by = "surveyls_title")
  }

  # Step 10: Return the final result
  return(df)
}


# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")
# df <- Limer_GetMaster(template = FALSE)

#' Get Questions from a Master File
#' @description This function gets the questions (plot, variable, text)
#'  from the master survey template.
#' @param id Survey ID.
#' @param name Survey name (surveyls_title).
#' @return Results from the API.
#' @examples
#' \dontrun{
#' LS_GetMasterQuestions(id = '1', name = 'master')
#' }
#'
#' @export

LS_GetMasterQuestions <- function(id, name) {

  #Get specs from config
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential
  #Connect
  tmp.session <- LS_Connect(user = tmp.user,
                            credential = tmp.credential,
                            server = tmp.server)

  #Get list of questions
  lslist <- LS_Ask(method = "list_questions",
                   params = list(iSurveyID = id))
  #Disconnect
  LS_Release()

  #Check for error status in the response
  if (rlang::is_empty(lslist$status) == FALSE) {
    problem <- paste0("Error in get_MasterMeta(): ", lslist$status)
    cli::cli_abort(problem)
  }

  #Check which question types are in the survey
  questiontypes <- unique(lslist$type)
  #These are tested question types
  allowed_types <- c("!", "L", "F", "X", "M", "S", "T")

  # Check if any value in questiontypes is not in the allowed set
  invalid_values <- questiontypes[!questiontypes %in% allowed_types]

  #Abort with a custom message if there are invalid values
  if (length(invalid_values) > 0) { # nocov
    cli::cli_abort(paste("Invalid value(s) found in questiontypes:", # nocov
                         paste(invalid_values, collapse = ", "))) # nocov
  }


  #Drop boilerplate questions (placeholder)
  if ("X" %in% questiontypes) {
    lslist <- lslist |> dplyr::filter(type != "X")
  }


  #Identify filter quesions via relevance
  gid_filter <- lslist |>
    dplyr::filter(relevance != "1") |>
    dplyr::pull(gid) |>
    unique()

  #Grab titles of filter questions
  filter <- NULL
  if (!rlang::is_empty(gid_filter)) {
    filter <- lslist |>
      dplyr::filter(parent_qid != "0") |>
      dplyr::filter(gid %in% gid_filter) |>
      dplyr::pull(title)
  }


  #Next we extract questions and titles, depending on the question type
  #TYPE F OR M
  templateArray <- NULL


  if (any(questiontypes %in% c("F", "M"))) {
    lslistArray <- lslist |> dplyr::filter(type %in% c("F", "M"))

    df <- lslistArray |>
      dplyr::select(parent_qid, title)


    # Step 1: Extract plot and var titles

    titles <- df |>
      dplyr::filter(parent_qid == 0) |>
      dplyr::mutate(row_number = dplyr::dense_rank(title)) |>
      dplyr::select(row_number, plot = title, parent = parent_qid)


    var_titles <- df |>
      dplyr::filter(parent_qid != 0) |>
      dplyr::mutate(row_number = dplyr::dense_rank(parent_qid)) |>
      dplyr::select(row_number, title, parentV = parent_qid)


    #Left join the two dataframes on row_number
    matched_variables <- titles |>
      dplyr::left_join(var_titles, by = "row_number")


    plot <- matched_variables$plot
    varname <- matched_variables$title

    #Step2: Extract questions
    question <- lslistArray |>
      dplyr::filter(parent_qid != "0") |>
      dplyr::pull(question)

    questions <- stringr::str_trim(question)

    #Create DF
    templateArray <- tibble::tibble(surveyID = id,
                                    template = name,
                                    plot = plot,
                                    variable = varname,
                                    text = questions)

    #Add filter column
    templateArray <- templateArray |>
      dplyr::mutate(filter = ifelse(variable %in% filter, "TRUE", "FALSE"))
  }

  templateLRadio <- NULL
  if (any(questiontypes %in% c("!", "L", "S", "T"))) {
    #TYPE "!", "L", "S", "T"
    lslistLRadio <- lslist |> dplyr::filter(type %in% c("!", "L", "S", "T"))

    varname <- lslistLRadio$title
    plot <- substr(varname, 1, 3)
    varname <- substr(varname, 4, nchar(varname))
    questions <- lslistLRadio$question


    #Some questions are HTML code, we need to extract the text
    #Work in Progress: Talk with Gisela
    checkhtml <- is_html(questions[1])

    #Extract text
    html_text <- purrr::map(questions, extract_html) |>
      purrr::flatten_chr()

    questions <- stringr::str_trim(html_text)

    #And there are manual breaks so nquestions must not nplots
    nquestions <- length(questions)
    nplots <- length(plot)

    if (nplots != nquestions) {
      questions <- "Reformat HTML Code"
    }

    #Create DF
    templateLRadio <- tibble::tibble(surveyID = id,
                                     template = name,
                                     plot = plot,
                                     variable = varname,
                                     text = questions)
    #Add filter column
    templateLRadio <- templateLRadio |>
      dplyr::mutate(filter = ifelse(variable %in% filter, "TRUE", "FALSE"))
  }


  # Return the appropriate result, combining if both exist
  if (!is.null(templateArray) && !is.null(templateLRadio)) {
    df_return <- rbind(templateArray, templateLRadio)
  } else {
    df_return <- rlang::`%||%`(templateArray, templateLRadio)
  }

  return(df_return)
}



#Limer_GetMasterQuesions(id = df$sid[31], name = df$surveyls_title[31])

#purrr::map2(df$sid, df$surveyls_title, limer_NEW)






#' Get the Master Data from Lime Survey
#'
#' @description This function gets the raw meta data from Lime Survey for all master templates.
#' @param export Export the data to an Excel file.
#' @return Results from the API.
#' @examples
#' \dontrun{
#' LS_GetMasterData(export = FALSE)
#' }
#'
#' @export


LS_GetMasterData <- function(export = FALSE) {

  #Get all the masters ids and names from LimeSurvey
  limerdf <- LS_GetMasterTemplates(template = FALSE)
  sid <- limerdf$sid
  surveyls_title <- limerdf$surveyls_title

  #Get the metadata for all the masters
  allmasters <- purrr::map2(sid,
                            surveyls_title,
                            LS_GetMasterQuestions, .progress = TRUE)

  #Bind them together
  allmasters <- allmasters |> dplyr::bind_rows()

  #allmasters$build_date <- format(Sys.Date(), "%Y %m %d")

  #export to Excel
  if (export == TRUE) {
    writexl::write_xlsx(allmasters, paste0("metadata_raw", ".xlsx"))
    cli::cli_alert_success("Raw meta data exported.")
  }else {
    return(allmasters)
  }
}




#' Upload Master Templates as Survey Templates to Lime Survey
#'
#' @description This function uploads all master templates as survey templates
#'  to Lime Survey.
#' @return Results from the API.
#' @examples
#' \dontrun{
#' LS_UploadTemplates()
#' }
#'
#' @export

LS_UploadTemplates <- function() {
  cli::cli_abort("This function is not ready yet. Adjust paths!")
  masters <- LS_GetMasterTemplates(template = TRUE)

  #List all files with ending lss here: data/MasterTemplates/Minke_Master_Backup/
  lssfiles <- list.files(here::here("data/MasterTemplates/Minke_Master_Backup/"),
                         pattern = ".lss$")
  lsspaths <- list.files(here::here("data/MasterTemplates/Minke_Master_Backup/"),
                         pattern = ".lss$", full.names = TRUE)

  lssnumbers <- stringr::str_extract(lssfiles, "\\d+")

  lssdf <- tibble::tibble(sid = as.integer(lssnumbers),
                          lss = lssfiles,
                          here = lsspaths)

  masterssenddf <- masters |> dplyr::left_join(lssdf, by = "sid")

  df <- masterssenddf |> dplyr::filter(template == "tmpl_bfr_allg_gm_elt_00_2022_p1")


  # Limer_sendSurvey(lss = df$here[1],
  #                  name = df$template[1])

  purrr::map2(df$here, df$template, Limer_sendSurvey, progress = TRUE)
}


utils::globalVariables(c("type", "relevance", "gid", "title", "row_number",
                         "variable", "master", "sid"))

