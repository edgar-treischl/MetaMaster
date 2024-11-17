#if (TRUE) skip("Some Important Requirement is not available")


test_that("DB_Table returns table names", {

  # Call the DB_Table function

  alltables <- DB_Table()

  # Test the return type
  expect_type(alltables, "character")

  # Optionally, check that there are table names returned
  expect_true(length(alltables) > 0)
})


test_that("DB_Table returns data frame", {
  #skip_on_cran()

  alltables <- DB_Table()
  testdata <- DB_Table(alltables[1])
  expect_s3_class(testdata, "data.frame")

  expect_error(DB_Table("blubb"))

})





