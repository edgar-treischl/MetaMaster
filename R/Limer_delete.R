#' Delete a Survey from Lime Survey Instance
#'
#' @description This function deletes a survey from Lime Survey.
#' @param id The survey ID.
#' @return Response from the API.
#' @examples
#' \dontrun{
#' LS_DeleteSurvey(id = "id")
#' }
#' @export


LS_DeleteSurvey <- function(id) {

  #Get specs
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential

  # Connect
  tmp.session <- LS_Connect(user = tmp.user,
                            credential = tmp.credential,
                            server = tmp.server)

  #Ask to delete survey
  response <- LS_Ask(method = "delete_survey",
                     params = list(iSurveyID  = id)
  )
  #Release
  LS_Release()

  cli::cli_inform("Survey deleted:")
  return(response)
}


