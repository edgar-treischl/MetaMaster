#if (TRUE) skip("Some Important Requirement is not available")
if (Sys.getenv("NO_TESTS") == "TRUE") {
  testthat::skip("Skipping tests due to NO_TESTS environment variable")
}



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


test_that("DB_send updates table, DB_DeleteFrom cleans it", {
  #skip_on_cran()
  # Create a table
  DB_send(table = tibble::tibble(test = TRUE),
          name = "test")
  testtable <- DB_Table("test")

  expect_true(testtable$test[1])

  # Delete the table
  DB_DeleteFrom("test")

  testtable <- DB_Table("test")
  expect_equal(nrow(testtable), 0)

})






