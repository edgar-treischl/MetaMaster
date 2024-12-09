if (file.exists("config.yml") == "FALSE") {
  testthat::skip("Skipping tests due to missing config.yml")
}



test_that("Extract Text from HTML", {
  txt_html <- '<p><span style="font-size:28px;"><b><span style="line-height:115%;"><span style="font-family:Calibri, sans-serif;">Meine Klassenlehrerin (...) was in meiner Klasse alles passiert (7-10).</span></span></b> </span></p>'
  txt <- 'Not HTML Code'
  expect_true(is_html(txt_html))
  expect_false(is_html(txt))

  txt <- extract_html(txt_html)
  expect_type(txt, "character")
})

test_that("Extract Whitespaces from LimeSurvey Txts", {
  uglytxt <- "Meine KL    merkt, was in meiner Klasse alles passiert (7-10)."
  txt <- remove_and_combine(uglytxt)
  expect_type(txt, "character")
})



test_that("create_TestSchools returns df", {

  Sys.setenv(R_CONFIG_ACTIVE = "test")
  testdf <- create_TestSchools()
  expect_s3_class(testdf, "data.frame")
})


test_that("create_config returns characters", {

  yaml <- create_config(export = FALSE)
  expect_type(yaml, "character")
})






