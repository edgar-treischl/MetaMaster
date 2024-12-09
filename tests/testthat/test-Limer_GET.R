if (file.exists("config.yml") == "FALSE") {
  testthat::skip("Skipping tests due to missing config.yml")
}



test_that("Limer_GetMasterTemplates returns data frame with 3 columns", {
  #skip_on_cran()
  Sys.setenv(R_CONFIG_ACTIVE = "test")
  df <- LS_GetMasterTemplates(template = TRUE)
  expect_s3_class(df, "data.frame")

  expect_equal(ncol(df), 3)
})


test_that("Limer_GetMasterQuestions returns data frame with 6 columns", {
  #skip_on_cran()
  Sys.setenv(R_CONFIG_ACTIVE = "test")
  df <- LS_GetMasterTemplates(template = TRUE)

  expect_error(LS_GetMasterQuestions(id = "1",
                                       name = "Name"))

  master01 <- LS_GetMasterQuestions(id = df$sid[1],
                                   name = df$surveyls_title[1])

  master29 <- LS_GetMasterQuestions(id = df$sid[29],
                                   name = df$surveyls_title[29])


  expect_s3_class(master01, "data.frame")
  expect_s3_class(master29, "data.frame")
  expect_equal(ncol(master01), 7)
})



