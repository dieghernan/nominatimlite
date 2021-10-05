test_that("Returning empty query", {
  expect_message(geo_lite_sf("xbzbzbzoa aiaia"))
  
  skip_if_api_server()
  
  obj <- geo_lite_sf("xbzbzbzoa aiaia")

  expect_true(nrow(obj) == 1)
  expect_true(ncol(obj) == 1)
  expect_true(obj$query == "xbzbzbzoa aiaia")
})

test_that("Data format", {
  skip_if_api_server()
  skip_if_offline()
  expect_true(is.data.frame(geo_lite_sf("Madrid")))
  expect_s3_class(geo_lite_sf("Madrid"), "sf")
})

test_that("Checking query", {
  skip_if_api_server()
  skip_if_offline()

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
  skip_if_api_server()
  skip_if_offline()
  expect_true(
    sf::st_geometry_type(geo_lite_sf("Pentagon")) == "POINT"
  )
  expect_true(
    sf::st_geometry_type(geo_lite_sf("Pentagon",
      points_only = FALSE
    )) == "POLYGON"
  )
})
