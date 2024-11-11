# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")




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








