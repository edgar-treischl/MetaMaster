if (Sys.getenv("NO_TESTS") == "TRUE") {
  testthat::skip("Skipping tests due to NO_TESTS environment variable")
}


test_that("prepare_OverallReport works", {

  overallreports1 <- prepare_OverallReport("Paket Berufliche Oberschulen")
  expect_s3_class(overallreports1, "data.frame")

})
