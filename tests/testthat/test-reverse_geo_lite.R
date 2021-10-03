test_that("Returning empty query", {
  obj <- expect_message(reverse_geo_lite(200, 200))
  
  skip_if_api_server()

  expect_true(nrow(obj) == 1)
  expect_true(all(is.na(obj$address)))
})

test_that("Returning error", {
  skip_if_api_server()
  skip_if_offline()

  expect_error(reverse_geo_lite(0, c(2, 3)))
  expect_error(reverse_geo_lite("a", "a"))
})

test_that("Data format", {
  skip_if_api_server()
  skip_if_offline()

  expect_true(is.data.frame(reverse_geo_lite(0, 0)))
  expect_false(inherits(reverse_geo_lite(0, 0), "sf")) 
  # this is _not_ a _sf function
})

test_that("Checking query", {
  skip_if_api_server()
  skip_if_offline()

  expect_equal(ncol(reverse_geo_lite(0, 0)), 3)
  expect_gt(ncol(reverse_geo_lite(0, 0, full_results = TRUE)), 3)
  expect_equal(nrow(reverse_geo_lite(0, 40,
    custom_query = list(zoom = 0)
  )), 1)

  expect_equal(nrow(reverse_geo_lite(0, 40,
    custom_query = list(extratags = 1)
  )), 1)
  
  # Several coordinates
  sev <- reverse_geo_lite(
            lat = c(40.75728, 55.95335),
            long = c(-73.98586, -3.188375)
          )
          
  expect_equal(nrow(sev), 2)
})
