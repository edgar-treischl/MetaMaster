test_that("Extract Text from HTML", {
  txt_html <- '<p><span style="font-size:28px;"><b><span style="line-height:115%;"><span style="font-family:Calibri, sans-serif;">Meine Klassenlehrerin (...) was in meiner Klasse alles passiert (7-10).</span></span></b> </span></p>'
  txt <- 'Not HTML Code'
  expect_true(is_html(txt_html))
  expect_false(is_html(txt))

  txt <- extract_html(txt_html)
  expect_type(txt, "character")
})


test_that("Extract Whitespaces from LimeSurvey Txts", {
  uglytxt <- "Meine KL    merkt, was in meiner Klasse alles passiert (7-10)."
  txt <- remove_and_combine(uglytxt)
  expect_type(txt, "character")
})












