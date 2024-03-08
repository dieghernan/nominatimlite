test_that("Access false", {
  expect_false(nominatim_check_access("https://www.google.com/"))
})

test_that("api_url", {
  api <- prepare_api_url("https://www.google.com", "some_invented_entry?")

  expect_snapshot(f <- api_call(api, tempfile(), quiet = FALSE))
  expect_false(f)

  # Checking with right approach
  skip_on_cran()
  skip_if_api_server()
  url <- prepare_api_url(
    "https://nominatim.openstreetmap.org/",
    "status.php?format=json"
  )


  expect_silent(t <- api_call(url, quiet = TRUE))
  expect_true(t)
})
