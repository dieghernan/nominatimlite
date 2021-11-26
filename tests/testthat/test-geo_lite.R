test_that("Returning empty query", {
  expect_message(geo_lite("xbzbzbzoa aiaia"))

  skip_on_cran()
  skip_if_api_server()

  obj <- geo_lite("xbzbzbzoa aiaia")

  expect_true(nrow(obj) == 1)

  expect_true(obj$query == "xbzbzbzoa aiaia")
})

test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_true(is.data.frame(geo_lite("Madrid")))
  expect_false(inherits(geo_lite("Madrid"), "sf"))
  # this is _not_ a _sf function
})


test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


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

  expect_equal(nrow(geo_lite(
    c("Pentagon", "Pentagon"),
    limit = 1,
    verbose = TRUE
  )), 2)
})
