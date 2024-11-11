# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")
#Master to Template


#' Deprecated: Get the templates Deprecated
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @export

# get_templates <- function() {
#
#   master_to_template <- readxl::read_excel("data/master_to_template.xlsx")
#
#   templates <- master_to_template |>
#     dplyr::arrange(surveyls_title) |>
#     dplyr::pull(template)
#
#   return(templates)
# }

#templates <- get_templates()


#' Deprecated: Get the templates
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @param templatename Template name
#' @export
# get_master <- function(templatename) {
#   master_to_template <- readxl::read_excel("data/master_to_template.xlsx")
#
#   mastername <- master_to_template |>
#     dplyr::filter(template == templatename) |>
#     dplyr::pull(surveyls_title)
#
#
#   return(mastername)
#
# }


#mastername <- get_master(templatename = "tmpl_bfr_allg_gm_elt_00_2022_p1")

#' Get the templates
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @export

get_masters <- function() {

  templates <- get_templates()
  allmasters <- purrr::map_chr(templates, get_master)

  list("template" = templates,
       "master" = allmasters)

}

#mastertemplatesList <- get_masters()



####################HERE##########################

# allMasters <- get_MasterTemplate()
# writexl::write_xlsx(allMasters, "data/allMastersLimeSurvey.xlsx")

#' Get the templates
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @param mastername Master name
#' @export
get_TemplateDF <- function(mastername) {

  allMasters <- readxl::read_excel(here::here("data/allMastersLimeSurvey.xlsx"))

  MasterID <- allMasters |>
    dplyr::filter(surveyls_title == mastername) |>
    dplyr::pull(sid)


  master01 <- get_MasterMeta(id = MasterID,
                             name = mastername)


  #rename columns variable to vars
  master01 <- master01 |> dplyr::rename(vars = variable)
  master01
}


#master <- get_TemplateDF(mastername = "master_01_bfr_allg_gm_elt_00_2022_v4")


#From Gisla To Master
#' Get the templates
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @param template Template name
#' @export

gisela_report <- function(template) {
  report_meta_dev <- readxl::read_excel("data/report_meta_dev.xlsx")

  report_template <- report_meta_dev |>
    dplyr::filter(surveys == template) |>
    dplyr::pull(report_tmpl)

  report_meta_rep <- readxl::read_excel("data/report_meta_dev.xlsx",
                                        sheet = "reports")




  reportdf <- report_meta_rep |>
    dplyr::filter(report == report_template) |>
    dplyr::select(-label)

  gisela_report <- list("reporttemplate" = report_template,
                        "report" = reportdf)

  return(gisela_report)
}


#gisela_report(template = "tmpl_bfr_allg_gm_elt_00_2022_p1")


#From Gisla To Master
#' Get the templates
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @param templatename Template name
#' @param mastername Master name
#' @param mistakes Logical
#' @export

joinMetaGisela <- function(templatename,
                           mastername,
                           mistakes = TRUE,
                           update = FALSE) {
  gisela_report <- gisela_report(template = templatename)
  master <- get_TemplateDF(mastername = mastername)

  report_template <- gisela_report$reporttemplate
  report <- gisela_report$report

  #match master with report by variable: vars
  master_universe <- master |> dplyr::left_join(report,
                                                  by = "vars")

  #Stefan fragen`?`
  # dplyr::setdiff(master$vars, report$vars)
  # dplyr::setdiff(report$vars, master$vars)

  # master_universe <- master |> dplyr::left_join(report,
  #                                                 by = "vars",
  #                                                 relationship = "one-to-one",
  #                                                 unmatched = "error")

  if (nrow(master_universe) == 0) {
    cli::cli_abort("No matching variables between master and report")
  }

  if (mistakes == TRUE) {
    master_universe <- master_universe |> dplyr::filter(is.na(report) == TRUE)

    if (nrow(master_universe) > 0) {
      excel_name <- dplyr::setdiff(report$vars, master$vars)
      master_universe$report <- report_template
      if (length(master_universe$vars) == length(excel_name)) {
        master_universe$excel_name <- excel_name

      }
    }

  }





  master_universe$surveytemplate <- templatename
  #master_universe |> dplyr::select(surveyID, template, vars, plot, report, surveytemplate)

  return(master_universe)

}


# joinMetaGisela(templatename = "tmpl_bfr_allg_gm_elt_00_2022_p1",
#                mastername = "master_01_bfr_allg_gm_elt_00_2022_v4")


#From Gisla To Master
#' Get the templates
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @param export Export results to Excel
#' @export

testrun <- function(export = FALSE) {

  mastertemplatesList <- get_masters()
  #exclude <- c(-17, -18, -19, -68, -69, -70, -71)

  metadf <- purrr::map2(mastertemplatesList$template,
                        mastertemplatesList$master,
                        joinMetaGisela, .progress = TRUE)


  #metadf <- metadf |> dplyr::bind_rows()


  # unique(metadf$template)
  # unique(metadf$surveytemplate)
  # mastertemplatesList$template[1:3]
  # mastertemplatesList$master[1:3]


  #get only year, month and day
  if (export == TRUE) {
    date <- format(Sys.time(), "%Y_%m_%d")
    file <- paste0("TestRun_", date, ".xlsx")
    metadf <- metadf |> dplyr::bind_rows()

    writexl::write_xlsx(metadf, file)
  }else {
    return(metadf)
  }

}


#testrun(export = FALSE)











#OVerall?############################

# master_to_template <- readxl::read_excel("data/master_to_template.xlsx")
#
#
# overall01 <- master_to_template |>
#   dplyr::filter(template == templates01) |>
#   dplyr::pull(surveyls_title)
#
#
# master_universe |> dplyr::filter(template == overall01)








