if (TRUE) skip("Some Important Requirement is not available")

test_that("Limer_GetMasterTemplates returns data frame with 3 columns", {
  skip_on_cran()
  df <- Limer_GetMasterTemplates(template = TRUE)
  expect_s3_class(df, "data.frame")

  expect_equal(ncol(df), 3)
})


test_that("Limer_GetMasterQuesions returns data frame with 5 columns", {
  skip_on_cran()
  df <- Limer_GetMasterTemplates(template = TRUE)

  master01 <- Limer_GetMasterQuesions(id = df$sid[1],
                                      name = df$surveyls_title[1])


  expect_s3_class(master01, "data.frame")
  expect_equal(ncol(master01), 5)
})






