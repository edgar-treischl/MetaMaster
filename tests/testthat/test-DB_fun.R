if (TRUE) skip("Some Important Requirement is not available")

test_that("DB_Table returns table names", {

  skip_on_cran()
  alltables <- DB_Table()
  #expect_gt(alltables, 0)
  expect_type(alltables, "character")
})

test_that("DB_Table returns data frame", {
  skip_on_cran()
  alltables <- DB_Table()
  testdata <- DB_Table(alltables[1])
  expect_s3_class(testdata, "data.frame")
})





