#' Get the list of questions for a given survey ID
#' @description This function retrieves the list of questions for a given survey ID.
#' @param id Survey ID
#' @return A character vector of unique question IDs
#' @export

Limer_GetQlist <- function(id) {
  # Get configuration parameters
  config_data <- config::get()

  # Extract server, user, and credential information from the config
  tmp.server <- config_data$tmp.server
  tmp.user <- config_data$tmp.user
  tmp.credential <- config_data$tmp.credential

  # Connect to the survey system
  tmp.session <- surveyConnectLs(user = tmp.user,
                                 credential = tmp.credential,
                                 server = tmp.server)

  # Check if the connection was successful
  if (is.null(tmp.session)) {
    cli::cli_abort(
      message = "Connection failed. Please check your credentials or server settings.",
      .call = match.call()
    )
  }

  # Retrieve the list of questions for the given survey ID
  lslist <- call_limer(method = "list_questions", params = list(iSurveyID = id))

  # Check for error status in the response
  if (!is.null(lslist$status) && grepl("Error", lslist$status)) {
    cli::cli_abort(
      message = "Failed to retrieve questions. Status: {lslist$status}",
      .call = match.call()
    )
  }

  # Check if the list is empty or NULL
  if (is.null(lslist) || nrow(lslist) == 0) {
    cli::cli_abort(
      message = "No questions found for the given survey ID.",
      .call = match.call()
    )
  }

  # Release the session key
  release_session_key()

  # Filter the list for questions of type "T" and exclude "0"
  # lslist_filtered <- lslist |>
  #   dplyr::filter(type == "T", qid != "0")

  lslist_filtered <- lslist |>
    dplyr::filter(parent_qid == "0")

  # Extract unique question IDs
  qidls <- as.character(lslist_filtered$qid)

  # Return the unique question IDs
  return(qidls)
}



#Limer_GetQlist(id = "197865")





#' Get Question Title, Plot Name, and Question Text by Question ID
#' @description This function retrieves the question title, plot name,
#'  and question text for a given question ID.
#' @param qid Question ID
#' @return A tibble with columns 'title', 'plot', and 'question'
#' @export

Limer_getQuestionsbyQID <- function(qid) {
  # Get configuration parameters
  config_data <- config::get()

  # Extract server, user, and credential information from the config
  tmp.server <- config_data$tmp.server
  tmp.user <- config_data$tmp.user
  tmp.credential <- config_data$tmp.credential

  # Connect to the survey system
  tmp.session <- surveyConnectLs(user = tmp.user,
                                 credential = tmp.credential,
                                 server = tmp.server)

  # Check if the connection is successful
  if (is.null(tmp.session)) {
    cli::cli_abort(
      message = "Connection failed. Please check your credentials or server settings.",
      .call = match.call()
    )
  }

  # Retrieve the question properties by question ID
  lslist <- call_limer(method = "get_question_properties", params = list(iQuestionID = qid))

  # Check for error in the response
  if (!is.null(lslist$status) && grepl("Error", lslist$status)) {
    cli::cli_abort(
      message = "Failed to retrieve question properties. Status: {lslist$status}",
      .call = match.call()
    )
  }

  # Check if required data exists in the response
  if (is.null(lslist$title) || is.null(lslist$available_answers)) {
    cli::cli_abort(
      message = "No question properties found or missing data for the given Question ID.",
      .call = match.call()
    )
  }

  # Release the session key
  release_session_key()

  # Create a tibble for available answers and their plot names
  ls_df <- tibble::tibble(
    title = rep(lslist$title, length(lslist$available_answers)),
    plot = names(lslist$available_answers),
    question = unlist(lslist$available_answers)
  )

  # Arrange the tibble by the 'plot' column
  # ls_df <- ls_df |>
  #   dplyr::arrange(plot)

  # Return the formatted tibble
  return(ls_df)
}


#Limer_getQuestionsbyQID(qid = "3307")





