test_that("Deprecated", {
  skip_if_not_installed("lifecycle")

  expect_snapshot(geo_amenity(), error = TRUE)
})
