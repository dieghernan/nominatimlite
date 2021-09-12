test_that("Returning empty query", {
  expect_warning(geo_lite("xbzbzbzoa aiaia"))
})

test_that("Data format", {
  expect_true(is.data.frame(geo_lite("Madrid")))
  expect_false(inherits(geo_lite("Madrid"), "sf")) # this is _not_ a _sf function
})


test_that("Checking query", {
  expect_equal(ncol(geo_lite(c("Madrid", "Barcelona"))), 4)
  expect_gt(ncol(geo_lite("Madrid", full_results = TRUE)), 4)
  expect_gt(nrow(geo_lite("Madrid",
    limit = 10,
    custom_query = list(countrycode = "es")
  )), 4)
  expect_equal(nrow(geo_lite("Madrid",
    custom_query = list(countrycode = "es")
  )), 1)
  expect_equal(nrow(geo_lite("Madrid",
    custom_query = list(extratags = 1)
  )), 1)
})
