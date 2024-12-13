#' Connect with Limesurvey
#'
#' @description Verbindung mit Limesurvey aufbauen
#' @param server Sever name
#' @param user Limesurvey user
#' @param credential Limesurvey credential
#' @return session id aus Limesurvey
#' @export

LS_Connect <- function(server, user, credential) {
  #Check input if otherwise
  server_names <- c("hws", "semiotikon", "las.my-survey.host")
  if (server %in% server_names == FALSE) {
    cli::cli_abort("Server name must be hws or semiotikon.")
  }

  #Connect semiotikon
  if (server == "semiotikon") {
    options(lime_api = config::get("api_url"))
    options(lime_username = user)
    options(lime_password = credential)
    tmp.session <- get_session_key()
  }
  #Connect hws
  if (server == "hws") {
    options(lime_api = config::get("api_url"))
    options(lime_username = user)
    options(lime_password = credential)
    tmp.session <- get_session_key()
  }

  if (server == "las.my-survey.host") {
    options(lime_api = config::get("api_url"))
    options(lime_username = user)
    options(lime_password = credential)
    tmp.session <- get_session_key()
  }

  #Check for invalid user
  # if (tmp.session == "Invalid user name or password") {
  #   cli::cli_abort("Error in surveyConnectLs(): Invalid user name or password.")
  # }
  return(tmp.session)
}





#' Make a call to the LimeSurvey API
#'
#' @description This function makes a generic call to the LimeSurvey API.
#'  See \url{https://manual.limesurvey.org/RemoteControl_2_API} for API documentation.
#' @param method API function to call. Full lis Defaults to value set in \code{options()}.
#' @param params Optional named list of parameters to pass to the function.
#' @param \dots Other arguments passed to \code{\link[httr]{POST}}.
#' @return Results from the API (sometimes plain text, sometimes base64-encoded text).
#' @import httr
#' @examples \dontrun{
#' LS_Ask(method = "list_surveys")
#' LS_Ask(method = "get_summary",
#'            params = list(iSurveyID = 238481,
#'                          sStatname = "completed_responses"))
#' }
#' @export

LS_Ask <- function(method, params = list(), ...) {
  if (!is.list(params)) {
    stop("params must be a list.")
  }

  if (!exists("session_key", envir = session_cache)) {
    stop("You need to get a session key first. Run get_session_key().")
  }

  key.list <- list(sSessionKey = session_cache$session_key)
  params.full <- c(key.list, params)

  body.json <- list(method = method,
                    id = " ",
                    params = params.full)

  r <- httr::POST(getOption('lime_api'), httr::content_type_json(),
                  body = jsonlite::toJSON(body.json, auto_unbox = TRUE), ...)

  return(jsonlite::fromJSON(httr::content(r, as='text', encoding="utf-8"))$result)
}


#' Get a LimeSurvey API session key
#'
#' @description This function logs into the LimeSurvey API and provides an access session key.
#' @param username LimeSurvey username. Defaults to value set in \code{options()}.
#' @param password LimeSurvey password Defaults to value set in \code{options()}.
#' @return API token
#' @import httr
#' @export
#' @examples \dontrun{
#' get_session_key()
#' }

get_session_key <- function(username = getOption('lime_username'),
                            password = getOption('lime_password')) {
  body.json = list(method = "get_session_key",
                   id = " ",
                   params = list(username = username,
                                 password = password))

  # Need to use jsonlite::toJSON because single elements are boxed in httr, which
  # is goofy. toJSON can turn off the boxing automatically, though it's not
  # recommended. They say to use unbox on each element, like this:
  #   params = list(admin = unbox("username"), password = unbox("password"))
  # But that's a lot of extra work. So auto_unbox suffices here.
  # More details and debate: https://github.com/hadley/httr/issues/159
  r <- httr::POST(getOption('lime_api'), httr::content_type_json(),
                  body = jsonlite::toJSON(body.json, auto_unbox = TRUE))

  session_key <- as.character(jsonlite::fromJSON(httr::content(r, as='text', encoding="utf-8"))$result)
  session_cache$session_key <- session_key
  session_key
}

# Start a new environment to hold the session key so all other functions can access it
# See http://trestletech.com/2013/04/package-wide-variablescache-in-r-package/
session_cache <- new.env(parent = emptyenv())



#' Get responses (data) from LimeSurvey
#'
#' @description This function exports and downloads data from a LimeSurvey survey.
#' @param iSurveyID \dots
#' @param sDocumentType \dots
#' @param sLanguageCode \dots
#' @param sCompletionStatus \dots
#' @param sHeadingType \dots
#' @param sResponseType \dots
#' @param \dots Further arguments to \code{\link{LS_Ask}}.
#' @export
#' @examples \dontrun{
#' get_responses(12345)
#' }

get_responses <- function(iSurveyID, sDocumentType = "csv", sLanguageCode = NULL,
                          sCompletionStatus = "complete", sHeadingType = "code",
                          sResponseType = "long", ...) {
  # Put all the function's arguments in a list to then be passed to LS_Ask()
  params <- as.list(environment())
  dots <- list(...)
  if(length(dots) > 0) params <- append(params,dots)
  # print(params) # uncomment to debug the params

  results <- LS_Ask(method = "export_responses", params = params)
  return(base64_to_df(unlist(results)))
}




#' Convert base64 encoded data to a data frame
#'
#' @description  This function converts raw base64 results into a data frame.
#' @param x \dots
#' @importFrom utils read.csv
#' @export
#' @examples \dontrun{
#' base64_to_df()
#' }

base64_to_df <- function(x) {
  raw_csv <- rawToChar(base64enc::base64decode(x))

  return(utils::read.csv(textConnection(raw_csv), stringsAsFactors = FALSE, sep = ";"))
}


#' Release a LimeSurvey API session key
#'
#' This function clears the LimeSurvey API session key currently in use, effectively logging out.
#' @export
#' @examples \dontrun{
#' release_session_key()
#' }

LS_Release <- function() {
  LS_Ask(method = "release_session_key")
}


utils::globalVariables(c("tmp.server",
                         "tmp.user",
                         "tmp.credential",
                         "parent_qid",
                         "surveyls_title"))
