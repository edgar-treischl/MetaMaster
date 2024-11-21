test_that("prepare_OverallReport works", {

  overallreports1 <- prepare_OverallReport("Paket Berufliche Oberschulen")
  expect_s3_class(overallreports1, "data.frame")

})
