test_that("Returning empty query", {
  expect_message(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ))

  skip_on_cran()
  skip_if_api_server()

  obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  )

  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "xbzbzbzoa aiaia")
})

test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_true(is.data.frame(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  )))
  expect_s3_class(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  ), "sf")
})


test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_equal(ncol(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  )), 3)
  expect_gt(ncol(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub", full_results = TRUE,
    points_only = FALSE
  )), 3)
  expect_gt(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    limit = 10,
    custom_query = list(countrycode = "es")
  )), 4)
  expect_equal(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    custom_query = list(countrycode = "es")
  )), 1)
  expect_equal(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    custom_query = list(extratags = 1)
  )), 1)

  expect_lt(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    limit = 1,
    strict = TRUE
  )), 2)

  expect_equal(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "pub"),
    limit = 1,
    verbose = TRUE
  )), 2)
})
