#' Send a survey template to Lime Survey
#'
#' @description This function sends a survey template to the LimeSurvey.
#' @param lss The survey template.
#' @param name The optional name of the survey.
#' @return Results from the API.
#' @examples \dontrun{
#' Limer_sendSurvey(lss = "struktur_LimeSurvey.lss",
#' name = "Edgar")
#' }
#' @export

Limer_sendSurvey <- function(lss, name = NULL) {

  #Get specs from config
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential

  #Encode lss file
  test_64 <- base64enc::base64encode(lss)

  tmp.session <- surveyConnectLs(user = tmp.user,
                                 credential = tmp.credential,
                                 server = tmp.server)

  # Get the number of completed responses for a survey
  response <- call_limer(method = "import_survey",
                         params = list(sImportData = test_64,
                                       ImportDataType = "lss",
                                       NewSurveyName = name))

  release_session_key()
  cli::cli_inform("Created survey:")
  return(response)
}


#' Send a list of survey templates to Lime Survey
#'
#' @description This function sends a survey template to the LimeSurvey API.
#' @return Results from the API.
#' @export


Limer_sendSurveys <- function() {
  lssfiles <- list.files(here::here("data/MasterTemplates/Minke_Master_Backup"),
                         full.names = TRUE)

  namesE <- c("Edgar", "Edga1")

  Limer_sendSurvey(lss = lssfiles[1], name = "Edgar1")

  response <- purrr::map2(lssfiles[1:2], namesE, Limer_sendSurvey, .progress = TRUE)
  cli::cli_inform("Surveys created:")
  return(response)

}





