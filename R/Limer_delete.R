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


#' Delete All Mastertemplates from LimeSurvey
#'
#' @description This function deletes all master templates from Lime Survey that are listed
#'  in the master_to_template table.
#' @return Response from the API.
#' @examples
#' \dontrun{
#' LS_DeleteMasterTemplates()
#' }
#' @export

LS_DeleteMasterTemplates <- function() {
  #Get survey ids to delete
  master_to_template <- DB_Table("master_to_template")
  surveyID <- master_to_template$surveyID |> unique() |> as.character()

  #Test purposes
  #surveyID <- c("197865", "136172")

  #For each surveyID, delete the survey
  #LS_DeleteSurvey(surveyID[2])

  #For all surveyIDs, delete the survey via purrr
  surveyID |> purrr::map(LS_DeleteSurvey)
}
