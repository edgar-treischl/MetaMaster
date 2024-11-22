#' Send a Survey Template to Lime Survey
#'
#' @description This function sends a survey template to the Lime Survey.
#' @param lss Path to the survey template.
#' @param name The optional name of the survey. If not provided, the name of
#'  the survey will be extracted from the template.
#' @return Results from the API.
#' @examples
#' \dontrun{
#' LS_SendSurvey(lss = "limesurvey_XXX.lss", name = "MySurvey")
#' }
#' @export

LS_SendSurvey <- function(lss, name = NULL) {

  #Get specs from config
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential

  #Encode lss file
  test_64 <- base64enc::base64encode(lss)

  # Connect
  tmp.session <- LS_Connect(user = tmp.user,
                            credential = tmp.credential,
                            server = tmp.server)

  #Ask to import survey
  response <- LS_Ask(method = "import_survey",
                     params = list(sImportData = test_64,
                                   ImportDataType = "lss",
                                   NewSurveyName = name))
  #Release and inform
  LS_Release()
  cli::cli_inform("Created survey:")
  return(response)
}


#' Send Several Survey Templates to Lime Survey
#'
#' @description This function is wrapper around LS_SendSurvey to send
#'  several surveys on the fly.
#' @return Results from the API.
#' @examples
#' \dontrun{
#' LS_SendSurveys()
#' }
#' @export


LS_SendSurveys <- function() {
  cli::cli_abort("This function is not ready yet. Adjust paths!")

  lssfiles <- list.files(here::here("data/MasterTemplates/Minke_Master_Backup"),
                         full.names = TRUE)

  namesE <- c("Edgar", "Edga1")

  Limer_sendSurvey(lss = lssfiles[1], name = "Edgar1")

  response <- purrr::map2(lssfiles[1:2], namesE, LS_SendSurvey, .progress = TRUE)
  cli::cli_inform("Surveys created:")
  return(response)

}





