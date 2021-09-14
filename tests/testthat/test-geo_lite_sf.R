test_that("Returning empty query", {
  expect_warning(geo_lite_sf("xbzbzbzoa aiaia"))
})

test_that("Data format", {
  expect_true(is.data.frame(geo_lite_sf("Madrid")))
  expect_s3_class(geo_lite_sf("Madrid"), "sf")
})

test_that("Checking query", {
  expect_equal(ncol(geo_lite_sf(c("Madrid", "Barcelona"))), 3)
  expect_gt(ncol(geo_lite_sf("Madrid", full_results = TRUE)), 3)
  expect_gt(nrow(geo_lite_sf("Madrid",
    limit = 10,
    custom_query = list(countrycode = "es")
  )), 4)
  expect_equal(nrow(geo_lite_sf("Madrid",
    custom_query = list(countrycode = "es")
  )), 1)

  expect_equal(nrow(geo_lite_sf("Madrid",
    custom_query = list(extratags = 1)
  )), 1)
})

test_that("Checking geometry type", {
  expect_true(
    sf::st_geometry_type(geo_lite_sf("Pentagon")) == "POINT"
  )
  expect_true(
    sf::st_geometry_type(geo_lite_sf("Pentagon",
      points_only = FALSE
    )) == "POLYGON"
  )
})
