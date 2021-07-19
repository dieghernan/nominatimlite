test_that("Returning empty query", {
  expect_warning(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ))
})


test_that("Checking query", {
  expect_equal(ncol(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub"
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
})
