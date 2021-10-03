test_that("Check access", {
  t <- expect_silent(nominatim_check_access())
  
  expect_type(t, "logical")
})

skip_if_api_server <- function() {
  if (nominatim_check_access()) {
    return(invisible(TRUE))
  }
  
  skip("Nominatim API not reachable")
}
