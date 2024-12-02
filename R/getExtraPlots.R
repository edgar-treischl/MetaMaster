
#' Get Extra Plots from the Manual Data
#'
#' @description This helper function splits the report_meta_dev data
#'  and returns the extra plots for a given report template.
#' @param reporttemplate The report template
#' @examples
#' \dontrun{
#' get_ExtraPlots(reporttemplate = "rpt_elt_p2")
#' }
#' @export

get_ExtraPlots <- function(reporttemplate) {



  cli::cli_inform("This function is not ready yet. We need to clarify how extra plots are defined. What about n>2?")
  #The source
  report_meta_dev <- DB_Table("reports")


  #Extract plots by report template that appear more than once
  report_meta_dev |>
    dplyr::filter(report == reporttemplate) |>
    #dplyr::select(1:3) |>
    dplyr::group_by(vars) |>
    dplyr::mutate(n = dplyr::n()) |>
    dplyr::filter(n > 1)

}

get_ExtraPlots(reporttemplate = "rpt_elt_p1")


#' Get Extra Plots for All Report Templates
#'
#' @description This is a wrapper function that returns all extra plots based
#'  on the report_meta_dev data.
#' @param export Export the result.
#' @param filter Only extra plots, not their parent.
#' @examples
#' \dontrun{
#' get_AllExtraPlots(export = FALSE, filter = TRUE)
#' }
#' @export


get_AllExtraPlots <- function(export = FALSE,
                              filter = FALSE) {

  cli::cli_inform("This function is not ready yet. We need to clarify how extra plots are defined. What about n>2?")

  #The source: Get all report names
  gisela_reports <- DB_Table("reports") |>
    dplyr::select(report) |>
    dplyr::pull() |>
    unique()


  # gisela_reports <- readxl::read_excel("data/report_meta_dev.xlsx",
  #                                      sheet = "reports") |>
  #   dplyr::select(report) |>
  #   dplyr::pull() |>
  #   unique()

  #Get the master_to_template table
  mtf <- DB_Table("master_to_template")
  reports <-mtf$report

  #Check for differences
  #dplyr::setdiff(gisela_reports, reports)

  #Get all extra plots
  extraPlots <- purrr::map(gisela_reports, get_ExtraPlots, .progress = TRUE)

  #Bind the results
  extraPlots <- extraPlots |>
    dplyr::bind_rows() |>
    dplyr::arrange(report, vars)

  #Filter the extra plots: W only
  if (filter == TRUE) {
    extraPlots$wplots <- stringr::str_starts(extraPlots$plot, "W")
    extraPlots <- extraPlots |> dplyr::filter(wplots == "TRUE")
  }

  #Export the result
  if (export == TRUE) {
    cli::cli_alert_success("Exporting extraPlots")
    writexl::write_xlsx(extraPlots, "extraPlots.xlsx")
  }else {
    return(extraPlots)
  }

}


utils::globalVariables(c("report", "vars", "wplots", "n"))


