if (file.exists("config.yml") == "FALSE") {
  testthat::skip("Skipping tests due to missing config.yml")
}


test_that("prepare_OverallReport works", {

  overallreports1 <- prepare_OverallReport("Paket Berufliche Oberschulen")
  expect_s3_class(overallreports1, "data.frame")

})
