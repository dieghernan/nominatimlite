test_that("Returning empty query", {
  expect_warning(geo_address_lookup("xbzbzbzoa aiaia", "R"))
})


test_that("Checking query", {
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
