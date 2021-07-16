test_that("Returning empty query", {
  expect_warning(reverse_geo_lite_sf(200, 200))
  expect_warning(reverse_geo_lite_sf(
    lat = c(0, 90),
    long = c(40, 90)
  ))
})

test_that("Returning error", {
  expect_error(reverse_geo_lite_sf(0, c(2, 3)))
  expect_error(reverse_geo_lite_sf("a", "a"))
})


test_that("Checking query", {
  expect_equal(ncol(reverse_geo_lite_sf(0, 0)), 4)
  expect_gt(ncol(reverse_geo_lite_sf(0, 0,
    full_results = TRUE
  )), 4)
  expect_equal(nrow(reverse_geo_lite_sf(0, 40,
    polygon = TRUE,
    custom_query = list(zoom = 0)
  )), 1)
})
