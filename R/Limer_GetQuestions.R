#' Get meta data from LimeSurvey master templates.
#'
#' @description This function gets the meta data from LimeSurvey master templates.
#' @param id Survey ID.
#' @param name Survey name (surveyls_title).
#' @return Results from the API.
#' @examples \dontrun{
#' get_MasterMeta()
#' }
#' @export


get_MasterMeta <- function(id, name) {

  #Get specs from config
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential
  #Connect
  tmp.session <- surveyConnectLs(user = tmp.user,
                                 credential = tmp.credential,
                                 server = tmp.server)

  fucktemplates <- c("master_08_bfr_allg_gs_sus_02_2022_v4",
                     "master_07_bfr_allg_gs_sus_00_2022_v4",
                     "master_28_bfr_zspf_fz_sus_05_2022_v4",
                     "master_37_bfr_allg_gs_sus_00_2022_v4",
                     "master_38_bfr_zspf_fz_sus_05_2022_v4",
                     "master_bfr_zspf_fz_sus_05_2022_v0")


  lslist <- call_limer(method = "list_questions",
                       params = list(iSurveyID = id))

  release_session_key()

  if (rlang::is_empty(lslist$status) == FALSE) {
    problem <- paste0("Error in get_MasterMeta(): ", lslist$status)
    cli::cli_abort(problem)
  }

  # if (purrr::is_empty(titles) == TRUE) {
  #   cli::cli_abort("No questions found in survey.")
  # }


  if (name %in% fucktemplates == TRUE) {
    varname <- lslist$title
    plot <- substr(varname, 1, 3)
    varname <- substr(varname, 4, nchar(varname))


    #cli::cli_abort("Fuck.")
  }else {
    df <- lslist |>
      dplyr::select(parent_qid, title)


    # Step 1: Extract plot titles (where parent_qid == 0)

    titles <- df |>
      dplyr::filter(parent_qid == 0) |>
      dplyr::mutate(row_number = dense_rank(title)) |>
      dplyr::select(row_number, plot = title, parent = parent_qid)


    var_titles <- df |>
      dplyr::filter(parent_qid != 0) |>
      dplyr::mutate(row_number = dense_rank(parent_qid)) |>
      dplyr::select(row_number, title, parentV = parent_qid)


    #Left join the two dataframes on row_number
    matched_variables <- titles |>
      dplyr::left_join(var_titles, by = "row_number")


    plot <- matched_variables$plot
    varname <- matched_variables$title


    #OLD approach
    # new_title <- df |>
    #   dplyr::mutate(new_title = ifelse(parent_qid == 0, title, NA)) |>
    #   tidyr::fill(new_title) |>
    #   dplyr::mutate(new_title = ifelse(parent_qid == 0, new_title, paste0(new_title, title))) |>
    #   dplyr::select(parent_qid, title = new_title) |>
    #   dplyr::pull(title)
    #
    #
    # lslist$title <- new_title
    #
    #
    #
    # titles <- lslist |>
    #   dplyr::filter(parent_qid != 0) |>
    #   #dplyr::filter(parent_qid != 0) |>
    #   dplyr::pull(title)
    #
    # #The first four characters
    # plot <- substr(titles, 1, 3)
    #
    # #The rest of the string
    # varname <- substr(titles, 4, nchar(titles))
  }


  if (name %in% fucktemplates == TRUE) {
    questions <- "lslist$question"

    q1 <- rvest::minimal_html(questions[1]) |>
      rvest::html_elements("span") |>
      rvest::html_elements("b") |>
      rvest::html_text2()

    questions_rest <- questions[-1]

    q_rest <- purrr::map(questions_rest, extract_html) |>
      purrr::flatten_chr()

    q_rest <- q_rest[q_rest != " "]

    questions <- c(q1, q_rest)
    questions <- stringr::str_trim(questions)

    if (length(questions) != length(lslist$question)) {
      questions <- "Error: Questions not extracted correctly"
    }


  }else {
    questions <- lslist |>
      dplyr::filter(parent_qid != "0") |>
      dplyr::pull(question)

    questions <- stringr::str_trim(questions)
  }

  #stringr::str_detect(name, pattern = "_ubb_")
  #lslist$str_length <- stringr::str_length(lslist$question)





  template <- tibble::tibble(surveyID = id,
                             template = name,
                             plot = plot,
                             variable = varname,
                             text = questions)

  return(template)
}


#' Get the Master Date from LimeSurvey
#'
#' @description This function gets the meta data from LimeSurvey for all master templates.
#' @param export Export the data to an Excel file.
#' @return Results from the API.
#' @examples \dontrun{
#' Limer_GetMasterData(export = FALSE)
#' }
#' @export


Limer_GetMasterData <- function(export = FALSE) {
  #Get all the masters ids and names from LimeSurvey
  limerdf <- Limer_GetMaster(template = FALSE)
  sid <- limerdf$sid
  surveyls_title <- limerdf$surveyls_title

  #Get the metadata for all the masters
  allmasters <- purrr::map2(sid,
                            surveyls_title,
                            get_MasterMeta, .progress = TRUE)

  #Bind all the metadata
  allmasters <- allmasters |> dplyr::bind_rows()

  if (export == TRUE) {
    #get a string with todays date: 2024_11_11
    today <- format(Sys.Date(), "%Y_%m_%d")

    writexl::write_xlsx(allmasters, paste0("MasterData_", today, ".xlsx"))
    cli::cli_alert_success("Master Data exported.")
  }else {
    return(allmasters)
  }
}

#Limer_GetMasterData(export = FALSE)


















