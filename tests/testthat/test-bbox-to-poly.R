test_that("bbox_to_poly() rejects incomplete bounding boxes", {
  expect_snapshot(error = TRUE, bbox_to_poly())
  expect_snapshot(error = TRUE, bbox_to_poly(1))
  expect_snapshot(error = TRUE, bbox_to_poly(xmin = 1))
})


test_that("bbox_to_poly() accepts vector and component coordinates", {
  expect_silent(bbox_to_poly(c(1, 2, 3, 4)))
  expect_silent(bbox_to_poly(xmin = 1, xmax = 2, ymin = 3, ymax = 4))

  test_box <- bbox_to_poly(xmin = 1, xmax = 2, ymin = 3, ymax = 4) |>
    sf::st_bbox() |>
    as.numeric() |>
    setNames(c("xmin", "ymin", "xmax", "ymax"))
  expect_equal(test_box, c(xmin = 1, ymin = 3, xmax = 2, ymax = 4))

  crsa <- sf::st_crs(bbox_to_poly(c(1, 2, 3, 4)))
  crsb <- sf::st_crs(bbox_to_poly(c(1, 2, 3, 4), crs = 3857))

  expect_false(identical(crsa, crsb))
})

test_that("bbox_to_poly() returns polygons with the requested CRS", {
  obj <- bbox_to_poly(c(1, 2, 3, 4))
  expect_s3_class(obj, "sfc")
  expect_equal(as.character(sf::st_geometry_type(obj)), "POLYGON")
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))

  obj <- bbox_to_poly(c(1, 2, 3, 4), crs = 3035)
  expect_s3_class(obj, "sfc")
  expect_equal(as.character(sf::st_geometry_type(obj)), "POLYGON")
  expect_identical(sf::st_crs(obj), sf::st_crs(3035))
})
