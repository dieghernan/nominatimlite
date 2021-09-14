test_that("Returning empty query", {
  expect_warning(geo_address_lookup_sf("xbzbzbzoa aiaia", "R"))
})

test_that("Data format", {
  expect_true(is.data.frame(geo_address_lookup_sf(34633854, "W")))
  expect_s3_class(geo_address_lookup_sf(34633854, "W"), "sf")
})

test_that("Checking query", {
  expect_equal(ncol(geo_address_lookup_sf(34633854, "W")), 3)
  expect_gt(ncol(geo_address_lookup_sf(34633854, "W", full_results = TRUE)), 3)
  expect_equal(nrow(geo_address_lookup_sf(34633854, "W",
    full_results = TRUE,
    custom_query = list(extratags = 1)
  )), 1)
  expect_equal(nrow(geo_address_lookup_sf(34633854, "W",
    points_only = FALSE,
    custom_query = list(countrycode = "us")
  )), 1)
  expect_true(sf::st_geometry_type(geo_address_lookup_sf(34633854, "W",
                                          points_only = TRUE,
                                          custom_query = list(countrycode = "us")
  )) == "POINT")
  expect_true(sf::st_geometry_type(geo_address_lookup_sf(34633854, "W",
                                                      points_only = FALSE,
                                                      custom_query = list(countrycode = "us")
  )) == "POLYGON")
})
