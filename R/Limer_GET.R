# Sys.setenv(R_CONFIG_ACTIVE = "test")
# library(MetaMaster)
#
# mastertemplatesList <- get_masters()

#' Get master templates from LimeSurvey
#'
#' @description This function gets the master templates from Lime Survey.
#' @param template Logical. If TRUE, the function will return the template name.
#' @return Results from the API.
#' @examples \dontrun{
#' get_MasterTemplate()
#' }
#' @export


Limer_GetMaster <- function(template = FALSE) {
  # Step 1: Get configuration settings (no error handling)
  get <- config::get()
  tmp.server <- get$tmp.server
  tmp.user <- get$tmp.user
  tmp.credential <- get$tmp.credential

  # Step 2: Establish a session with the survey system
  tmp.session <- surveyConnectLs(user = tmp.user, credential = tmp.credential, server = tmp.server)

  # Step 3: Retrieve the list of surveys
  lslist <- call_limer(method = "list_surveys")

  # Step 4: Check for error status in the response
  if (!is.null(lslist$status) && grepl("Error", lslist$status)) {
    cli::cli_abort(
      message = "Failed to retrieve data from the API. Status: {lslist$status}",
      .call = match.call()
    )
  }

  # Step 5: Release the session key
  release_session_key()

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


#Limer_GetMaster(template = TRUE)


#' Upload Master Templates as Survey Templates to LimeSurvey
#'
#' @description This function uploads the master templates as survey templates
#'  to LimeSurvey.
#' @return Results from the API.
#' @examples \dontrun{
#' Limer_UploadTemplates()
#' }
#' @export



Limer_UploadTemplates <- function() {
  cli::cli_abort("This function is not ready yet. Adjust paths!")
  masters <- Limer_GetMaster(template = TRUE)

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




