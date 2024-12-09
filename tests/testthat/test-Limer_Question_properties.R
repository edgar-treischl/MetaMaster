if (file.exists("config.yml") == "FALSE") {
  testthat::skip("Skipping tests due to missing config.yml")
}



test_that("Limer_GetQlist return question list", {
  Sys.setenv(R_CONFIG_ACTIVE = "test")

  qlist <- LS_GetQlist(id = "197865")
  expect_type(qlist, "character")
  expect_error(Limer_GetQlist(id = "1"))
})


# test_that("multiplication works", {
#   Sys.setenv(R_CONFIG_ACTIVE = "test")
#
#   qlist <- Limer_getQuestionsbyQID(qid = "102273")
#   #expect_s3_class(qlist, "data.frame")
#   #expect_error(Limer_getQuestionsbyQID(id = "1"))
# })



