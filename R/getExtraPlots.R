
#' Get Extra Plots
#'
#' @description This helper function splits the report_meta_dev data
#'  and returns the extra plots for a given report template.
#' @export

get_ExtraPlots <- function(reporttemplate) {


  # report_meta_dev <- readxl::read_excel("data/report_meta_dev.xlsx",
  #                                       sheet = "reports")

  report_meta_dev <- DB_Table("reports")



  report_meta_dev |>
    dplyr::filter(report == reporttemplate) |>
    #dplyr::select(1:3) |>
    dplyr::group_by(vars) |>
    dplyr::mutate(n = dplyr::n()) |>
    dplyr::filter(n > 1)

}

#get_ExtraPlots(reporttemplate = "rpt_elt_p2")


#' Get  Extra Plots for All Report Templates
#' @description This is a wrapper function that returns all extra plots based
#'  on the report_meta_dev data.
#' @export


get_AllExtraPlots <- function(export = FALSE,
                              filter = FALSE) {

  #cli::cli_warn("This function is not ready yet. We need to clarify how extra plots are defined. What about n>2?")
  gisela_reports <- DB_Table("reports") |>
    dplyr::select(report) |>
    dplyr::pull() |>
    unique()


  # gisela_reports <- readxl::read_excel("data/report_meta_dev.xlsx",
  #                                      sheet = "reports") |>
  #   dplyr::select(report) |>
  #   dplyr::pull() |>
  #   unique()

  mtf <- DB_Table("master_to_template")
  reports <-mtf$report


  #dplyr::setdiff(gisela_reports, reports)

  extraPlots <- purrr::map(gisela_reports, get_ExtraPlots, .progress = TRUE)


  extraPlots <- extraPlots |>
    dplyr::bind_rows() |>
    dplyr::arrange(report, vars)

  if (filter == TRUE) {
    extraPlots$wplots <- stringr::str_starts(extraPlots$plot, "W")

    extraPlots <- extraPlots |> dplyr::filter(wplots == "TRUE")
  }




  if (export == TRUE) {
    cli::cli_alert_success("Exporting extraPlots to data/extraPlots.xlsx")
    writexl::write_xlsx(extraPlots, "data/extraPlots.xlsx")
    return(extraPlots)
  }else {
    return(extraPlots)
  }

}



#get_AllExtraPlots(export = FALSE, filter = TRUE)
