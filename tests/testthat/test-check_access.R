test_that("Check access", {
  t <- expect_silent(nominatim_check_access())
  
  expect_type(t, "logical")
})
