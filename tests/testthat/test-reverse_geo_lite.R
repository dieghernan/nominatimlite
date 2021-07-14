test_that("Returning empty query", {
  expect_warning(reverse_geo_lite(200, 200))
})

test_that("Returning error", {
  expect_error(reverse_geo_lite(0, c(2, 3)))
  expect_error(reverse_geo_lite("a", "a"))
})


test_that("Checking query", {
  expect_equal(ncol(reverse_geo_lite(0, 0)), 3)
  expect_gt(ncol(reverse_geo_lite(0, 0, full_results = TRUE)), 3)
  expect_equal(nrow(reverse_geo_lite(0, 40,
    custom_query = list(zoom = 0)
  )), 1)
})
