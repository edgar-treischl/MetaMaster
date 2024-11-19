#' Delete a Survey from Lime Survey Instance
#'
#' @description This function deletes a survey from a Lime Survey instance.
#' @param id The id of the survey to delete.
#' @return Response from the API.
#' @examples \dontrun{
#' Limer_DeleteSurvey(id = "116647")
#' }
#' @export


Limer_DeleteSurvey <- function(id) {
  #Get specs from config
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential

  tmp.session <- surveyConnectLs(user = tmp.user,
                                 credential = tmp.credential,
                                 server = tmp.server)

  # Get the number of completed responses for a survey
  response <- call_limer(method = "delete_survey",
                         params = list(iSurveyID  = id)
  )

  release_session_key()

  cli::cli_inform("Survey deleted:")
  return(response)
}


