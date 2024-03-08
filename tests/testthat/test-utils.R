test_that("Check add_custom_query", {
  u <- "http://test"
  t <- add_custom_query(custom_query = list(), url = u)
  expect_identical(u, t)

  # Uname some argument
  t <- add_custom_query(custom_query = list(1, b = 2), url = u)
  expect_identical(u, t)

  # Uname some argument
  t <- add_custom_query(custom_query = list(a = 1, 2), url = u)
  expect_identical(u, t)


  # Uname some argument
  t <- add_custom_query(custom_query = list(3), url = u)
  expect_identical(u, t)


  # Check
  t <- add_custom_query(custom_query = list(a = 3, b = 3), url = u)
  expect_identical("http://test&a=3&b=3", t)
})

test_that("prepare_api_url", {
  t <- prepare_api_url(entry = "an_entry")
  expect_identical(t, "https://nominatim.openstreetmap.org/an_entry")

  # Add trailing slash
  t2 <- prepare_api_url("https://nominatim.openstreetmap.org", "an_entry")
  expect_identical(t, t2)

  # Custom server
  t3 <- prepare_api_url("http://localhost:2322/nominatim-update", "custom")
  expect_identical(t3, "http://localhost:2322/nominatim-update/custom")
})
