if (Sys.getenv("NO_TESTS") == "TRUE") {
  testthat::skip("Skipping tests due to NO_TESTS environment variable")
}


test_that("Extra plot function returns data", {
  extraplots <- get_ExtraPlots(reporttemplate = "rpt_elt_p2")
  expect_s3_class(extraplots, "data.frame")

  # allextraplots <- get_AllExtraPlots(export = FALSE, filter = TRUE)
  # expect_s3_class(allextraplots, "data.frame")

})



