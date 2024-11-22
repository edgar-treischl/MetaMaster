if (Sys.getenv("NO_TESTS") == "TRUE") {
  testthat::skip("Skipping tests due to NO_TESTS environment variable")
}


#if (TRUE) skip("Some Important Requirement is not available")

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

  master30 <- LS_GetMasterQuestions(id = df$sid[31],
                                   name = df$surveyls_title[31])


  expect_s3_class(master01, "data.frame")
  expect_s3_class(master30, "data.frame")
  expect_equal(ncol(master01), 6)
})




