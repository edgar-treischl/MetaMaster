# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")
# #Get master template for all school types
# LimeSurveytemplates <- LS_GetMasterTemplates()


# library(readxl)
# report <- read_excel("~/bycsdrive/Personal/OES_MetaData/report_meta_devE.xlsx",
#                                sheet = "reports")
#
# MetaMaster::DB_send(report, "reports")
#
# MetaMaster::DB_Table()


#' Workaround (Soft depreciated)
#'
#' @description This helper function matches the manual meta data with master
#'  templates from LimeSurvey. This way, the function check which variables
#'  of the manual meta data can be merged. Furthermore, the function adds the
#'  plot to the variable name. Once we get code, variable and names and
#'  plot via the API, this function will be depreciated. Thus, this is a helper
#'  function to create a running system without manual steps.
#' @param sid The survey id
#' @param master_title The title of the master template
#' @examples \dontrun{
#' workaround(sid = LimeSurveytemplates$sid[1],
#'            master_title = LimeSurveytemplates$surveyls_title[1])
#'
#' purrr::map2(LimeSurveytemplates$sid,
#'             LimeSurveytemplates$surveyls_title,
#'             workaround, .progress = TRUE)
#' }
#' @export

workaround <- function(sid, master_title) {
  #Get master meta data from LimeSurvey
  LimeSurveyMaster <- LS_GetMasterQuestions(id = sid,
                                     name = master_title)

  check <- length(LimeSurveyMaster$variable)

  #Replace Variablename LimeSurveyMaster$plot
  names(LimeSurveyMaster)[names(LimeSurveyMaster) == "plot"] <- "code"

  #Which report in this case is the master report
  report_template <- DB_Table("master_to_template")

  report_template <- report_template |>
    dplyr::filter(surveyls_title == master_title) |>
    dplyr::pull(rpt)

  #report_template <- unique(report_template)
  report_template <- report_template[1]


  #Get the plots for the master report for that report

  Gisela_plots <- DB_Table("reports")

  Gisela_plots <- Gisela_plots |>
    dplyr::filter(report == report_template) |>
    dplyr::select(vars, plot_meta = plot)

  Gisela_plots$plot_meta_filled <- Gisela_plots$plot_meta

  Gisela_plots$plot_meta_filled <- stringr::str_replace_all(Gisela_plots$plot_meta_filled, pattern = "A1", replacement = "A01")
  Gisela_plots$plot_meta_filled <- stringr::str_replace_all(Gisela_plots$plot_meta_filled, pattern = "A2", replacement = "A02")
  Gisela_plots$plot_meta_filled <- stringr::str_replace_all(Gisela_plots$plot_meta_filled, pattern = "A4", replacement = "A04")
  Gisela_plots$plot_meta_filled <- stringr::str_replace_all(Gisela_plots$plot_meta_filled, pattern = "A6", replacement = "A06")
  Gisela_plots$plot_meta_filled <- stringr::str_replace_all(Gisela_plots$plot_meta_filled, pattern = "ZE", replacement = "ZFE")
  Gisela_plots$plot_meta_filled <- stringr::str_replace_all(Gisela_plots$plot_meta_filled, pattern = "ZS", replacement = "ZFS")
  Gisela_plots$plot_meta_filled <- stringr::str_replace_all(Gisela_plots$plot_meta_filled, pattern = "ZA", replacement = "ZFA")
  Gisela_plots$plot_meta_filled <- stringr::str_replace_all(Gisela_plots$plot_meta_filled, pattern = "ZL", replacement = "ZL")



  #Add characters to the plot_old column
  Gisela_plots$plot_meta_filled <- stringr::str_pad(Gisela_plots$plot_meta_filled, width = 4, side = "right", pad = "a")


  #Filter out the plots that are not unique
  #MasterGiselaLS$filter <- stringr::str_detect(MasterGiselaLS$plot_meta, pattern = "W")
  extraplots <- get_ExtraPlots(reporttemplate = report_template)
  extraplots$wplots <- stringr::str_detect(extraplots$plot, pattern = "W")

  extraplots <- extraplots |>
    dplyr::filter(wplots == TRUE) |>
    dplyr::pull(plot) |>
    unique()


  #filter if the are not the extraplots
  Gisela_plots <- Gisela_plots |> dplyr::filter(!plot_meta %in% extraplots)


  #combine master and report plots: Matching variable is variable == vars
  MasterGiselaLS <- dplyr::left_join(LimeSurveyMaster, Gisela_plots, by = c("variable" = "vars"))


  MasterGiselaLS$masterplots <- stringr::str_c(MasterGiselaLS$variable, MasterGiselaLS$plot_meta_filled)


  MasterGiselaLS$report <- report_template

  df <- MasterGiselaLS |> dplyr::arrange(variable)

  if (check != length(df$variable)) {
    cli::cli_abort("The number of variables in the master template is not equal to the number of variables in the report. Please check the master template and the report template.")
  }else {
    print(paste("Export: ", master_title))
  }

  #get a string with date and time
  date <- format(Sys.time(), "%Y_%m_%d")
  folder <- paste0("automation_", date)
  folder <- here::here(folder)

  fs::dir_create(folder)

  filename <- here::here(folder, paste0(master_title, ".xlsx"))


  ##Export MasterGiselaLS as excel
  #writexl::write_xlsx(df, path = filename)
  return(df)
}



