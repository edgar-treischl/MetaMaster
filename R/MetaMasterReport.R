
#' Send results of a test run via Mail
#' @description This function sends the results of a test run via mail to a
#'  specified email address. It expects a file named "TestRun_YYYY_MM_DD.xlsx".
#' @param sendto The email address to send the test run to
#' @export

send_testrun <- function(sendto) {


  date <- format(Sys.time(), "%Y_%m_%d")
  filename <- paste0("TestRun_", date, ".xlsx")

  #Read "MetaMasterTestRun_2024_10_30.xlsx"
  metadf <- readxl::read_excel(filename)

  #Create a flextable as preview?
  # ft <- metadf |>
  #   dplyr::select(surveyID, template, vars, report, surveytemplate, excel_name) |>
  #   flextable::flextable()
  #
  # #Save the flextable as an image
  # flextable::save_as_image(ft, path = "errors.png")



  #Create a blastula email manually
  # image <- blastula::add_image(file = here::here("man/figures/logo.png"))
  #
  #
  # body_text <-
  #   blastula::md(glue::glue(
  #     "
  # Hi Gisela,
  #
  # dies ist eine automatisierte Mail mit den Ergebnissen des Metamasters (siehe Anhang).
  #
  # XXX,
  #
  # MetaMaster
  #
  # {image}
  #
  # "
  #   ))
  #
  #
  # # Create/Compose a (first) mail
  # email <- blastula::compose_email(
  #   body = body_text
  # )
  #
  # email


  # # Create a smtp credentials file
  # blastula::create_smtp_creds_file(
  #   file = "my_mail_creds",
  #   user = "edgar.treischl@isb.bayern.de",
  #   host = "postout.lrz.de",
  #   port = 465,
  #   use_ssl = TRUE
  # )

  #get date and time and add it to the subject
  date <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  mailsubject <- paste("MetaMaster Update", date)

  #Build the email with the template
  email <- blastula::render_email("template_mail.Rmd")|>
    blastula::add_attachment(file = filename)

  # Send the email with smtp_send
  #Gisela.Goegelein@isb.bayern.de
  email |>
    blastula::smtp_send(
      to = sendto,
      from = "edgar.treischl@isb.bayern.de",
      subject = mailsubject,
      credentials = blastula::creds_file("my_mail_creds")
    )

}


#send_testrun()
