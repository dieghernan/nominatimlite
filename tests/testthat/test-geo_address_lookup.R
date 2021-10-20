test_that("Returning empty query", {
  expect_message(geo_address_lookup("xbzbzbzoa aiaia", "R"))

  skip_if_api_server()
  skip_on_cran()

  obj <- geo_address_lookup("xbzbzbzoa aiaia", "R")

  expect_true(nrow(obj) == 1)

  expect_true(obj$query == "Rxbzbzbzoa aiaia")
})

test_that("Data format", {
  skip_if_api_server()
  skip_if_offline()
  skip_on_cran()

  expect_true(is.data.frame(geo_address_lookup(34633854, "W")))
  expect_false(inherits(geo_address_lookup(34633854, "W"), "sf"))
  # this is _not_ a _sf function
})

test_that("Checking query", {
  skip_if_api_server()
  skip_if_offline()
  skip_on_cran()

  expect_equal(ncol(geo_address_lookup(34633854, "W")), 4)
  expect_gt(ncol(geo_address_lookup(34633854, "W", full_results = TRUE)), 4)
  expect_equal(nrow(geo_address_lookup(34633854, "W",
    full_results = TRUE,
    custom_query = list(extratags = 1)
  )), 1)
  expect_equal(nrow(geo_address_lookup(34633854, "W",
    custom_query = list(countrycode = "us")
  )), 1)
})
