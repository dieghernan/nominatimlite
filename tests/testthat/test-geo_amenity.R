test_that("Returning empty query", {
  skip_if_offline()
  expect_warning(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ))
})

test_that("Data format", {
  skip_if_offline()
  expect_true(is.data.frame(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  )))
  expect_false(inherits(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  ), "sf")) # this is _not_ a _sf function
})

test_that("Checking query", {
  skip_if_offline()
  expect_equal(ncol(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  )), 4)
  expect_gt(ncol(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub", full_results = TRUE
  )), 4)
  expect_gt(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    limit = 10,
    custom_query = list(countrycode = "es")
  )), 4)
  expect_equal(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    custom_query = list(countrycode = "es")
  )), 1)
  expect_equal(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    custom_query = list(extratags = 1)
  )), 1)
  expect_lt(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    limit = 1,
    strict = TRUE
  )), 2)
})
