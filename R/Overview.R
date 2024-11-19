# Sys.setenv(R_CONFIG_ACTIVE = "test")
# library(MetaMaster)
# #Get the names all unique survey templates
#
# mastername <- get_master(templatename = "tmpl_bfr_allg_gm_elt_00_2022_p1")
# mastername
# #
# mastertemplatesList <- get_masters()
# head(mastertemplatesList$template)
# head(mastertemplatesList$master)
#
#
# master <- get_TemplateDF(mastername = "master_01_bfr_allg_gm_elt_00_2022_v4")
# master
#
# gisela_report(template = "tmpl_bfr_allg_gm_elt_00_2022_p1")
#
#
# #send_testrun(sendto = "john.doe@johndoe.com")
#
# #LS Questions
# Limer_GetQlist(id = "197865")
#
#
# Limer_getQuestionsbyQID(qid = "3307")
#
#
# Limer_sendSurvey(lss = here::here("data/MasterTemplates/Minke_Master_Backup/limesurvey_survey_197865.lss"),
#                  name = "TestEdgar")
# #
# #Limer_DeleteSurvey(id = "197865")
#
#
#
# ##DB Functions
#
# # DB_send(table = readxl::read_excel("data/master_to_template.xlsx"),
# #         name = "master_to_template")
#
# #DB_MetaUpdate(path = "data/report_meta_dev.xlsx")
#
# #DB_Table()
#
#
#
#
# options(cli.ignore_unknown_rstudio_theme = TRUE)
# pkgdown::build_site()
#
# update_allMastersLimeSurvey()
#
#
# get_AllMasterMeta(export = TRUE)
#
#
# testrun(export = TRUE)

#devtools::document()

#send_testrun(sendto = "edgar.treischl@me.com")
