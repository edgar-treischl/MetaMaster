

#' Build Overall Report
#' @description This function will build an overall report based on the package name.
#' @param packagename The path to the Excel file.
#' @export


buildOverallReport <- function(packagename) {
  master_to_template <- DB_Table("master_to_template")

  allreports <- master_to_template |>
    dplyr::filter(pckg == packagename) |>
    dplyr::pull(report) |>
    unique()


  reports <- DB_Table("reports")


  overallreports <- reports |>
    dplyr::filter(report %in% allreports)

  check <- overallreports |>
    dplyr::pull(report) |>
    unique()

  if (identical(allreports, check) == FALSE) {
    return(as.list(allreports, check))
    cli::cli_abort("Reports are not the same. Check the data.")
  }else {
    overallreports$report <- packagename
    return(overallreports)
  }
}


#master_to_template <- DB_Table("master_to_template")
#report_packages <- master_to_template |> dplyr::pull(pckg) |> unique()

#buildOverallReport(packagename = report_packages[1])

#purrr::map(report_packages[1:17], buildOverallReport)



# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")
# df <- Limer_GetMasterTemplate(template = TRUE)
#
# df |> print(n = 20)
#
#
#
# get <- config::get()
# tmp.server <- get$tmp.server
# tmp.user <- get$tmp.user
# tmp.credential <- get$tmp.credential
# #Connect
# tmp.session <- surveyConnectLs(user = tmp.user,
#                                credential = tmp.credential,
#                                server = tmp.server)
#
#
# lslist <- call_limer(method = "list_questions",
#                      params = list(iSurveyID = df$sid[17]))
#
#
# release_session_key()
#
# View(lslist)
#
#
# gid_f <- lslist |>
#   dplyr::filter(relevance != "1") |>
#   dplyr::pull(gid) |>
#   unique()
#
# lslist |>
#   dplyr::filter(gid == gid_f) |>
#   dplyr::pull(title)