# workaround(sid = LimeSurveytemplates$sid[26],
#            master_title = LimeSurveytemplates$surveyls_title[26])
#
# purrr::map2(LimeSurveytemplates$sid,
#             LimeSurveytemplates$surveyls_title,
#             workaround, .progress = TRUE)



#' Swap the Titles of the LimeSurvey Files (LLS)
#'
#' @description This helper function adjusts the titles of the LLS Limesurvey file.
#'  It extracts the title from the LLS File, matches it with Meta Data and
#'  exports the new LLS file. By doing so, this helper function automates the
#'  process of adjusting the titles of the LLS file. This function is a workaround
#'  until we get the code, variable and plot name via the API. Once we get the
#'  code, variable and plot name via the API, this function will be depreciated.
#' @param file The LLS file
#' @examples \dontrun{
#' lssfile <- list.files("automation_2024_11_18", pattern = ".lss", full.names = TRUE)
#' SwapLimesurveyTitles(file = lssfile)
#' }
#' @export


SwapLimesurveyTitles <- function(file) {

  #Read file
  xml_file <- xml2::read_xml(file)

  #Get the survey id
  id <- xml2::xml_find_all(xml_file, "//surveyls_survey_id")
  sid <- xml2::xml_text(id) |> unique()

  #Get the master template
  mastertmpl <- xml2::xml_find_all(xml_file, "//surveyls_title")
  mastertmpl <- xml2::xml_text(mastertmpl) |> unique()
  mastertmpl <- stringr::str_subset(mastertmpl, pattern = "^master_")
  mastertmpl

  #Get the title of a survey item
  title <- xml2::xml_find_all(xml_file, "//title")

  #Replace the title of the survey item with the title from the master template
  master <- readxl::read_excel(here::here("automation_2024_11_18/master_01_bfr_allg_gm_elt_00_2022_v4.xlsx")) |>
    dplyr::filter(template == mastertmpl)

  #Create vectors with code and variable names
  codes <- master$code |> unique()
  codes <- stringr::str_sort(codes)

  #New one
  masterplots <- master$masterplots
  masterplots <- c(codes, masterplots)

  #Old one
  oldvar <- c(codes, master$variable)

  #Create a mapping
  title_mapping <- setNames(masterplots, oldvar)

  #Replace the title with the title from the master template
  xml2::xml_text(title) <- purrr::map_chr(xml2::xml_text(title), ~ title_mapping[.])

  #Save the modified XML file
  limesurveyMod <- paste0("limesurvey_survey_", sid, ".lss")
  cli::cli_alert_success(paste0("Export: ", limesurveyMod))
  xml2::write_xml(xml_file, file = limesurveyMod)


  # Limer_sendSurvey(lss = limesurveyMod,
  #                  name = mastertemplate)
}










