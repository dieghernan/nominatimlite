test_that("Deprecated geo_amenity_sf", {
  skip_if_not_installed("lifecycle")

  expect_snapshot(geo_amenity_sf(), error = TRUE)
})

test_that("Deprecated geo_amenity", {
  skip_if_not_installed("lifecycle")

  expect_snapshot(geo_amenity(), error = TRUE)
})
