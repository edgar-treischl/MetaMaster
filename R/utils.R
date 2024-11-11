#' Extract Text from HTML
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @param input HTML code
#' @export
extract_html <- function(input) {
  rvest::minimal_html(input) |>
    rvest::html_elements("p") |>
    rvest::html_elements("b") |>
    rvest::html_text2()
}


#' Update all Masters LimeSurvey
#' @description Some text in LimeSurvey are stored in HTML format.
#'  This helper function extracts it from the HTML code.
#' @export

update_allMastersLimeSurvey <- function() {
  allMasters <- get_MasterTemplate()
  writexl::write_xlsx(allMasters, "data/allMastersLimeSurvey.xlsx")
}

#update_allMastersLimeSurvey()









#' Add report template
#' @description Bla bla


add_report_template <- function() {
  mastertmp <- MetaMaster::MasterToTemplates

  template <- mastertmp$template


  report_template <- template |>
    stringr::str_replace_all("tmpl_", "rpt_")


  mastertmp$report_template <- report_template
  mastertmp

  #export to excel file

  openxlsx::write.xlsx(mastertmp, here::here("data/master_to_template.xlsx"))

}


#add_report_template()




