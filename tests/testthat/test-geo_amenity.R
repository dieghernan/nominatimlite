test_that("Non-reachable", {
  expect_message(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ), "not reachable")

  skip_on_cran()
  skip_if_api_server()

  expect_message(obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ))

  expect_true(nrow(obj) == 1)
  expect_s3_class(obj, "tbl")
  expect_true(obj$query == "xbzbzbzoa aiaia")
})

test_that("Returning Empty", {
  skip_on_cran()
  skip_if_api_server()


  expect_message(
    obj <- geo_amenity(
      bbox = c(-88.1446, 41.5022, -87.4854, 41.8795),
      amenity = "grit_bin"
    ),
    "No results"
  )


  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "grit_bin")
  expect_s3_class(obj, "tbl")
})


test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  )

  expect_s3_class(obj, "tbl")
  expect_false(inherits(obj, "sf"))
})

test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  expect_message(obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
    limit = 51
  ), "50 results")


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

  expect_equal(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "pub"),
    limit = 1,
  )), 1)
})
