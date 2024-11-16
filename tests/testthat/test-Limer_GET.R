if (TRUE) skip("Some Important Requirement is not available")

test_that("Limer_GetMasterTemplates returns data frame with 3 columns", {
  skip_on_cran()
  df <- Limer_GetMasterTemplates(template = TRUE)
  expect_s3_class(df, "data.frame")

  expect_equal(ncol(df), 3)
})



