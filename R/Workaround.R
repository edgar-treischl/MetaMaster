# library(MetaMaster)
# Sys.setenv(R_CONFIG_ACTIVE = "test")
# #Get master template for all school types
# LimeSurveytemplates <- Limer_GetMasterTemplates()




# library(readxl)
# reports <- read_excel("~/bycsdrive/Personal/OES_MetaData/report_meta_devE.xlsx",
#                                sheet = "reports")
#
# DB_send(reports, name = "reports")


workaround <- function(sid, master_title) {
  #Get master meta data from LimeSurvey
  LimeSurveyMaster <- Limer_GetMasterQuesions(id = sid,
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
  writexl::write_xlsx(df, path = filename)
  #return(MasterGiselaLS)
}


# workaround(sid = LimeSurveytemplates$sid[22],
#            master_title = LimeSurveytemplates$surveyls_title[22])
# #
# purrr::map2(LimeSurveytemplates$sid,
#             LimeSurveytemplates$surveyls_title,
#             workaround, .progress = TRUE)










#Create new LimeSurvey Template###################################################


# # masternew |>
# #   dplyr::filter(variable == "Z1E") |>
# #   dplyr::select(plot, variable, plot_old, masterplots)
# #
# #
# # masternew |>
# #   dplyr::filter(variable == "B131W124E") |>
# #   dplyr::select(plot, variable, plot_old, masterplots)
#
#
# master_tpl1 <- readr::read_delim("data/MasterTemplates/limesurvey_survey_197865.txt",
#                                        delim = "\t", escape_double = FALSE,
#                                        trim_ws = TRUE)
#
# master_tpl1 |> dplyr::filter(name == masternew$variable[1])
# master_tpl1
#
# # master_tpl1 |>
# #   dplyr::filter(class == "SQ") |>
# #   dplyr::filter(language  == "de") |>
# #   dplyr::select(name) |>
# #   unique()
#
#
# # #Replace the variable name in the master template with the new variable name
# # master_tpl1$name <- stringr::str_replace_all(master_tpl1$name, pattern = masternew$variable[1],
# #                          replacement = masternew$masterplots[1])
#
# # Create a named vector of replacements
#
# replacements <- setNames(masternew$masterplots, masternew$variable)
#
#
# # Replace all patterns in master_tpl1$name using reduce
# master_tpl1$nameNew <- purrr::reduce(names(replacements), function(x, pattern) {
#   stringr::str_replace_all(x, pattern, replacements[pattern])
# }, .init = master_tpl1$name)
#
#
#
# #View(master_tpl1)
#
#
# test <- master_tpl1 |>
#   dplyr::filter(class == "SQ") |>
#   dplyr::filter(language  == "de") |>
#   dplyr::select(name, nameNew)
#
# View(test)
#
# test <- master_tpl1 |>
#   dplyr::filter(class == "SQ") |>
#   dplyr::filter(language  == "de") |>
#   dplyr::select(nameNew)
#
#
#
#
# dplyr::setdiff(test$nameNew, masternew$masterplots)
#
# dplyr::union(master_tpl1$nameNew, master_tpl1$name)
#
#
#
#
# test <- master_tpl1 |>
#   dplyr::select(name, nameNew)
#
#
# View(test)











