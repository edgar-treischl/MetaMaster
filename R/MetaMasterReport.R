#' Send Test Results
#' @description This function send the test results to the specified email address.
#' @param sendto The recipient of the email
#' @examples \dontrun{
#' send_testrun(sendto = 'john.doe@johndoe.com')
#' }
#' @export

send_testrun <- function(sendto) {


  #date <- format(Sys.time(), "%Y_%m_%d")
  #filename <- paste0("TestRun_", date, ".xlsx")

  #Read "MetaMasterTestRun_2024_10_30.xlsx"
  metadf <- readxl::read_excel("MetaMasterMeta.xlsx")

  #Create a flextable as preview?
  # ft <- metadf |>
  #   dplyr::select(surveyID, template, vars, report, surveytemplate, excel_name) |>
  #   flextable::flextable()
  #
  # #Save the flextable as an image
  # flextable::save_as_image(ft, path = "errors.png")

  #get date and time and add it to the subject
  date <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  mailsubject <- paste("MetaMaster Update", date)

  #Build the email with the template
  email <- blastula::render_email("template_mail.Rmd")|>
    blastula::add_attachment(file = "MetaMasterMeta.xlsx")

  # Send the email with smtp_send
  email |>
    blastula::smtp_send(
      to = sendto,
      from = "edgar.treischl@isb.bayern.de",
      subject = mailsubject,
      credentials = blastula::creds_file("my_mail_creds")
    )

}


